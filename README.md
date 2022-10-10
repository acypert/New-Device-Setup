# New-Device-Setup: Mac os

## Install xcode command line tools
```bash
xcode-select --install
```

## Install Homebrew
[Homebrew](https://brew.sh/)

## iTerm2
```bash
brew install --cask iterm2
```
[Homebrew iTerm2](https://formulae.brew.sh/cask/iterm2)
[iTerm2 homepage](https://iterm2.com/features.html)

### Theme: One Dark
Import into iTerm

[One Dark](./OneDark.itermcolors)

### Hotkey Window
1. Open Preferences (CMD+,)
1. General > Startup > Window restoration policy > Only Restore Hotkey Window
1. Profiles > Window > Style: Full-Width Bottom of Screen, Screen: Screen with Cursor, Space: All Spaces
1. Profiles > Keys > Check "A hotkey opens a dedicated window with this profile."
1. Click Configure Hotkey Window > Set Hotkey (CMD+`) > Animate showing and hiding, Floating window
1. On Dock icon click: Show this Hotkey Window if no other window is open

### Open new tabs in the same directory
Settings > Profiles > General > Working Directory > Reuse previous session's directory

### cmd/opt + arrow keys
[Natural Text Editing](https://superuser.com/a/1704086)
1. Open Preferences
2. Click "Profile" tab
3. Select a profile in the list on the left (eg "Default")
4. Click "Keys" tab
5. Click "Key Mappings" tab (if it exists)
6. Click the "Presets" dropdown and select "Natural Text Editing"

### Jetbrains Mono font
[JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono
```
iTerm > Preferences > Profiles > Text > Font > JetBrains Mono

### New Window Size
`125 x 30`

iTerm > Preferences > Profiles > Window > Settings for New Windows


## Update/install git
```bash
brew install git
```


## vscode
```bash
brew install --cask visual-studio-code
```


## oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
[oh-my-zsh](https://ohmyz.sh/)

### Theme: ac (derived from afowler)
Add to `~/.oh-my-zsh/themes`

[ac](./ac.zsh-theme)
[more themes if desired](https://github.com/mbadolato/iTerm2-Color-Schemes)

### Plugins
[list of plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
#### zsh-autosuggestions
[github install page](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)

1. Clone the repository into $ZSH_CUSTOM/plugins (by default ~/.oh-my-zsh/custom/plugins)
    ```bash
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```
2. Add the plugin to the list of plugins for Oh My Zsh to load (inside ~/.zshrc):
    ```bash
    plugins=( 
        # other plugins...
        zsh-autosuggestions
    )
    ```
3. Source zsh
    ```bash
    source ~/.zshrc
    ```
    
#### zsh-syntax-highlighting
[GitHub install page](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)

1. Clone the repository in oh-my-zsh's plugins directory:
    ```bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    ```
2. Activate the plugin in ~/.zshrc. Note that zsh-syntax-highlighting needs to be the last one in the list:
    ```bash
    plugins=( [plugins...] zsh-syntax-highlighting)
    ```
3. Source zsh
    ```bash
    source ~/.zshrc
    ```
    
## CLI Tools
### fnm
[install script](https://github.com/Schniz/fnm#using-a-script-macoslinux)
```bash
curl -fsSL https://fnm.vercel.app/install | bash
eval "$(fnm env --use-on-cd)" >> ~/.zshrc
source ~/.zshrc
```

### sdkman!
[install page](https://sdkman.io/install)
```bash
curl -s "https://get.sdkman.io" | bash
source ~/.zshrc
```

### HTTPie
[HTTPie](https://httpie.io/)
```bash
brew install httpie
```

### bat: a `cat` clone with syntax highlighting and Git integration
[bat](https://github.com/sharkdp/bat)
```bash
brew install bat
```
