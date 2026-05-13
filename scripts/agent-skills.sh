#!/usr/bin/env bash
set -euo pipefail

AGENT_NAME="${SKILLS_AGENT:-codex}"

install_skill() {
  local package="$1"
  local skill="$2"
  shift 2

  printf "Installing %s from %s for %s\n" "$skill" "$package" "$AGENT_NAME"
  npx --yes skills add "$package" -g -a "$AGENT_NAME" --skill "$skill" "$@" -y
}

if ! command -v npx >/dev/null 2>&1; then
  printf "npx is required before installing agent skills. Run scripts/codex.sh first.\n" >&2
  exit 1
fi

install_skill "vercel-labs/agent-browser" "agent-browser"
install_skill "vercel-labs/skills" "find-skills"
install_skill "anthropics/skills" "frontend-design"
install_skill "daymade/claude-code-skills" "qa-expert" "--full-depth"
install_skill "thebushidocollective/han" "solid-principles" "--full-depth"
install_skill "obra/superpowers" "systematic-debugging"
install_skill "mattpocock/skills" "tdd" "--full-depth"
install_skill "vercel-labs/agent-skills" "vercel-composition-patterns"
install_skill "vercel-labs/agent-skills" "vercel-react-best-practices"
install_skill "vercel-labs/agent-skills" "web-design-guidelines"
