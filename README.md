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
installs Codex and Oh My Codex, enables Codex memories, runs OMX setup, and
installs third-party agent skills with `npx skills`.

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
omx setup --force --verbose --scope user
omx doctor
```

## Packages

Most apps and CLI tools live in `Brewfile`:

- `git`
- `gh`
- `fnm`
- `pyenv`
- `httpie`
- `bat`
- iTerm2
- Rectangle
- Visual Studio Code
- JetBrains Mono

Apply package changes with:

```bash
brew bundle --file Brewfile
```

## Codex And Memories

The setup script installs Codex and Oh My Codex with npm:

```bash
npm install -g @openai/codex oh-my-codex
```

It also enables memories in `~/.codex/config.toml`:

```toml
[features]
memories = true
```

Codex personal state is not committed to this public repo. To move personal
Codex config, native agents, prompts, memories, and the home-level `AGENTS.md`
from the old laptop:

```bash
./scripts/backup-codex.sh
```

Then copy the generated archive to the new laptop and restore it:

```bash
./scripts/restore-codex-backup.sh codex-personal-backup-YYYYMMDD-HHMMSS.tgz
```

Review the archive before storing or sharing it. It may contain private
preferences or memory context. Do not back up `~/.codex/auth.json`, logs,
sessions, or sqlite state by default.

## Codex Skills

Oh My Codex skills are installed by `omx setup`.

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
5. Configure Hotkey Window > Set Hotkey `CMD+\`` > Pin hotkey window, Animate showing and hiding, Floating window.
6. On Dock icon click: Show this Hotkey Window if no other window is open.

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
