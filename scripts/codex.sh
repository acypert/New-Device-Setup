#!/usr/bin/env bash
set -euo pipefail

ensure_node() {
  if command -v npm >/dev/null 2>&1; then
    return
  fi

  if ! command -v fnm >/dev/null 2>&1; then
    printf "npm is not available and fnm is not installed. Run bootstrap.sh or install fnm first.\n" >&2
    exit 1
  fi

  eval "$(fnm env --shell bash)"
  fnm install --lts --use

  local node_version
  node_version="$(fnm current)"
  fnm default "$node_version"
}

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

ensure_node

printf "Installing OpenAI Codex CLI and Oh My Codex\n"
npm install -g @openai/codex oh-my-codex

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
