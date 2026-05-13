#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/node.sh"

activate_node_runtime

check_command() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    printf "ok   %s -> %s\n" "$name" "$(command -v "$name")"
  else
    printf "miss %s\n" "$name"
  fi
}

check_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    printf "ok   %s\n" "$path"
  else
    printf "miss %s\n" "$path"
  fi
}

check_command brew
check_command git
check_command gh
check_command fnm
check_command npm
check_command npx
check_command codex
check_command omx
check_command http
check_command bat
check_command pyenv
check_command rustc
check_command cargo
check_command tmux
check_command code

check_path "$HOME/.oh-my-zsh"
check_path "$HOME/.codex/config.toml"
check_path "$HOME/.codex/memories"
check_path "$HOME/Library/Application Support/iTerm2/DynamicProfiles/ac-profiles.json"

printf "\nManual checks still required:\n"
printf "%s\n" "- gh auth login"
printf "%s\n" "- codex login, or run codex and complete the browser sign-in"
printf "%s\n" "- iTerm hotkey window behavior if dynamic profiles did not apply it automatically"
