#!/bin/bash
set -e

echo "🚀 Starting Coder workspace dotfiles installation..."

# Symlink .zshrc
if [ -f "$HOME/.zshrc" ]; then
  echo "📝 Backing up existing .zshrc to .zshrc.backup"
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
ln -sf "$(pwd)/.zshrc" "$HOME/.zshrc"
echo "✅ Linked .zshrc"

# Install common tools if not present
if ! command -v fzf &> /dev/null; then
  echo "📦 Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
fi

# Install rbenv if not present
if ! command -v rbenv &> /dev/null; then
  echo "📦 Installing rbenv..."
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo "📦 Installing ruby-build plugin..."
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

# Install eza if not present (modern ls replacement)
if ! command -v eza &> /dev/null; then
  echo "📦 Installing eza..."
  if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
  else
    echo "⚠️  Please install eza manually for your distribution"
  fi
fi

# Install ripgrep if not present
if ! command -v rg &> /dev/null; then
  echo "📦 Installing ripgrep..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get install -y ripgrep
  else
    echo "⚠️  Please install ripgrep manually for your distribution"
  fi
fi

# Install fd if not present
if ! command -v fd &> /dev/null; then
  echo "📦 Installing fd..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get install -y fd-find
    # Create symlink if fd-find is installed as fdfind
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
      sudo ln -s $(which fdfind) /usr/local/bin/fd
    fi
  else
    echo "⚠️  Please install fd manually for your distribution"
  fi
fi

echo "✨ Dotfiles installation complete!"
echo "🔄 Run 'source ~/.zshrc' or restart your shell to apply changes"
