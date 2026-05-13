# Codex Skills

OMX-owned skills are installed by the Oh My Codex setup flow:

```bash
omx setup --force --verbose --scope user
```

Third-party agent skills should be installed with the `skills` CLI through `npx`.
The setup script runs the same commands from `scripts/agent-skills.sh`.

```bash
npx --yes skills add vercel-labs/agent-browser -g -a codex --skill agent-browser -y
npx --yes skills add vercel-labs/skills -g -a codex --skill find-skills -y
npx --yes skills add anthropics/skills -g -a codex --skill frontend-design -y
npx --yes skills add daymade/claude-code-skills -g -a codex --skill qa-expert --full-depth -y
npx --yes skills add thebushidocollective/han -g -a codex --skill solid-principles --full-depth -y
npx --yes skills add obra/superpowers -g -a codex --skill systematic-debugging -y
npx --yes skills add mattpocock/skills -g -a codex --skill tdd --full-depth -y
npx --yes skills add vercel-labs/agent-skills -g -a codex --skill vercel-composition-patterns -y
npx --yes skills add vercel-labs/agent-skills -g -a codex --skill vercel-react-best-practices -y
npx --yes skills add vercel-labs/agent-skills -g -a codex --skill web-design-guidelines -y
```

Back up personal Codex customizations separately. Do not put these in this
public repo without reviewing them first:

- `~/.codex/AGENTS.md`
- `~/.codex/config.toml`
- `~/.codex/agents/`
- `~/.codex/prompts/`
- `~/.codex/memories/`
- `~/AGENTS.md`
