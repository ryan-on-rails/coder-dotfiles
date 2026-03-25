#!/bin/bash
set -e

echo "🚀 Starting Coder workspace dotfiles installation..."

unameOut="$(uname -s)"

# Copy config files
echo "📦 Copying configuration files..."
if [ -d ".config" ]; then
  mkdir -p "$HOME/.config"
  cp -ra .config/* "$HOME/.config/"
  echo "✅ Copied .config directory"
fi

# Copy .claude config — commands and skills are always synced (additive);
# CLAUDE.md and settings.json only written if not already present (preserves customizations)
if [ -d ".claude" ]; then
  mkdir -p "$HOME/.claude/commands" "$HOME/.claude/skills"
  [ -d ".claude/commands" ] && cp -ra .claude/commands/. "$HOME/.claude/commands/"
  [ -d ".claude/skills" ] && cp -ra .claude/skills/. "$HOME/.claude/skills/"
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

case "${unameOut}" in
  Linux*)
    echo "📦 Installing packages for Linux..."
    # cloud-init already ran apt-get update, skip it if packages are present
    if ! command -v rg &> /dev/null || ! command -v fd &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y --no-install-recommends ripgrep fd-find
    fi

    # fd symlink
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
      sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    # eza — direct binary, avoids GPG+apt repo setup (~2 min saved)
    if ! command -v eza &> /dev/null; then
      echo "📦 Installing eza..."
      curl -fsSLo /tmp/eza.tar.gz \
        "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz"
      tar -xzf /tmp/eza.tar.gz -C ~/.local/bin eza
      rm /tmp/eza.tar.gz
      echo "✅ eza installed"
    fi

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

    # Add asdf plugins and install tools not already present
    asdf plugin add neovim 2>/dev/null || true
    asdf plugin add kubectl 2>/dev/null || true
    # Install only — skips tools already compiled in the prebuild AMI
    asdf install
    echo "✅ asdf tools installed"
    ;;
  Darwin*)
    echo "📦 Installing packages for macOS..."
    if command -v brew &> /dev/null; then
      brew install ripgrep fd eza lazygit
    else
      echo "⚠️  Homebrew not found. Please install brew first."
    fi

    if ! command -v asdf &> /dev/null; then
      echo "📦 Installing asdf..."
      curl -LO "https://github.com/asdf-vm/asdf/releases/download/v0.16.6/asdf-v0.16.6-darwin-arm64.tar.gz"
      tar xzf asdf-v0.16.6-darwin-arm64.tar.gz -C "$HOME/.local/bin"
      rm asdf-v0.16.6-darwin-arm64.tar.gz
    fi

    asdf plugin add neovim 2>/dev/null || true
    asdf install
    ;;
esac

# Set zsh as default shell
ZSH_PATH=$(command -v zsh)
if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting Zsh as default shell..."
  sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null || chsh -s "$ZSH_PATH"
  echo "✅ Default shell set to Zsh"
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended --keep-zshrc
  echo "✅ Oh My Zsh installed"
fi

# Install FZF
if ! command -v fzf &> /dev/null; then
  echo "📦 Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
  echo "✅ FZF installed"
fi

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
