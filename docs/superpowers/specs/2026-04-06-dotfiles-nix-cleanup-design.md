# Dotfiles Cleanup: Remove OMZ/eza, Add Determinate Nix

**Date:** 2026-04-06  
**Status:** Approved

## Problem

The dotfiles `install.sh` and `.zshrc` are failing on Coder workspace startup due to unreliable package installs (eza binary download, Oh My Zsh). Several installs are also redundant — the Coder `acme` template already provisions zsh, asdf, and sets the login shell at workspace creation time.

## Goal

Align `install.sh` and `.zshrc` with what the Coder template already provides. Replace fragile binary downloads and Oh My Zsh with Determinate Systems Nix for reproducible, declarative tool management.

## What the Coder Template Already Provides (don't duplicate)

- `zsh` — installed via cloud-init apt
- `asdf` — installed via bootstrap `install-asdf.sh`
- Login shell — set at workspace creation time via Coder parameter (fish/zsh/bash)
- Core apt packages: curl, git, vim, tmux, jq, unzip, rsync, build-essential, libssl-dev, libpq-dev, etc.

## Approach: Determinate Nix for Tool Management

Use [Determinate Systems Nix](https://determinate.systems/) to install and manage developer tools. A `flake.nix` in the dotfiles repo declares the exact tool set. Works on both `x86_64-linux` (Coder) and `aarch64-darwin` (local macOS).

This replaces: individual binary downloads from GitHub, the macOS `brew install` tool line, and asdf plugins for non-runtime tools.

## Changes

### New file: `flake.nix`

Declares a single `default` package (a `buildEnv`) for both supported systems:

| Tool | Replaces |
|---|---|
| `fzf` | git clone + install script |
| `lazygit` | GitHub binary download |
| `ripgrep` | apt install |
| `fd` | apt install + fdfind symlink |
| `neovim` | asdf plugin |
| `kubectl` | asdf plugin |

Supported systems: `x86_64-linux`, `aarch64-darwin`

### `install.sh`

**Remove:**
- `eza` binary download block
- Oh My Zsh install block
- `chsh` / set default shell block (template handles this)
- `git clone fzf` install block
- `asdf plugin add neovim` and `asdf plugin add kubectl`
- macOS `brew install ripgrep fd eza lazygit` line

**Add:**
- Determinate Nix installer: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm`
- Source Nix daemon profile immediately after install so `nix` is available in the same shell session: `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
- `nix profile install .#default` to install all declared tools

**Keep:**
- File copying (.config, .claude, .local/bin, .tool-versions)
- Git alias setup
- `asdf install` (for ruby, nodejs, awscli, python)
- Claude Code CLI install
- git-jump npm install

### `.tool-versions`

Remove entries now managed by Nix:
- `kubectl 1.23.6`
- `neovim stable`

Keep: `ruby`, `nodejs`, `awscli`, `python` (runtime tools; asdf manages these as the template expects)

### `.zshrc`

**Remove:**
- All Oh My Zsh config: `ZSH`, `ZSH_THEME`, `ZSH_CUSTOM`, `plugins=()`, `source $ZSH/oh-my-zsh.sh`
- `eza` aliases (`ls`, `ll`, `la`)

**Add:**
- Nix profile sourcing: `[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"`
- `autoload -U compinit && compinit` — zsh tab completion (previously provided by OMZ)
- `eval "$(fzf --zsh)"` — fzf key bindings (ctrl-r, ctrl-t, alt-c) and completion
- Simple PROMPT using built-in `vcs_info` for git branch display
- Manual plugin source: `source ~/.config/zsh/custom/plugins/coder-tools/coder-tools.plugin.zsh`
- Plain ls aliases: `ls='ls --color=auto'`, `ll='ls -lh --color=auto'`, `la='ls -lah --color=auto'`

**Keep as-is:**
- All PATH exports (local bin, asdf shims)
- asdf PATH setup
- Platform detection and macOS-specific paths
- All fzf functions (f, fm, fd, fif, fkill, fo, fgb, fgd, fzf-git-branch, gch)
- All aliases (git, ruby, navigation, process management)
- macOS Finder aliases and brew aliases
- `setopt no_share_history`

## What Is Not Changing

- `.config/nvim/` — LazyVim config unchanged
- `.claude/` — commands, skills, CLAUDE.md, settings.json unchanged
- `.local/bin/` — scripts unchanged
- `.asdfrc` — unchanged
- `coder-tools` plugin logic — unchanged, just loaded via direct `source` instead of OMZ plugin system
