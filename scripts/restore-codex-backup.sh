#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf "Usage: %s <codex-personal-backup.tgz>\n" "$0" >&2
  exit 1
fi

archive="$1"

if [[ ! -f "$archive" ]]; then
  printf "Backup archive not found: %s\n" "$archive" >&2
  exit 1
fi

mkdir -p "$HOME/.codex"
tar -xzf "$archive" -C "$HOME"

printf "Restored Codex personal files from %s\n" "$archive"
