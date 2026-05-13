#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
output="${1:-$PWD/codex-personal-backup-$timestamp.tgz}"

paths=()

add_if_exists() {
  local path="$1"
  if [[ -e "$HOME/$path" ]]; then
    paths+=("$path")
  fi
}

add_if_exists ".codex/AGENTS.md"
add_if_exists ".codex/config.toml"
add_if_exists ".codex/agents"
add_if_exists ".codex/prompts"
add_if_exists ".codex/memories"
add_if_exists "AGENTS.md"

if [[ ${#paths[@]} -eq 0 ]]; then
  printf "No Codex personal files found to back up.\n" >&2
  exit 1
fi

printf "Creating %s\n" "$output"
tar -czf "$output" -C "$HOME" "${paths[@]}"

printf "Review this archive before storing or sharing it. It may contain private preferences or memory context.\n"
