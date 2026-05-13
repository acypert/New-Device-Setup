#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_CONFIG="$HOME/.codex/config.toml"
PROFILE_NAME="${1:-work}"

usage() {
  printf "Usage: %s work [--print|--profile-only]\n" "$0" >&2
}

if [[ "$PROFILE_NAME" != "work" ]]; then
  usage
  exit 1
fi

PRINT_ONLY=false
MAKE_DEFAULT=true

shift || true
for arg in "$@"; do
  case "$arg" in
    --print)
      PRINT_ONLY=true
      ;;
    --profile-only)
      MAKE_DEFAULT=false
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

BASE_URL="${CODEX_WORK_LITELLM_BASE_URL:-https://YOUR-LITELLM-HOST/v1}"
MODEL="${CODEX_WORK_LITELLM_MODEL:-YOUR-LITELLM-MODEL-ALIAS}"
ENV_KEY="${CODEX_WORK_LITELLM_ENV_KEY:-LITELLM_API_KEY}"
SOURCE_INSTRUCTIONS="$ROOT_DIR/profiles/work/codex/developer-instructions.md"
INSTALLED_PROFILE_DIR="$HOME/.codex/profiles/work"
INSTALLED_INSTRUCTIONS="$INSTALLED_PROFILE_DIR/developer-instructions.md"
ROOT_BEGIN_MARKER="# BEGIN New-Device-Setup Codex default: work"
ROOT_END_MARKER="# END New-Device-Setup Codex default: work"
PROFILE_BEGIN_MARKER="# BEGIN New-Device-Setup Codex profile: work"
PROFILE_END_MARKER="# END New-Device-Setup Codex profile: work"

if [[ ! -f "$SOURCE_INSTRUCTIONS" ]]; then
  printf "Work developer instructions not found: %s\n" "$SOURCE_INSTRUCTIONS" >&2
  exit 1
fi

generate_blocks() {
  python3 - \
    "$SOURCE_INSTRUCTIONS" \
    "$BASE_URL" \
    "$MODEL" \
    "$ENV_KEY" \
    "$ROOT_BEGIN_MARKER" \
    "$ROOT_END_MARKER" \
    "$PROFILE_BEGIN_MARKER" \
    "$PROFILE_END_MARKER" \
    "$MAKE_DEFAULT" <<'PY'
import sys
from pathlib import Path

(
    instructions_path,
    base_url,
    model,
    env_key,
    root_begin,
    root_end,
    profile_begin,
    profile_end,
    make_default,
) = sys.argv[1:]

instructions = Path(instructions_path).read_text(encoding="utf-8").rstrip() + "\n"

def toml_string(value: str) -> str:
    return '"""' + value.replace("\\", "\\\\").replace('"""', '\\"""') + '"""'

if make_default == "true":
    print(root_begin)
    print(f'model = "{model}"')
    print('model_provider = "litellm_work"')
    print('model_reasoning_effort = "xhigh"')
    print('personality = "pragmatic"')
    print('cli_auth_credentials_store = "auto"')
    print('developer_instructions = ' + toml_string(instructions))
    print(root_end)
    print()

print(profile_begin)
print('[model_providers.litellm_work]')
print('name = "LiteLLM Work"')
print(f'base_url = "{base_url}"')
print('wire_api = "responses"')
print(f'env_key = "{env_key}"')
print(f'env_key_instructions = "Set {env_key} in your shell environment before launching codex"')
print()
print('[profiles.work]')
print('model_provider = "litellm_work"')
print(f'model = "{model}"')
print('model_reasoning_effort = "xhigh"')
print('personality = "pragmatic"')
print('cli_auth_credentials_store = "auto"')
print('developer_instructions = ' + toml_string(instructions))
print(profile_end)
PY
}

if [[ "$PRINT_ONLY" == "true" ]]; then
  generate_blocks
  exit 0
fi

mkdir -p "$HOME/.codex" "$INSTALLED_PROFILE_DIR"
cp "$SOURCE_INSTRUCTIONS" "$INSTALLED_INSTRUCTIONS"
touch "$CODEX_CONFIG"

tmp_config="$(mktemp)"
block_file="$(mktemp)"
trap 'rm -f "$tmp_config" "$block_file"' EXIT

generate_blocks > "$block_file"

python3 - \
  "$CODEX_CONFIG" \
  "$tmp_config" \
  "$block_file" \
  "$ROOT_BEGIN_MARKER" \
  "$ROOT_END_MARKER" \
  "$PROFILE_BEGIN_MARKER" \
  "$PROFILE_END_MARKER" \
  "$MAKE_DEFAULT" <<'PY'
import re
import sys
from pathlib import Path

(
    config_path,
    tmp_path,
    block_path,
    root_begin,
    root_end,
    profile_begin,
    profile_end,
    make_default,
) = sys.argv[1:]

config_path = Path(config_path)
tmp_path = Path(tmp_path)
block_path = Path(block_path)

config = config_path.read_text(encoding="utf-8")
block = block_path.read_text(encoding="utf-8").rstrip() + "\n"

def remove_managed_block(text: str, begin: str, end: str) -> str:
    pattern = re.compile(rf"\n?{re.escape(begin)}.*?{re.escape(end)}\n?", re.DOTALL)
    return pattern.sub("\n", text)

def split_generated_block(text: str):
    root_block = ""
    profile_block = text
    if root_begin in text:
        start = text.index(root_begin)
        end = text.index(root_end) + len(root_end)
        root_block = text[start:end].rstrip() + "\n"
        profile_block = (text[:start] + text[end:]).strip() + "\n"
    return root_block, profile_block

def remove_top_level_keys(text: str) -> str:
    managed_keys = {
        "base_url",
        "chatgpt_base_url",
        "cli_auth_credentials_store",
        "developer_instructions",
        "env_key",
        "forced_chatgpt_workspace_id",
        "forced_login_method",
        "model",
        "model_provider",
        "model_reasoning_effort",
        "openai_base_url",
        "personality",
    }

    lines = text.splitlines()
    output = []
    i = 0
    in_top_level = True
    assignment_re = re.compile(r"^\s*([A-Za-z0-9_.-]+)\s*=")

    while i < len(lines):
        line = lines[i]
        stripped = line.lstrip()
        if in_top_level and stripped.startswith("["):
            in_top_level = False

        match = assignment_re.match(line) if in_top_level else None
        if match and match.group(1) in managed_keys:
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

    return "\n".join(output).rstrip() + "\n"

cleaned = remove_managed_block(config, root_begin, root_end)
cleaned = remove_managed_block(cleaned, profile_begin, profile_end)

root_block, profile_block = split_generated_block(block)

if make_default == "true":
    cleaned = remove_top_level_keys(cleaned).lstrip()
    next_config = root_block.rstrip() + "\n\n" + cleaned.rstrip() + "\n\n" + profile_block
else:
    for table in ("[profiles.work]", "[model_providers.litellm_work]"):
        if table in cleaned:
            raise SystemExit(
                f"{table} already exists outside the managed work-profile block. "
                "Move or remove it before applying this scaffold."
            )
    next_config = cleaned.rstrip() + "\n\n" + profile_block

tmp_path.write_text(next_config.lstrip(), encoding="utf-8")
PY

python3 - "$tmp_config" <<'PY'
import sys
try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib

with open(sys.argv[1], "rb") as f:
    tomllib.load(f)
PY

backup="$CODEX_CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CODEX_CONFIG" "$backup"
mv "$tmp_config" "$CODEX_CONFIG"

printf "Installed Codex work defaults into %s\n" "$CODEX_CONFIG"
printf "Backed up previous config to %s\n" "$backup"
printf "Copied work developer instructions to %s\n" "$INSTALLED_INSTRUCTIONS"

if [[ "$BASE_URL" == "https://YOUR-LITELLM-HOST/v1" || "$MODEL" == "YOUR-LITELLM-MODEL-ALIAS" ]]; then
  printf "\nWARN: Work profile still contains placeholder LiteLLM values.\n" >&2
  printf "Set CODEX_WORK_LITELLM_BASE_URL and CODEX_WORK_LITELLM_MODEL, then rerun this script.\n" >&2
fi
