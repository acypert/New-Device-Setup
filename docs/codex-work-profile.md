# Codex Work Profile

The default setup stays personal-neutral. The work profile is opt-in, installs
LiteLLM routing into `~/.codex/config.toml` as a managed block, and installs the
full repo-managed Codex guidance into `~/.codex/AGENTS.md`.

## Install

Set the non-secret LiteLLM endpoint and model alias for the work profile:

```bash
export CODEX_WORK_LITELLM_BASE_URL="https://YOUR-LITELLM-HOST/v1"
export CODEX_WORK_LITELLM_MODEL="YOUR-LITELLM-MODEL-ALIAS"
export CODEX_WORK_LITELLM_ENV_KEY="LITELLM_API_KEY"
./scripts/codex-profile.sh work
```

The script adds:

- `[model_providers.litellm_work]`
- `[profiles.work]`
- the full work `~/.codex/AGENTS.md`, including `Additional Instructions`

It also sets the same work provider and model at the top level of
`~/.codex/config.toml`, so plain `codex` uses the work setup. When those
top-level work defaults are installed, stale top-level model context window
settings from a previous default model are removed instead of being silently
applied to the work provider.

It does not store an API key.

## Authenticate

Preferred work setup: put the LiteLLM key in the environment before launching
Codex.

```bash
read -rsp "LiteLLM API key: " LITELLM_API_KEY
printf "\n"
export LITELLM_API_KEY
codex
```

For a persistent machine-specific setup, put the export in a private shell file
that is not committed, then source it from `~/.zshrc`.

If your LiteLLM setup requires Codex's credential store instead of an env var,
you can also run:

```bash
printf "%s" "$LITELLM_API_KEY" | codex login --with-api-key
codex login status
```

## Use

Start Codex with the work defaults:

```bash
codex
```

You can still address the named work profile explicitly:

```bash
codex --profile work
```

To preview the TOML block without writing it:

```bash
./scripts/codex-profile.sh work --print
```

If you ever need to install only the named profile without changing what plain
`codex` does:

```bash
./scripts/codex-profile.sh work --profile-only
```

Codex global guidance is `CODEX_HOME` scoped, not named-profile scoped, so the
work profile script still installs the full `~/.codex/AGENTS.md` guidance.
