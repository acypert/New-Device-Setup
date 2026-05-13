# Codex Work Profile

The default setup stays personal-neutral. The work profile is opt-in and is
installed into `~/.codex/config.toml` as a managed block.

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
- work-only `developer_instructions`

It does not store an API key.

## Authenticate

Preferred work setup: put the LiteLLM key in the environment before launching
Codex.

```bash
read -rsp "LiteLLM API key: " LITELLM_API_KEY
printf "\n"
export LITELLM_API_KEY
codex --profile work
```

For a persistent machine-specific setup, put the export in a private shell file
that is not committed, then source it from `~/.zshrc`.

If your LiteLLM setup requires Codex's credential store instead of an env var,
you can also run:

```bash
printf "%s" "$LITELLM_API_KEY" | codex --profile work login --with-api-key
codex --profile work login status
```

## Use

Start personal/default Codex:

```bash
codex
```

Start work Codex:

```bash
codex --profile work
```

To preview the TOML block without writing it:

```bash
./scripts/codex-profile.sh work --print
```
