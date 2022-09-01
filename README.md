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
1. Clone from https://github.com/mbadolato/iTerm2-Color-Schemes
2. Install One Dark
    ```bash
    
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

### Theme: afowler-custom 
Add to `~/.oh-my-zsh/themes
```zsh-theme
if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="blue"; fi

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

PROMPT='AC %{${fg_bold[blue]}%}:: %{$reset_color%}%{${fg[green]}%}%3~ $(git_prompt_info)%{${fg_bold[$CARETCOLOR]}%}»%{${reset_color}%} '

RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
```
