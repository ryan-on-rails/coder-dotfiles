# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="bira"

# Custom folder for Oh My Zsh
export ZSH_CUSTOM="$HOME/.config/zsh/custom"

# Plugins
plugins=(git fzf coder-tools)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'
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

# Aliases - Better ls with eza
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='eza -la --icons --no-user --group-directories-first  --time-style long-iso'
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
