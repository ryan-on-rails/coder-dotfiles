# Move next only if `homebrew` is installed
if command -v brew >/dev/null 2>&1; then
  # Load rupa's z if installed
  [ -f $(brew --prefix)/etc/profile.d/z.sh ] && source $(brew --prefix)/etc/profile.d/z.sh
fi

# Get operating system
platform='unknown'
unamestr=$(uname)
if [[ $unamestr == 'Linux' ]]; then
  platform='linux'
elif [[ $unamestr == 'Darwin' ]]; then
  platform='darwin'
fi

export EDITOR='vim'
export PATH=$HOME/bin:/usr/local/bin:$PATH:
export PATH=$PATH:/opt/homebrew/bin/
export PGDATA="/Users/ryanmilstead/Library/Application Support/Postgres/var-16"
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

# set NPM tokem

# must ensure this is the last exported PATH env in the entire file
export PATH=$PATH:$HOME/.rvm/bin
# Use fd and fzf to get the args to a command.
# Works only with zsh
# Examples:
# f mv # To move files. You can write the destination after selecting the files.
# f 'echo Selected:'
# f 'echo Selected music:' --extention mp3
# fm rm # To rm files in current directory
f() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf)}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}

# Like f, but not recursive.
fm() f "$@" --max-depth 1

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
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

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
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

# FZF pretty git diff
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

  # If branch name starts with 'remotes/' then it is a remote branch. By
  # using --track and a remote branch name, it is the same as:
  # git checkout -b branchName --track origin/branchName
  if [[ "$branch" = 'remotes/'* ]]; then
      git checkout --track $branch
  else
      git checkout $branch;
  fi
}

# PS
alias psa="ps aux"
alias psg="ps aux | ag "
alias psr='ps aux | ag ruby'

# Moving around
alias cdb='cd -'
alias cls='clear;ls'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --no-user --group-directories-first  --time-style long-iso'
alias la='eza -la --icons --no-user --group-directories-first  --time-style long-iso'
alias reload='source ~/.zshrc'

alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

alias brewu='brew update && brew upgrade && brew cleanup && brew doctor'
alias bup="brew upgrade && brew update"

# zsh profile editing
alias ze="$EDITOR ~/.zshrc"
alias zr="source ~/.zshrc"

# *********************
# Rebase workflow
alias rboc='git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop -c /Users/ryanmilstead/Healthie/web/.gpshcop.yml --force-exclusion'
alias rboca=rboc --auto-correct
alias as="alias | ag"
alias gs='git status'
alias gj='git jump'
alias gfc='git clone'
alias gpr='git request-pull'
alias gstsh='git stash'
alias gst=gs
alias gsp='git stash pop'
alias gsa='git stash apply'
#alias gsh='git show'
#alias gshw='git show'
#alias gshow='git show'
#alias gi='vim .gitignore'
#alias gcm='git ci -m'
#alias gcim='git ci -m'
#alias gci='git ci'
#alias gco='git co'
#alias gcp='git cp'
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
#alias gap='git add -p'
#alias guns='git unstage'
#alias gunc='git uncommit'
#alias gm='git merge'
#alias gms='git merge --squash'
#alias gam='git amend --reset-author'
#alias grv='git remote -v'
#alias grr='git remote rm'
#alias grad='git remote add'
#alias gr='git rebase'
#alias gra='git rebase --abort'
#alias ggrc='git rebase --continue'
#alias gbi='git rebase --interactive'
#alias gl='git l'
#alias glg='git l'
#alias glog='git l'
#alias co='git co'
#alias gf='git fetch'
#alias gfp='git fetch --prune'
#alias gfa='git fetch --all'
#alias gfap='git fetch --all --prune'
#alias gfch='git fetch'
alias gd=fgd
#alias gb='git b'
## Staged and cached are the same thing
#alias gdc='git diff --cached -w'
#alias gds='git diff --staged -w'
#alias gpub='grb publish'
#alias gtr='grb track'
alias gpl='git pull --rebase --autostash'
#alias gplr='git pull --rebase'
alias gps='git push'
alias gpf='git push --force-with-lease'
alias gpsh='git push -u origin `git rev-parse --abbrev-ref HEAD`'
alias gnb='git nb' # new branch aka checkout -b
#alias grs='git reset'
alias grsh='git reset --hard'
#alias gcln='git clean'
#alias gclndf='git clean -df'
#alias gclndfx='git clean -dfx'
#alias gsm='git submodule'
#alias gsmi='git submodule init'
#alias gsmu='git submodule update'
#alias gt='git t'
#alias gbg='git bisect good'
#alias gbb='git bisect bad'
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias grbm='git pull origin staging --rebase --autostash'
alias gcm='git checkout staging'
alias cl='clear'
alias lg='lazygit'

# Ruby
alias be='bundle exec'
alias bi='bundle install'
alias c='rails c'
alias rs='be rails s'

export PATH="$HOME/.local/bin:$PATH"
