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

check_codex_feature_not_true() {
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
    printf "miss %s [features].%s should not be true for skills-only OMX\n" "$config" "$feature"
  else
    printf "ok   %s [features].%s is not true\n" "$config" "$feature"
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

check_omx_plugin_config() {
  local config="$HOME/.codex/config.toml"

  if [[ -f "$config" ]] && awk '
    /^\[plugins\."oh-my-codex@oh-my-codex-local"\][[:space:]]*$/ {
      in_plugin = 1
      next
    }
    /^\[/ {
      in_plugin = 0
    }
    in_plugin {
      line = $0
      sub(/[[:space:]]*#.*/, "", line)
      if (line ~ /^[[:space:]]*enabled[[:space:]]*=[[:space:]]*true[[:space:]]*$/) {
        found = 1
      }
    }
    END {
      exit found ? 0 : 1
    }
  ' "$config"; then
    printf "ok   oh-my-codex plugin enabled in %s\n" "$config"
  else
    printf "miss oh-my-codex plugin enabled in %s\n" "$config"
  fi
}

check_no_config_developer_instructions() {
  local config="$HOME/.codex/config.toml"

  if [[ -f "$config" ]] && grep -q 'developer_instructions[[:space:]]*=' "$config"; then
    printf "miss %s should not contain developer_instructions\n" "$config"
  else
    printf "ok   no developer_instructions in %s\n" "$config"
  fi
}

check_codex_agents_md() {
  local agents_path="$HOME/.codex/AGENTS.md"
  local config="$HOME/.codex/config.toml"
  local work_default_marker="# BEGIN New-Device-Setup Codex default: work"

  if [[ ! -f "$agents_path" ]]; then
    printf "miss %s\n" "$agents_path"
    return
  fi

  printf "ok   %s\n" "$agents_path"

  if grep -q '<!-- omx:generated:agents-md -->' "$agents_path"; then
    printf "miss generated OMX AGENTS.md remains at %s\n" "$agents_path"
  else
    printf "ok   no generated OMX AGENTS.md\n"
  fi

  if [[ -f "$config" ]] && grep -q "$work_default_marker" "$config"; then
    if grep -q '^## Additional Instructions$' "$agents_path"; then
      printf "ok   work AGENTS.md includes Additional Instructions\n"
    else
      printf "miss work AGENTS.md should include Additional Instructions\n"
    fi
  else
    if grep -q '^## Additional Instructions$' "$agents_path"; then
      printf "miss non-work AGENTS.md should not include Additional Instructions\n"
    else
      printf "ok   non-work AGENTS.md omits Additional Instructions\n"
    fi
  fi
}

check_no_omx_native_hooks() {
  local hooks_path="$HOME/.codex/hooks.json"

  if [[ -f "$hooks_path" ]] && grep -q 'oh-my-codex.*/codex-native-hook\.js' "$hooks_path"; then
    printf "miss OMX native hook commands remain in %s\n" "$hooks_path"
  else
    printf "ok   no OMX native hook commands\n"
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

check_codex_feature memories
check_codex_feature_not_true hooks
check_codex_feature_not_true goals
check_no_config_developer_instructions
check_codex_agents_md
check_omx_plugin_cache
check_omx_plugin_config
check_no_omx_native_hooks

printf "\nManual checks still required:\n"
printf "%s\n" "- gh auth login"
printf "%s\n" "- codex login, or run codex and complete the browser sign-in"
printf "%s\n" "- iTerm hotkey window behavior if dynamic profiles did not apply it automatically"
printf "%s\n" "- iTerm Input Monitoring and Accessibility permissions if the hotkey only works while iTerm is active"
