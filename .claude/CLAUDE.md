# Global Claude Context

## Environment
- Coder workspace: ephemeral Ubuntu 22.04 on AWS EC2 (t3.2xlarge)
- Shell: zsh + Oh My Zsh | Editor: nvim (LazyVim)
- Version manager: asdf (`~/.asdf/shims` on PATH)
- Home dir is ephemeral — personal config comes from coder-dotfiles repo

## Stack
- Ruby 3.3.2 — Rails apps: Coyote (port 9000), Falco (7000), Beeline (8002), Lyra (4301/4302)
- Node.js 22.8.0
- PostgreSQL 16
- Tilt for local service orchestration (`tilt up` in `~/workspace/`)
- AWS (secrets via `~/.aws/.env.coder`)

## Key Conventions
- Use `bundle exec` (aliased `be`) for Ruby commands
- Squash merge PRs — keep linear history for bisect/revert
- Keep PRs small and focused (target under 200 lines)
- Run tests before committing: `rspec` or `bundle exec rspec`
- Use `rubocop -a` for auto-fixable style issues

## Git Aliases Available
- `gs` → git status, `ga` → git add -A, `gc` → git commit -v
- `gpl` → git pull --rebase --autostash, `gps` → git push
- `gpsh` → push and set upstream, `lg` → lazygit

## Shell Utilities
- `rg` → ripgrep, `fd` → find, `fzf` → fuzzy finder
- `ll` / `la` → eza with icons, `ls` → eza
