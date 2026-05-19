#!/usr/bin/env bash

archive_omx_agents_md() {
  local agents_path="${1:-$HOME/.codex/AGENTS.md}"
  local archive_path

  [[ -f "$agents_path" ]] || return 0

  if grep -q '<!-- omx:generated:agents-md -->' "$agents_path"; then
    archive_path="$agents_path.omx-disabled.$(date +%Y%m%d-%H%M%S)"
    mv "$agents_path" "$archive_path"
    printf "Archived generated OMX AGENTS.md to %s\n" "$archive_path"
  fi
}

install_codex_agents_md() {
  local source_path="$1"
  local mode="$2"
  local target_path="${3:-$HOME/.codex/AGENTS.md}"
  local tmp
  local backup_path

  if [[ ! -f "$source_path" ]]; then
    printf "Codex AGENTS source not found: %s\n" "$source_path" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$target_path")"
  archive_omx_agents_md "$target_path"

  tmp="$(mktemp)"
  case "$mode" in
    full)
      cp "$source_path" "$tmp"
      ;;
    without-additional)
      python3 - "$source_path" "$tmp" <<'PY'
import sys
from pathlib import Path

source_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])

lines = source_path.read_text(encoding="utf-8").splitlines()
output = []
skip = False

for line in lines:
    if line == "## Additional Instructions":
        skip = True
        continue
    if skip and line.startswith("## "):
        skip = False
    if not skip:
        output.append(line)

target_path.write_text("\n".join(output).rstrip() + "\n", encoding="utf-8")
PY
      ;;
    *)
      printf "Unknown Codex AGENTS install mode: %s\n" "$mode" >&2
      rm -f "$tmp"
      exit 1
      ;;
  esac

  if [[ -f "$target_path" ]] && ! cmp -s "$tmp" "$target_path"; then
    backup_path="$target_path.bak.New-Device-Setup.$(date +%Y%m%d-%H%M%S)"
    cp "$target_path" "$backup_path"
    printf "Backed up existing Codex AGENTS.md to %s\n" "$backup_path"
  fi

  mv "$tmp" "$target_path"
  chmod 644 "$target_path"
  printf "Installed Codex AGENTS.md to %s\n" "$target_path"
}
