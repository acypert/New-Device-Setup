# New Device Setup: macOS

Bootstrap a new Mac with the tools, shell setup, Codex setup, Oh My Codex setup,
and agent skills used on this laptop.

## Quick Start

Install Xcode Command Line Tools first:

```bash
xcode-select --install
```

Clone this repo and run the bootstrap:

```bash
git clone https://github.com/acypert/New-Device-Setup.git
cd New-Device-Setup
./bootstrap.sh
```

The script installs Homebrew if needed, runs `brew bundle`, configures zsh,
installs Codex through Homebrew, installs or updates Oh My Codex through npm,
enables the Codex runtime feature flags this setup depends on, runs plugin-mode
OMX setup, and installs third-party agent skills with `npx skills`.

## Manual Steps

Some steps are intentionally left manual because they require auth, secrets, or
GUI-specific choices.

```bash
gh auth login
codex login
```

If OMX setup needs to be rerun:

```bash
cd ~
omx setup --force --verbose --scope user --install-mode plugin --mcp none
omx doctor
```

## Rerunning

It is safe to rerun `./bootstrap.sh`. The setup is intended to be idempotent:
Homebrew skips installed packages, zsh plugins update existing clones, iTerm
dynamic profiles are overwritten from the checked-in copy, Codex runtime flags
stay enabled, OMX refreshes plugin-mode hooks and plugin discovery, and
third-party skills are reinstalled through `npx skills`.

If the first run stopped during agent skill installation, rerun the full
bootstrap or run:

```bash
./scripts/agent-skills.sh
```

## Packages

Most apps and CLI tools live in `Brewfile`:

- `git`
- `gh`
- `fnm`
- `pyenv`
- `rust`
- `tmux`
- `httpie`
- `bat`
- Codex
- iTerm2
- Rectangle
- Visual Studio Code
- JetBrains Mono

Apply package changes with:

```bash
brew bundle --file Brewfile
```

## Codex And OMX

The setup script installs Codex with Homebrew:

```bash
brew install --cask codex
```

Oh My Codex is installed and updated with npm:

```bash
npm install -g oh-my-codex@latest
```

It also enables the Codex feature flags required by this setup in
`~/.codex/config.toml`:

```toml
[features]
memories = true
hooks = true
goals = true
```

OMX setup runs in Codex plugin delivery mode:

```bash
omx setup --force --verbose --scope user --install-mode plugin --mcp none
```

Plugin mode uses Codex plugin discovery for bundled OMX workflows and skills,
keeps runtime hooks in `~/.codex/hooks.json`, and leaves first-party OMX MCP
compatibility disabled unless it is explicitly requested.

Codex personal state is not committed to this public repo. To move personal
Codex config, hook registrations, profile instructions, native agents, prompts,
memories, and the home-level `AGENTS.md` from the old laptop:

```bash
./scripts/backup-codex.sh
```

Then copy the generated archive to the new laptop and restore it:

```bash
./scripts/restore-codex-backup.sh codex-personal-backup-YYYYMMDD-HHMMSS.tgz
```

Review the archive before storing or sharing it. It may contain private
preferences or memory context. Do not back up `~/.codex/auth.json`, logs,
sessions, sqlite state, or generated plugin caches by default.

## Codex Profiles

This repo supports a personal/default Codex setup and an optional work profile.
The default bootstrap does not apply work-only API routing or work-specific
developer instructions.

To install the work profile:

```bash
export CODEX_WORK_LITELLM_BASE_URL="https://YOUR-LITELLM-HOST/v1"
export CODEX_WORK_LITELLM_MODEL="YOUR-LITELLM-MODEL-ALIAS"
./scripts/codex-profile.sh work
```

Then launch work sessions normally:

```bash
codex
```

See [`docs/codex-work-profile.md`](docs/codex-work-profile.md) for the LiteLLM
API-key manual steps and profile details.

## Codex Skills

Oh My Codex workflows and bundled skills are supplied by the Codex plugin that
`omx setup --install-mode plugin` registers and refreshes. Setup still owns the
native runtime hooks and Codex runtime feature flags.

Third-party skills are installed through `npx skills`, not copied manually by
default:

```bash
./scripts/agent-skills.sh
```

The current skill manifest lives in [`docs/codex-skills.md`](docs/codex-skills.md).

## zsh

The setup script installs Oh My Zsh, copies [`ac.zsh-theme`](ac.zsh-theme) into
`~/.oh-my-zsh/themes`, sets `ZSH_THEME="ac"`, and installs:

- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

It also adds shell initialization for `fnm` and `pyenv`.

## iTerm2

The setup script installs dynamic profiles from
[`iterm2/DynamicProfiles`](iterm2/DynamicProfiles), including the current
profile keyboard shortcuts.

To refresh the checked-in profiles after changing iTerm profile settings:

```bash
./scripts/iterm2.sh export
```

To install the checked-in profiles manually:

```bash
./scripts/iterm2.sh install
```

[`OneDark.itermcolors`](OneDark.itermcolors) is kept for manual import if needed,
but the checked-in dynamic profiles also include the current profile color
settings.

Hotkey window:

1. Open Preferences with `CMD+,`.
2. General > Startup > Window restoration policy > Only Restore Hotkey Window.
3. Profiles > Window > Style: Full-Width Bottom of Screen, Screen: Screen with Cursor, Space: All Spaces.
4. Profiles > Keys > Check "A hotkey opens a dedicated window with this profile."
5. Configure Hotkey Window > Set Hotkey to double-tap Option > Pin hotkey window, Animate showing and hiding, Floating window.
6. On Dock icon click: Show this Hotkey Window if no other window is open.

If the Option double-tap works only while iTerm2 is already active, grant
`/Applications/iTerm.app` permission in System Settings > Privacy & Security >
Input Monitoring and Accessibility, then quit and reopen iTerm2. The dedicated
hotkey window needs global keyboard event access to trigger while another app is
frontmost.

Open new tabs in the same directory:

```text
Settings > Profiles > General > Working Directory > Reuse previous session's directory
```

Natural Text Editing:

1. Preferences > Profiles.
2. Select the profile.
3. Keys > Key Mappings.
4. Presets > Natural Text Editing.

Font:

```text
iTerm > Preferences > Profiles > Text > Font > JetBrains Mono
```

New window size:

```text
125 x 30
```

## Verify

Run:

```bash
./scripts/verify.sh
```
