# Dotfiles Nix Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace fragile Oh My Zsh / eza / binary-download installs with Determinate Systems Nix for reproducible tool management, and rewrite `.zshrc` as pure zsh.

**Architecture:** A new `flake.nix` declares all developer tools (fzf, lazygit, ripgrep, fd, neovim, kubectl). `install.sh` installs Nix via Determinate Systems, then runs `nix profile install .#default`. `.zshrc` is rewritten without Oh My Zsh — using zsh builtins for completions, `vcs_info` for the prompt, and `eval "$(fzf --zsh)"` for fzf integration.

**Tech Stack:** Bash (install.sh), Zsh (shell config), Nix flakes (Determinate Systems)

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `flake.nix` | **Create** | Declares all Nix-managed tools for `x86_64-linux` and `aarch64-darwin` |
| `.tool-versions` | **Modify** | Remove `kubectl` and `neovim` (moved to Nix) |
| `install.sh` | **Modify** | Remove OMZ/eza/fzf/chsh blocks; add Nix installer + profile install; remove asdf neovim/kubectl plugins |
| `.zshrc` | **Rewrite** | Pure zsh: no OMZ, Nix profile sourcing, fzf integration, vcs_info prompt, plain ls aliases |

---

### Task 1: Create flake.nix

**Files:**
- Create: `flake.nix`

- [ ] **Step 1: Create flake.nix**

```nix
{
  description = "Coder dotfiles tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = with pkgs; [
            fzf
            lazygit
            ripgrep
            fd
            neovim
            kubectl
          ];
        };
      });
    };
}
```

- [ ] **Step 2: Generate the lock file and verify the flake**

```bash
nix flake update
nix flake show
```

Expected output from `nix flake show`: shows `packages.x86_64-linux.default` and `packages.aarch64-darwin.default`

This creates `flake.lock`, which pins exact nixpkgs revisions for reproducibility. If Nix is not installed locally, run `nix flake update` on the Coder workspace after install.sh runs, then commit the lock file.

- [ ] **Step 3: Commit flake.nix and flake.lock**

```bash
git add flake.nix flake.lock
git commit -m "feat: add flake.nix for Nix-managed tools"
```

---

### Task 2: Update .tool-versions

**Files:**
- Modify: `.tool-versions`

- [ ] **Step 1: Remove kubectl and neovim entries**

Current `.tool-versions`:
```
kubectl 1.23.6
ruby 3.3.2
nodejs 22.8.0
neovim stable
awscli 2.25.5
python 3.7.17
```

Updated `.tool-versions`:
```
ruby 3.3.2
nodejs 22.8.0
awscli 2.25.5
python 3.7.17
```

- [ ] **Step 2: Verify**

```bash
cat .tool-versions
```

Expected: 4 lines, no `kubectl` or `neovim`.

- [ ] **Step 3: Commit**

```bash
git add .tool-versions
git commit -m "chore: remove kubectl and neovim from .tool-versions (managed by Nix)"
```

---

### Task 3: Update install.sh

**Files:**
- Modify: `install.sh`

This task removes the OMZ, eza, fzf clone, and chsh blocks, removes the asdf neovim/kubectl plugin adds, removes the macOS brew tool install line, and adds the Determinate Nix install + profile install.

- [ ] **Step 1: Remove the chsh block (lines 143–148)**

Remove this entire block:
```bash
# Set zsh as default shell
ZSH_PATH=$(command -v zsh)
if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting Zsh as default shell..."
  sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null || chsh -s "$ZSH_PATH"
  echo "✅ Default shell set to Zsh"
fi
```

- [ ] **Step 2: Remove the Oh My Zsh install block (lines 151–156)**

Remove this entire block:
```bash
# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
  echo "✅ Oh My Zsh installed"
fi
```

- [ ] **Step 3: Remove the fzf git clone install block (lines 159–164)**

Remove this entire block:
```bash
# Install FZF
if ! command -v fzf &> /dev/null; then
  echo "📦 Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
  echo "✅ FZF installed"
fi
```

- [ ] **Step 4: Remove the Linux eza install block (lines 82–89)**

Remove this entire block:
```bash
    # eza — direct binary, avoids GPG+apt repo setup (~2 min saved)
    if ! command -v eza &> /dev/null; then
      echo "📦 Installing eza..."
      curl -fsSL \
        "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" \
        | tar -xz -C ~/.local/bin eza
      chmod +x ~/.local/bin/eza
      echo "✅ eza installed"
    fi
```

- [ ] **Step 5: Remove the Linux ripgrep+fd apt block (lines 71–79)**

Remove this entire block (now handled by Nix):
```bash
    # cloud-init already ran apt-get update, skip it if packages are present
    if ! command -v rg &> /dev/null || ! command -v fd &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y --no-install-recommends ripgrep fd-find
    fi

    # fd symlink
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
      sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
```

- [ ] **Step 6: Remove asdf neovim and kubectl plugin adds from Linux section (lines 116–118)**

Remove these two lines:
```bash
    asdf plugin add neovim 2>/dev/null || true
    asdf plugin add kubectl 2>/dev/null || true
```

- [ ] **Step 7: Remove asdf neovim plugin add from macOS section (line 137)**

Remove this line:
```bash
    asdf plugin add neovim 2>/dev/null || true
```

- [ ] **Step 8: Remove macOS brew tool install line**

Remove this block:
```bash
    if command -v brew &> /dev/null; then
      brew install ripgrep fd eza lazygit
    else
      echo "⚠️  Homebrew not found. Please install brew first."
    fi
```

- [ ] **Step 9: Add Nix install + source + profile install**

After the git aliases block (after `git config --global rerere.enabled true`) and before the `case "${unameOut}"` line, add:

```bash
# Install Nix via Determinate Systems (idempotent — skips if already installed)
if ! command -v nix &> /dev/null; then
  echo "📦 Installing Nix (Determinate Systems)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  echo "✅ Nix installed"
fi

# Source Nix daemon profile so `nix` is available in this shell session
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Install tools from flake (run from dotfiles repo root)
echo "📦 Installing tools via Nix..."
nix profile install .#default
echo "✅ Nix tools installed"
```

- [ ] **Step 10: Verify the final install.sh looks correct**

```bash
cat install.sh
```

Confirm the file:
- Has no mention of `oh-my-zsh`, `eza`, `fzf clone`, or `chsh`
- Has the Nix install block before the `case` statement
- Linux section no longer has `ripgrep`, `fd-find`, or `eza` installs
- Neither section has `asdf plugin add neovim` or `asdf plugin add kubectl`

- [ ] **Step 11: Commit**

```bash
git add install.sh
git commit -m "feat: replace binary downloads with Determinate Nix, remove OMZ/eza/chsh"
```

---

### Task 4: Rewrite .zshrc

**Files:**
- Modify: `.zshrc`

Replace the entire file content. The new file keeps all existing functions and aliases but removes all Oh My Zsh references, replaces eza aliases with plain ls, adds Nix profile sourcing, adds zsh builtins for completions, adds a vcs_info prompt, and wires up fzf via `eval "$(fzf --zsh)"`.

- [ ] **Step 1: Replace .zshrc with the following content**

```zsh
# Nix profile
[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# User configuration
export EDITOR='nvim'
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$PATH:/opt/homebrew/bin/

# Platform detection
platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

# Homebrew setup (macOS)
if command -v brew >/dev/null 2>&1; then
  [ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
fi

# Set PATH for local bin
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# asdf setup
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# macOS specific paths
if [[ "$platform" == "darwin" ]]; then
  export PGDATA="/Users/ryanmilstead/Library/Application Support/Postgres/var-16"
  export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
  export LDFLAGS="-L/opt/homebrew/lib"
  export CPPFLAGS="-I/opt/homebrew/include"

  if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)
    if [ -d "$BREW_PREFIX/opt/openjdk/bin" ]; then
      export PATH="$BREW_PREFIX/opt/openjdk/bin:$PATH"
      export JAVA_HOME=$(/usr/libexec/java_home)
    fi
  fi
fi

# RVM (must be last PATH export)
export PATH=$PATH:$HOME/.rvm/bin

# zsh completions
autoload -Uz compinit && compinit

# Prompt with git branch via vcs_info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f%F{green}${vcs_info_msg_0_}%f %# '

# fzf key bindings and completion
eval "$(fzf --zsh)"

# coder-tools plugin
[ -f "$HOME/.config/zsh/custom/plugins/coder-tools/coder-tools.plugin.zsh" ] && \
  source "$HOME/.config/zsh/custom/plugins/coder-tools/coder-tools.plugin.zsh"

# FZF functions
f() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf)}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}

fm() f "$@" --max-depth 1

fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

fkill() {
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi
}

fo() (
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
)

fgb() (
  local branch
  branch=$(git branch | fzf -m | awk '{print $1}')
  git switch $branch
)

fgd() {
  preview="git diff $@ --color=always -- {-1}"
  git diff $@ --name-only | fzf -m --ansi --preview $preview
}

fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}

gch() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  local branch
  branch=$(fzf-git-branch)
  if [[ "$branch" = "" ]]; then
      echo "No branch selected."
      return
  fi

  if [[ "$branch" = 'remotes/'* ]]; then
      git checkout --track $branch
  else
      git checkout $branch;
  fi
}

# Aliases - Process management
alias psa="ps aux"
alias psg="ps aux | ag "
alias psr='ps aux | ag ruby'

# Aliases - Navigation
alias cdb='cd -'
alias cls='clear;ls'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# Aliases - ls
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias reload='source ~/.zshrc'

# Aliases - macOS Finder
if [[ "$platform" == "darwin" ]]; then
  alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
  alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
  alias brewu='brew update && brew upgrade && brew cleanup && brew doctor'
  alias bup="brew upgrade && brew update"
fi

# Aliases - Shell config
alias ze="$EDITOR ~/.zshrc"
alias zr="source ~/.zshrc"

# Aliases - Search
alias as="alias | ag"

# Aliases - Git
alias gs='git status'
alias gj='git jump'
alias gfc='git clone'
alias gpr='git request-pull'
alias gstsh='git stash'
alias gst=gs
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcam='git commit -a -m'
alias gcas='git commit -a -s'
alias gcasm='git commit -a -s -m'
alias gcsm='git commit -s -m'
alias ga='git add -A'
alias gd=fgd
alias gpl='git pull --rebase --autostash'
alias gps='git push'
alias gpf='git push --force-with-lease'
alias gpsh='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gnb='git nb'
alias grsh='git reset --hard'
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias grbm='git pull origin staging --rebase --autostash'
alias gcm='git checkout staging'
alias cl='clear'
alias lg='lazygit'

# Aliases - Ruby
alias be='bundle exec'
alias bi='bundle install'
alias c='rails c'
alias rs='be rails s'

setopt no_share_history
unsetopt share_history
```

- [ ] **Step 2: Verify no OMZ references remain**

```bash
grep -n "oh-my-zsh\|ZSH_THEME\|ZSH_CUSTOM\|source \$ZSH\|eza" .zshrc
```

Expected: no output

- [ ] **Step 3: Verify fzf and coder-tools are referenced**

```bash
grep -n "fzf --zsh\|coder-tools" .zshrc
```

Expected: two matches — the `eval "$(fzf --zsh)"` line and the coder-tools source line

- [ ] **Step 4: Commit**

```bash
git add .zshrc
git commit -m "refactor: rewrite .zshrc as pure zsh, drop OMZ/eza, add Nix + fzf --zsh"
```
