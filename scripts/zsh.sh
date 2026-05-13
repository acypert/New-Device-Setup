#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$HOME/.zshrc"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugin() {
  local repo="$1"
  local target="$2"

  if [[ -d "$target/.git" ]]; then
    git -C "$target" pull --ff-only
  else
    git clone "$repo" "$target"
  fi
}

set_zsh_theme() {
  mkdir -p "$HOME/.oh-my-zsh/themes"
  cp "$ROOT_DIR/ac.zsh-theme" "$HOME/.oh-my-zsh/themes/ac.zsh-theme"

  touch "$ZSHRC"
  if grep -q '^ZSH_THEME=' "$ZSHRC"; then
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="ac"/' "$ZSHRC"
  else
    printf '\nZSH_THEME="ac"\n' >> "$ZSHRC"
  fi
}

set_zsh_plugins() {
  local tmp
  tmp="$(mktemp)"

  awk '
    BEGIN { replaced = 0; skipping = 0 }
    skipping {
      if ($0 ~ /\)/) {
        skipping = 0
      }
      next
    }
    /^plugins=\(/ {
      if (!replaced) {
        print "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
        replaced = 1
      }
      if ($0 !~ /\)/) {
        skipping = 1
      }
      next
    }
    { print }
    END {
      if (!replaced) {
        print "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
      }
    }
  ' "$ZSHRC" > "$tmp"

  cp "$ZSHRC" "$ZSHRC.bak"
  mv "$tmp" "$ZSHRC"
}

ensure_block() {
  local marker="$1"
  local content="$2"

  if grep -q "$marker" "$ZSHRC"; then
    return
  fi

  printf '\n%s\n%s\n' "$marker" "$content" >> "$ZSHRC"
}

install_oh_my_zsh
mkdir -p "$ZSH_CUSTOM_DIR/plugins"

install_zsh_plugin \
  "https://github.com/zsh-users/zsh-autosuggestions" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"

install_zsh_plugin \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

set_zsh_theme
set_zsh_plugins

ensure_block "# New-Device-Setup: fnm" 'if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi'

ensure_block "# New-Device-Setup: pyenv" 'if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi'
