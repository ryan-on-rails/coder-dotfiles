#!/bin/bash
set -e

echo "🚀 Starting Coder workspace dotfiles installation..."

# Get the OS type
unameOut="$(uname -s)"

# Copy config files
echo "📦 Copying configuration files..."
if [ -d ".config" ]; then
  mkdir -p "$HOME/.config"
  cp -ra .config/* "$HOME/.config/"
  echo "✅ Copied .config directory"
fi

if [ -d ".local/bin" ]; then
  mkdir -p "$HOME/.local/bin"
  cp -a .local/bin/* "$HOME/.local/bin/"
  chmod +x "$HOME/.local/bin/"*
  echo "✅ Copied .local/bin scripts"
fi

# Copy asdf config files
if [ -f ".asdfrc" ]; then
  cp .asdfrc "$HOME/.asdfrc"
  echo "✅ Copied .asdfrc"
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

# Add local bin to path
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$PATH:$HOME/.local/bin"
fi

# Add git aliases
add_git_alias() {
  local alias_name="$1"
  local git_command="$2"

  if git config --global --get "alias.$alias_name" > /dev/null; then
    echo "Git alias '$alias_name' already exists."
    return
  else
    echo "Adding git alias '$alias_name' for '$git_command'."
    git config --global "alias.$alias_name" "$git_command"
  fi
}

add_git_alias "co" "checkout"
add_git_alias "ff" "pull --ff-only"
add_git_alias "br" "branch"
add_git_alias "st" "status"
add_git_alias "lg" "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global rerere.enabled true

# Install tools based on OS
case "${unameOut}" in
  Linux*)     
    echo "📦 Installing packages for Linux..."
    sudo apt-get update
    sudo apt install -y ripgrep fd-find zsh
    
    # Create fd symlink if needed
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
      sudo ln -s $(which fdfind) /usr/local/bin/fd
    fi

    # Install asdf
    if [[ -z `command -v asdf` ]]; then
      echo "📦 Installing asdf..."
      curl -LO https://github.com/asdf-vm/asdf/releases/download/v0.16.6/asdf-v0.16.6-linux-amd64.tar.gz
      tar xzf asdf-v0.16.6-linux-amd64.tar.gz -C $HOME/.local/bin
      rm asdf-v0.16.6-linux-amd64.tar.gz
    fi

    # Install eza
    if ! command -v eza &> /dev/null; then
      echo "📦 Installing eza..."
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt-get update
      sudo apt-get install -y eza
    fi
    ;;
  Darwin*)   
    echo "📦 Installing packages for macOS..."
    if command -v brew &> /dev/null; then
      brew install ripgrep fd zsh
    else
      echo "⚠️  Homebrew not found. Please install brew first."
    fi

    # Install asdf
    if [[ -z `command -v asdf` ]]; then
      echo "📦 Installing asdf..."
      curl -LO https://github.com/asdf-vm/asdf/releases/download/v0.16.6/asdf-v0.16.6-darwin-arm64.tar.gz
      tar xzf asdf-v0.16.6-darwin-arm64.tar.gz -C $HOME/.local/bin
      rm asdf-v0.16.6-darwin-arm64.tar.gz
    fi

    # Install eza via brew
    if ! command -v eza &> /dev/null; then
      echo "📦 Installing eza..."
      brew install eza
    fi
    ;;
esac

# Set zsh as default shell
ZSH_PATH=$(command -v zsh)
if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
  echo "Setting Zsh as default shell..."
  if command -v sudo > /dev/null; then
    sudo chsh -s "$ZSH_PATH" "$(whoami)"
  else
    chsh -s "$ZSH_PATH"
  fi
  echo "✅ Default shell set to Zsh"
else
  echo "✅ Zsh is already the default shell"
fi

# Install Oh My Zsh
OHMYZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$OHMYZSH_DIR" ]; then
  echo "✅ Oh My Zsh is already installed"
else
  echo "📦 Installing Oh My Zsh..."
  if command -v curl > /dev/null; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    echo "✅ Oh My Zsh installed successfully"
  else
    echo "⚠️  curl not found. Cannot install Oh My Zsh"
  fi
fi

# Install FZF
if ! command -v fzf &> /dev/null; then
  echo "📦 Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
  echo "✅ FZF installed"
else
  echo "✅ FZF is already installed"
fi

# Install asdf plugins if asdf is available
if command -v asdf &> /dev/null; then
  echo "📦 Installing asdf plugins..."
  
  # Add plugins if not already added
  asdf plugin add neovim 2>/dev/null || true
  asdf plugin add ruby 2>/dev/null || true
  asdf plugin add nodejs 2>/dev/null || true
  
  echo "✅ asdf plugins configured"
  echo "ℹ️  Run 'asdf install' to install versions from .tool-versions"
fi

echo ""
echo "✨ Dotfiles installation complete!"
echo "🔄 Run 'source ~/.zshrc' or restart your shell to apply changes"
echo ""
echo "Next steps:"
echo "  1. If asdf was installed, run: asdf install"
echo "  2. Restart your terminal or run: exec zsh"
