#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_CONFIG="$HOME/.codex/config.toml"
PROFILE_NAME="${1:-work}"

usage() {
  printf "Usage: %s work [--print]\n" "$0" >&2
}

if [[ "$PROFILE_NAME" != "work" ]]; then
  usage
  exit 1
fi

MODE="${2:-apply}"
if [[ "$MODE" != "apply" && "$MODE" != "--print" ]]; then
  usage
  exit 1
fi

BASE_URL="${CODEX_WORK_LITELLM_BASE_URL:-https://YOUR-LITELLM-HOST/v1}"
MODEL="${CODEX_WORK_LITELLM_MODEL:-YOUR-LITELLM-MODEL-ALIAS}"
ENV_KEY="${CODEX_WORK_LITELLM_ENV_KEY:-LITELLM_API_KEY}"
SOURCE_INSTRUCTIONS="$ROOT_DIR/profiles/work/codex/developer-instructions.md"
INSTALLED_PROFILE_DIR="$HOME/.codex/profiles/work"
INSTALLED_INSTRUCTIONS="$INSTALLED_PROFILE_DIR/developer-instructions.md"
BEGIN_MARKER="# BEGIN New-Device-Setup Codex profile: work"
END_MARKER="# END New-Device-Setup Codex profile: work"

if [[ ! -f "$SOURCE_INSTRUCTIONS" ]]; then
  printf "Work developer instructions not found: %s\n" "$SOURCE_INSTRUCTIONS" >&2
  exit 1
fi

generate_block() {
  python3 - "$SOURCE_INSTRUCTIONS" "$BASE_URL" "$MODEL" "$ENV_KEY" "$BEGIN_MARKER" "$END_MARKER" <<'PY'
import sys
from pathlib import Path

instructions_path, base_url, model, env_key, begin_marker, end_marker = sys.argv[1:]
instructions = Path(instructions_path).read_text(encoding="utf-8").rstrip() + "\n"

def toml_string(value: str) -> str:
    return '"""' + value.replace("\\", "\\\\").replace('"""', '\\"""') + '"""'

print(begin_marker)
print('[model_providers.litellm_work]')
print('name = "LiteLLM Work"')
print(f'base_url = "{base_url}"')
print('wire_api = "responses"')
print(f'env_key = "{env_key}"')
print(f'env_key_instructions = "Set {env_key} in your shell environment before launching codex --profile work"')
print()
print('[profiles.work]')
print('model_provider = "litellm_work"')
print(f'model = "{model}"')
print('model_reasoning_effort = "xhigh"')
print('personality = "pragmatic"')
print('cli_auth_credentials_store = "auto"')
print('developer_instructions = ' + toml_string(instructions))
print(end_marker)
PY
}

if [[ "$MODE" == "--print" ]]; then
  generate_block
  exit 0
fi

mkdir -p "$HOME/.codex" "$INSTALLED_PROFILE_DIR"
cp "$SOURCE_INSTRUCTIONS" "$INSTALLED_INSTRUCTIONS"
touch "$CODEX_CONFIG"

tmp_config="$(mktemp)"
block_file="$(mktemp)"
trap 'rm -f "$tmp_config" "$block_file"' EXIT

generate_block > "$block_file"

python3 - "$CODEX_CONFIG" "$tmp_config" "$block_file" "$BEGIN_MARKER" "$END_MARKER" <<'PY'
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
tmp_path = Path(sys.argv[2])
block_path = Path(sys.argv[3])
begin_marker = sys.argv[4]
end_marker = sys.argv[5]

config = config_path.read_text(encoding="utf-8")
block = block_path.read_text(encoding="utf-8").rstrip() + "\n"

managed_pattern = re.compile(
    rf"\n?{re.escape(begin_marker)}.*?{re.escape(end_marker)}\n?",
    re.DOTALL,
)
cleaned = managed_pattern.sub("\n", config).rstrip()

for table in ("[profiles.work]", "[model_providers.litellm_work]"):
    if table in cleaned:
        raise SystemExit(
            f"{table} already exists outside the managed work-profile block. "
            "Move or remove it before applying this scaffold."
        )

next_config = (cleaned + "\n\n" + block).lstrip()
tmp_path.write_text(next_config, encoding="utf-8")
PY

python3 - "$tmp_config" <<'PY'
import sys
try:
    import tomllib
except ModuleNotFoundError:
    import tomli as tomllib

with open(sys.argv[1], "rb") as f:
    tomllib.load(f)
PY

backup="$CODEX_CONFIG.bak.$(date +%Y%m%d-%H%M%S)"
cp "$CODEX_CONFIG" "$backup"
mv "$tmp_config" "$CODEX_CONFIG"

printf "Installed Codex work profile into %s\n" "$CODEX_CONFIG"
printf "Backed up previous config to %s\n" "$backup"
printf "Copied work developer instructions to %s\n" "$INSTALLED_INSTRUCTIONS"

if [[ "$BASE_URL" == "https://YOUR-LITELLM-HOST/v1" || "$MODEL" == "YOUR-LITELLM-MODEL-ALIAS" ]]; then
  printf "\nWARN: Work profile still contains placeholder LiteLLM values.\n" >&2
  printf "Set CODEX_WORK_LITELLM_BASE_URL and CODEX_WORK_LITELLM_MODEL, then rerun this script.\n" >&2
fi
