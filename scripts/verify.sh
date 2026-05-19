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

check_codex_feature() {
  local feature="$1"
  local config="$HOME/.codex/config.toml"

  if [[ -f "$config" ]] && awk -v feature="$feature" '
    /^\[features\][[:space:]]*$/ {
      in_features = 1
      next
    }
    /^\[/ {
      in_features = 0
    }
    in_features {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      pattern = "^[[:space:]]*" feature "[[:space:]]*=[[:space:]]*true[[:space:]]*$"
      if (line ~ pattern) {
        found = 1
      }
    }
    END {
      exit found ? 0 : 1
    }
  ' "$config"; then
    printf "ok   %s [features].%s\n" "$config" "$feature"
  else
    printf "miss %s [features].%s\n" "$config" "$feature"
  fi
}

check_omx_plugin_cache() {
  local cache_root="${CODEX_HOME:-$HOME/.codex}/plugins/cache"
  local plugin_manifest

  plugin_manifest="$(find "$cache_root" -path "*/oh-my-codex/*/.codex-plugin/plugin.json" -type f -print -quit 2>/dev/null || true)"
  if [[ -n "$plugin_manifest" ]]; then
    printf "ok   oh-my-codex plugin cache -> %s\n" "$(dirname "$(dirname "$plugin_manifest")")"
  else
    printf "miss oh-my-codex plugin cache\n"
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
check_path "$HOME/.codex/hooks.json"
check_path "$HOME/.codex/memories"
check_path "$HOME/Library/Application Support/iTerm2/DynamicProfiles/ac-profiles.json"

check_codex_feature memories
check_codex_feature hooks
check_codex_feature goals
check_omx_plugin_cache

printf "\nManual checks still required:\n"
printf "%s\n" "- gh auth login"
printf "%s\n" "- codex login, or run codex and complete the browser sign-in"
printf "%s\n" "- iTerm hotkey window behavior if dynamic profiles did not apply it automatically"
printf "%s\n" "- iTerm Input Monitoring and Accessibility permissions if the hotkey only works while iTerm is active"
