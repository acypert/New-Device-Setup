#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/node.sh"

enable_codex_memories() {
  local config="$HOME/.codex/config.toml"
  local tmp

  mkdir -p "$HOME/.codex"

  if [[ ! -f "$config" ]]; then
    printf "[features]\nmemories = true\n" > "$config"
    return
  fi

  tmp="$(mktemp)"
  awk '
    BEGIN { in_features = 0; saw_features = 0; set_memories = 0 }
    /^\[features\][[:space:]]*$/ {
      saw_features = 1
      in_features = 1
      print
      next
    }
    /^\[/ {
      if (in_features && !set_memories) {
        print "memories = true"
        set_memories = 1
      }
      in_features = 0
    }
    in_features && /^[[:space:]]*memories[[:space:]]*=/ {
      print "memories = true"
      set_memories = 1
      next
    }
    { print }
    END {
      if (!saw_features) {
        print ""
        print "[features]"
        print "memories = true"
      } else if (in_features && !set_memories) {
        print "memories = true"
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

printf "Installing Oh My Codex\n"
npm install -g oh-my-codex

printf "Enabling Codex memories\n"
enable_codex_memories

if command -v omx >/dev/null 2>&1; then
  printf "Running Oh My Codex setup\n"
  (
    cd "$HOME"
    omx setup --force --verbose --scope user
    omx doctor
  )
else
  printf "omx command not found. Install Oh My Codex, then run:\n" >&2
  printf "  cd ~\n" >&2
  printf "  omx setup --force --verbose --scope user\n" >&2
  printf "  omx doctor\n" >&2
fi
