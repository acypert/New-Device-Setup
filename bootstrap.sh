#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  printf "\n==> %s\n" "$*"
}

warn() {
  printf "\nWARN: %s\n" "$*" >&2
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf "This bootstrap is intended for macOS.\n" >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Install Xcode Command Line Tools first, then rerun this script:"
  printf "  xcode-select --install\n" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

log "Installing Homebrew packages"
brew bundle --file "$ROOT_DIR/Brewfile"

log "Configuring zsh"
"$ROOT_DIR/scripts/zsh.sh"

log "Installing iTerm2 dynamic profiles"
"$ROOT_DIR/scripts/iterm2.sh" install

log "Installing Codex and configuring OMX"
"$ROOT_DIR/scripts/codex.sh"

log "Installing non-OMX agent skills"
"$ROOT_DIR/scripts/agent-skills.sh"

log "Verifying setup"
"$ROOT_DIR/scripts/verify.sh"

log "Done. Complete the manual sign-in and iTerm steps in README.md."
