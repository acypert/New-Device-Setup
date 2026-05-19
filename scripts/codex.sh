#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib/codex-agents.sh"
source "$SCRIPT_DIR/lib/node.sh"

SOURCE_AGENTS="$ROOT_DIR/profiles/work/codex/AGENTS.md"
WORK_DEFAULT_BEGIN_MARKER="# BEGIN New-Device-Setup Codex default: work"

ensure_codex_feature_flags() {
  local config="$HOME/.codex/config.toml"
  local tmp

  mkdir -p "$HOME/.codex"

  if [[ ! -f "$config" ]]; then
    printf "[features]\nmemories = true\n" > "$config"
    return
  fi

  tmp="$(mktemp)"
  awk '
    BEGIN {
      managed_count = split("memories", managed, " ")
      disabled_count = split("hooks goals", disabled, " ")
      for (i = 1; i <= managed_count; i++) {
        desired[managed[i]] = 1
      }
      for (i = 1; i <= disabled_count; i++) {
        no_longer_managed[disabled[i]] = 1
      }
      in_features = 0
      saw_features = 0
    }
    function emit_missing(    i, key) {
      for (i = 1; i <= managed_count; i++) {
        key = managed[i]
        if (!seen[key]) {
          print key " = true"
          seen[key] = 1
        }
      }
    }
    /^\[features\][[:space:]]*$/ {
      saw_features = 1
      in_features = 1
      print
      next
    }
    /^\[/ {
      if (in_features) {
        emit_missing()
      }
      in_features = 0
    }
    in_features {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      for (key in no_longer_managed) {
        pattern = "^[[:space:]]*" key "[[:space:]]*="
        if (line ~ pattern) {
          next
        }
      }
      for (i = 1; i <= managed_count; i++) {
        key = managed[i]
        pattern = "^[[:space:]]*" key "[[:space:]]*="
        if (line ~ pattern) {
          if (!seen[key]) {
            print key " = true"
            seen[key] = 1
          }
          next
        }
      }
    }
    { print }
    END {
      if (!saw_features) {
        print ""
        print "[features]"
        emit_missing()
      } else if (in_features) {
        emit_missing()
      }
    }
  ' "$config" > "$tmp"
  mv "$tmp" "$config"
}

remove_omx_hook_trust_state() {
  local config="$HOME/.codex/config.toml"
  local hooks_path="$HOME/.codex/hooks.json"
  local tmp

  [[ -f "$config" ]] || return 0

  tmp="$(mktemp)"
  python3 - "$config" "$tmp" "$hooks_path" <<'PY'
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
tmp_path = Path(sys.argv[2])
hooks_path = sys.argv[3]

skip_table = False
output = []

for line in config_path.read_text(encoding="utf-8").splitlines(keepends=True):
    stripped = line.strip()

    if stripped.startswith("["):
        skip_table = (
            stripped.startswith("[hooks.state.")
            and f'"{hooks_path}:' in stripped
        )
        if skip_table:
            continue

    if skip_table:
        continue

    if stripped == "# End OMX-owned Codex hook trust state":
        continue

    output.append(line)

tmp_path.write_text("".join(output), encoding="utf-8")
PY
  mv "$tmp" "$config"
}

remove_codex_developer_instructions_config() {
  local config="$HOME/.codex/config.toml"
  local tmp

  [[ -f "$config" ]] || return 0

  tmp="$(mktemp)"
  python3 - "$config" "$tmp" <<'PY'
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
tmp_path = Path(sys.argv[2])

lines = config_path.read_text(encoding="utf-8").splitlines()
output = []
i = 0
assignment_re = re.compile(r"^\s*developer_instructions\s*=")

while i < len(lines):
    line = lines[i]
    if assignment_re.match(line):
        remainder = line.split("=", 1)[1]
        triple_count = remainder.count('"""')
        i += 1
        if triple_count % 2 == 1:
            while i < len(lines):
                triple_count += lines[i].count('"""')
                i += 1
                if triple_count % 2 == 0:
                    break
        continue

    output.append(line)
    i += 1

tmp_path.write_text("\n".join(output).rstrip() + "\n", encoding="utf-8")
PY
  mv "$tmp" "$config"
}

remove_omx_native_hooks() {
  local hooks_path="$HOME/.codex/hooks.json"

  [[ -f "$hooks_path" ]] || return 0

  python3 - "$hooks_path" <<'PY'
import json
import sys
from pathlib import Path

hooks_path = Path(sys.argv[1])
data = json.loads(hooks_path.read_text(encoding="utf-8"))

def is_omx_native_hook(hook):
    command = hook.get("command", "")
    return "oh-my-codex" in command and "codex-native-hook.js" in command

hooks = data.get("hooks", {})
clean_hooks = {}
for event_name, entries in hooks.items():
    clean_entries = []
    for entry in entries:
        entry_hooks = entry.get("hooks", [])
        remaining_hooks = [
            hook for hook in entry_hooks
            if not is_omx_native_hook(hook)
        ]
        if remaining_hooks:
            clean_entry = dict(entry)
            clean_entry["hooks"] = remaining_hooks
            clean_entries.append(clean_entry)
        elif not entry_hooks:
            clean_entries.append(entry)
    if clean_entries:
        clean_hooks[event_name] = clean_entries

if clean_hooks:
    data["hooks"] = clean_hooks
else:
    data.pop("hooks", None)

state = data.get("state", {})
clean_state = {
    key: value
    for key, value in state.items()
    if not key.startswith(f"{hooks_path}:")
}
if clean_state:
    data["state"] = clean_state
else:
    data.pop("state", None)

if data:
    hooks_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
else:
    hooks_path.unlink()
PY
}

refresh_omx_plugin_cache() {
  local npm_root
  local package_root
  local plugin_source
  local plugin_manifest
  local plugin_version
  local cache_base
  local destination
  local tmp_destination

  npm_root="$(npm root -g)"
  package_root="$npm_root/oh-my-codex"
  plugin_source="$package_root/plugins/oh-my-codex"
  plugin_manifest="$plugin_source/.codex-plugin/plugin.json"

  if [[ ! -f "$plugin_manifest" ]]; then
    printf "Oh My Codex plugin manifest not found: %s\n" "$plugin_manifest" >&2
    exit 1
  fi

  plugin_version="$(
    node -e 'const fs = require("fs"); const path = process.argv[1]; console.log(JSON.parse(fs.readFileSync(path, "utf8")).version);' "$plugin_manifest"
  )"

  cache_base="${CODEX_HOME:-$HOME/.codex}/plugins/cache/oh-my-codex-local/oh-my-codex"
  destination="$cache_base/$plugin_version"
  tmp_destination="$destination.tmp.$$"

  mkdir -p "$cache_base"
  rm -rf "$tmp_destination"
  mkdir -p "$tmp_destination"
  cp -R "$plugin_source"/. "$tmp_destination"/
  rm -rf "$destination"
  mv "$tmp_destination" "$destination"

  find "$cache_base" -mindepth 1 -maxdepth 1 -type d ! -name "$plugin_version" -exec rm -rf {} +
}

ensure_omx_plugin_config() {
  local config="$HOME/.codex/config.toml"
  local npm_root
  local package_root
  local tmp

  npm_root="$(npm root -g)"
  package_root="$npm_root/oh-my-codex"
  tmp="$(mktemp)"

  python3 - "$config" "$tmp" "$package_root" <<'PY'
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
tmp_path = Path(sys.argv[2])
package_root = sys.argv[3]

target_tables = {
    '[plugins."oh-my-codex@oh-my-codex-local"]',
    '[marketplaces.oh-my-codex-local]',
}

skip_table = False
output = []
for line in config_path.read_text(encoding="utf-8").splitlines(keepends=True):
    stripped = line.strip()
    if stripped.startswith("["):
        skip_table = stripped in target_tables
        if skip_table:
            continue
    if skip_table and stripped.startswith("# BEGIN New-Device-Setup "):
        skip_table = False
    if skip_table:
        continue
    output.append(line)

while output and not output[-1].strip():
    output.pop()

escaped_package_root = package_root.replace("\\", "\\\\").replace('"', '\\"')
output.extend([
    "\n\n",
    '[plugins."oh-my-codex@oh-my-codex-local"]\n',
    "enabled = true\n",
    "\n",
    "[marketplaces.oh-my-codex-local]\n",
    'source_type = "local"\n',
    f'source = "{escaped_package_root}"\n',
])

tmp_path.write_text("".join(output), encoding="utf-8")
PY
  mv "$tmp" "$config"
}

ensure_node_runtime

if ! command -v codex >/dev/null 2>&1; then
  printf "Codex is not installed. Run brew bundle --file Brewfile first.\n" >&2
  exit 1
fi

printf "Installing or updating Oh My Codex\n"
npm install -g oh-my-codex@latest

printf "Configuring Codex for OMX skills-only plugin discovery\n"
ensure_codex_feature_flags
remove_codex_developer_instructions_config
remove_omx_hook_trust_state
remove_omx_native_hooks
if [[ -f "$HOME/.codex/config.toml" ]] && grep -q "$WORK_DEFAULT_BEGIN_MARKER" "$HOME/.codex/config.toml"; then
  install_codex_agents_md "$SOURCE_AGENTS" full "$HOME/.codex/AGENTS.md"
else
  install_codex_agents_md "$SOURCE_AGENTS" without-additional "$HOME/.codex/AGENTS.md"
fi
refresh_omx_plugin_cache
ensure_omx_plugin_config

printf "OMX plugin skills are available without installing OMX native hooks.\n"
