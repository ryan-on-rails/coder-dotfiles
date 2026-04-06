#!/bin/bash
set -e

echo "🚀 Starting Coder workspace dotfiles installation..."

unameOut="$(uname -s)"

# Copy config files
echo "📦 Copying configuration files..."
if [ -d ".config" ]; then
  mkdir -p "$HOME/.config"
  cp -a .config/* "$HOME/.config/"
  echo "✅ Copied .config directory"
fi

# Copy .claude config — commands and skills are always synced (additive);
# CLAUDE.md and settings.json only written if not already present (preserves customizations)
if [ -d ".claude" ]; then
  mkdir -p "$HOME/.claude/commands" "$HOME/.claude/skills"
  [ -d ".claude/commands" ] && cp -a .claude/commands/. "$HOME/.claude/commands/"
  [ -d ".claude/skills" ] && cp -a .claude/skills/. "$HOME/.claude/skills/"
  [ ! -f "$HOME/.claude/CLAUDE.md" ] && cp .claude/CLAUDE.md "$HOME/.claude/CLAUDE.md"
  [ ! -f "$HOME/.claude/settings.json" ] && cp .claude/settings.json "$HOME/.claude/settings.json"
  echo "✅ Configured .claude directory"
fi

if [ -d ".local/bin" ]; then
  mkdir -p "$HOME/.local/bin"
  cp -a .local/bin/* "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/"*
  echo "✅ Copied .local/bin scripts"
fi

if [ -f ".tool-versions" ]; then
  cp .tool-versions "$HOME/.tool-versions"
  echo "✅ Copied .tool-versions"
fi

# Symlink .zshrc
if [ -f "$HOME/.zshrc" ]; then
  echo "📝 Backing up existing .zshrc to .zshrc.backup"
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
ln -sf "$(pwd)/.zshrc" "$HOME/.zshrc"
echo "✅ Linked .zshrc"

export PATH="$HOME/.local/bin:$HOME/.asdf/shims:$PATH"

# Add git aliases
add_git_alias() {
  local alias_name="$1"
  local git_command="$2"
  if git config --global --get "alias.$alias_name" > /dev/null 2>&1; then
    echo "Git alias '$alias_name' already exists."
  else
    git config --global "alias.$alias_name" "$git_command"
  fi
}

add_git_alias "co" "checkout"
add_git_alias "ff" "pull --ff-only"
add_git_alias "br" "branch"
add_git_alias "st" "status"
add_git_alias "lg" "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global rerere.enabled true

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

case "${unameOut}" in
  Linux*)
    echo "📦 Installing packages for Linux..."
    # lazygit
    if ! command -v lazygit &> /dev/null; then
      echo "📦 Installing lazygit..."
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep -Po '"tag_name": "v\K[^"]*')
      curl -fsSLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin
      rm /tmp/lazygit /tmp/lazygit.tar.gz
      echo "✅ lazygit installed"
    fi

    # asdf — skip install if already present (prebuild AMI has it)
    if ! command -v asdf &> /dev/null; then
      echo "📦 Installing asdf..."
      latest_tag=$(curl -s "https://api.github.com/repos/asdf-vm/asdf/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
      curl -fsSLo /tmp/asdf.tar.gz \
        "https://github.com/asdf-vm/asdf/releases/download/${latest_tag}/asdf-${latest_tag}-linux-amd64.tar.gz"
      tar -xzf /tmp/asdf.tar.gz -C ~/.local/bin
      rm /tmp/asdf.tar.gz
      echo "✅ asdf installed"
    fi

    # Install only — skips tools already compiled in the prebuild AMI
    asdf install
    echo "✅ asdf tools installed"
    ;;
  Darwin*)
    echo "📦 Installing packages for macOS..."
    if ! command -v asdf &> /dev/null; then
      echo "📦 Installing asdf..."
      curl -LO "https://github.com/asdf-vm/asdf/releases/download/v0.16.6/asdf-v0.16.6-darwin-arm64.tar.gz"
      tar xzf asdf-v0.16.6-darwin-arm64.tar.gz -C "$HOME/.local/bin"
      rm asdf-v0.16.6-darwin-arm64.tar.gz
    fi

    asdf install
    ;;
esac

# Install Claude Code CLI (node is available via asdf shims)
if ! command -v claude &> /dev/null; then
  echo "📦 Installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | zsh
  echo "✅ Claude Code CLI installed"
fi

# Install git-jump
if ! npm list -g git-jump &> /dev/null 2>&1; then
  npm install -g git-jump
  echo "✅ git-jump installed"
fi

echo ""
echo "✨ Dotfiles installation complete!"
echo "🔄 Restart your shell or run: exec zsh"
