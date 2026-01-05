# Coder Dotfiles

Personal dotfiles configuration for [Coder](https://coder.com) workspaces.

## Usage

When creating a new Coder workspace, provide this repository URL in the dotfiles settings:

```
https://github.com/YOUR_USERNAME/coder-dotfiles
```

Coder will automatically clone this repository and run `install.sh` to set up your environment.

## What's Included

### Shell Configuration (.zshrc)
- Custom aliases for git, navigation, and development
- Enhanced directory listing with `eza`
- FZF integration for fuzzy finding
- Useful functions for file search, git branch switching, and process management

### Tools Installed
- **fzf** - Fuzzy finder for the command line
- **rbenv** - Ruby version manager
- **eza** - Modern replacement for `ls`
- **ripgrep** - Fast text search tool
- **fd** - Fast alternative to `find`

## Manual Installation

To test this setup locally:

```bash
git clone https://github.com/YOUR_USERNAME/coder-dotfiles.git
cd coder-dotfiles
./install.sh
source ~/.zshrc
```

## Customization

Edit `.zshrc` to add your own aliases, functions, or environment variables. Commit and push changes to update all future workspaces.
