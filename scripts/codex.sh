#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/node.sh"

ensure_codex_feature_flags() {
  local config="$HOME/.codex/config.toml"
  local tmp

  mkdir -p "$HOME/.codex"

  if [[ ! -f "$config" ]]; then
    printf "[features]\nmemories = true\nhooks = true\ngoals = true\n" > "$config"
    return
  fi

  tmp="$(mktemp)"
  awk '
    BEGIN {
      managed_count = split("memories hooks goals", managed, " ")
      for (i = 1; i <= managed_count; i++) {
        desired[managed[i]] = 1
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

ensure_node_runtime

if ! command -v codex >/dev/null 2>&1; then
  printf "Codex is not installed. Run brew bundle --file Brewfile first.\n" >&2
  exit 1
fi

printf "Installing or updating Oh My Codex\n"
npm install -g oh-my-codex@latest

printf "Enabling Codex runtime feature flags\n"
ensure_codex_feature_flags

if command -v omx >/dev/null 2>&1; then
  printf "Running Oh My Codex setup in plugin mode\n"
  (
    cd "$HOME"
    omx setup --force --verbose --scope user --install-mode plugin --mcp none
    omx doctor
  )
else
  printf "omx command not found. Install Oh My Codex, then run:\n" >&2
  printf "  cd ~\n" >&2
  printf "  omx setup --force --verbose --scope user --install-mode plugin --mcp none\n" >&2
  printf "  omx doctor\n" >&2
fi
