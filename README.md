# New-Device-Setup

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

### Open new tabs in the same directory
Settings > Profiles > General > Working Directory > Reuse previous session's directory

### Jetbrains Mono font
[JetBrains Mono](https://github.com/JetBrains/JetBrainsMono)

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono
```


## Update/install git
```bash
brew install git
```


## oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
[oh-my-zsh](https://ohmyz.sh/)

### Theme: ac (derived from afowler)
Add to `~/.oh-my-zsh/themes`

[ac](./ac.zsh-theme)
