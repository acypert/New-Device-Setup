ensure_node_runtime() {
  if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env --shell bash)"
  fi

  if command -v npm >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
    return
  fi

  if ! command -v fnm >/dev/null 2>&1; then
    printf "npm and npx are required, but fnm is not available to install Node.\n" >&2
    printf "Run brew bundle --file Brewfile first, then rerun this script.\n" >&2
    exit 1
  fi

  fnm install --lts --use

  local node_version
  node_version="$(fnm current)"
  if [[ -n "$node_version" && "$node_version" != "none" ]]; then
    fnm default "$node_version"
  fi

  if ! command -v npm >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
    printf "Node was installed, but npm or npx is still unavailable in PATH.\n" >&2
    printf "Open a new terminal or run: eval \"$(fnm env --shell zsh)\"\n" >&2
    exit 1
  fi
}
