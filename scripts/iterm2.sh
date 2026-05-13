#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DYNAMIC_PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
SOURCE_PROFILE_DIR="$ROOT_DIR/iterm2/DynamicProfiles"
PROFILE_FILE="$SOURCE_PROFILE_DIR/ac-profiles.json"
ITERM_PREFS="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

install_profiles() {
  if [[ ! -d "$SOURCE_PROFILE_DIR" ]]; then
    printf "No iTerm2 dynamic profiles found at %s\n" "$SOURCE_PROFILE_DIR" >&2
    exit 1
  fi

  mkdir -p "$DYNAMIC_PROFILE_DIR"
  cp "$SOURCE_PROFILE_DIR"/*.json "$DYNAMIC_PROFILE_DIR/"
  printf "Installed iTerm2 dynamic profiles to %s\n" "$DYNAMIC_PROFILE_DIR"
}

export_profiles() {
  if [[ ! -f "$ITERM_PREFS" ]]; then
    printf "iTerm2 preferences not found at %s\n" "$ITERM_PREFS" >&2
    exit 1
  fi

  mkdir -p "$SOURCE_PROFILE_DIR"

  python3 - "$ITERM_PREFS" "$PROFILE_FILE" <<'PY'
import json
import plistlib
import sys
from pathlib import Path

prefs_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

with prefs_path.open("rb") as prefs_file:
    prefs = plistlib.load(prefs_file)

profiles = prefs.get("New Bookmarks", [])
if not profiles:
    raise SystemExit("No iTerm2 profiles found in preferences")

document = {
    "Profiles": profiles,
}

with output_path.open("w", encoding="utf-8") as output_file:
    json.dump(document, output_file, indent=2, sort_keys=True)
    output_file.write("\n")

for profile in profiles:
    name = profile.get("Name", "<unnamed>")
    keys = len(profile.get("Keyboard Map", {}))
    print(f"Exported profile {name} with {keys} keyboard mappings")
PY
}

case "${1:-install}" in
  install)
    install_profiles
    ;;
  export)
    export_profiles
    ;;
  *)
    printf "Usage: %s [install|export]\n" "$0" >&2
    exit 1
    ;;
esac
