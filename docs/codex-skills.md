# Codex Skills

OMX-owned workflows and bundled skills are supplied by Codex plugin discovery in
the current setup. Oh My Codex still needs the npm package, but this repo
refreshes the local plugin cache directly instead of running full OMX setup:

```bash
./scripts/codex.sh
```

That script refreshes the local `oh-my-codex-local` plugin cache and enables
the plugin in `~/.codex/config.toml`. It intentionally removes setup-owned OMX
native hooks from `~/.codex/hooks.json`, removes generated OMX `AGENTS.md`
guidance, and does not enable `features.hooks` or `features.goals`.

The same default setup writes repo-managed global Codex guidance to
`~/.codex/AGENTS.md` without work-only `Additional Instructions`. Running
`./scripts/codex-profile.sh work` installs the full work guidance into that
global AGENTS file.

Legacy `~/.agents/skills` can be archived after confirming current skills are
available under `~/.codex/skills` or from plugin discovery.

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
- `~/.codex/hooks.json`
- `~/.codex/agents/`
- `~/.codex/prompts/`
- `~/.codex/profiles/`
- `~/.codex/memories/`
- `~/AGENTS.md`
