# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a **thoughtbot-inspired dotfiles repository** that provides a comprehensive development environment setup for macOS. The configuration uses **rcm (RCM)** for dotfile management and includes configurations for:

- **Neovim**: LazyVim-based configuration with AI integration
- **Zsh**: Oh-My-Zsh with custom functions and completions
- **Tmux**: Terminal multiplexer with custom themes
- **Git**: Enhanced workflow with custom aliases and hooks
- **Kitty/Ghostty**: Terminal emulator configurations
- **Development Tools**: Ruby, Rails, Go, and other language-specific setups

## Common Commands

### Dotfiles Management

- `rcup` - Install/update dotfiles (creates symlinks)
- `rcup -v` - Verbose installation showing what's being linked
- `rcdn` - Remove dotfiles symlinks
- `mkrc <file>` - Add a file to dotfiles management

### Development Workflow

- `tat` - Attach to tmux session named after current directory
- `b` / `bundle` - Bundle commands
- `be` / `bundle exec` - Execute with bundler
- `s` / `rspec` - Run RSpec tests
- `g` - Git status (no args) or git command (with args)
- `vim` / `nvim` - Neovim editor (aliased)

### Git Workflow (Custom Scripts in bin/)

- `git create-branch <name>` - Create and switch to feature branch
- `git delete-branch <name>` - Delete feature branch safely
- `git up` - Fetch and rebase origin/master
- `git up -i` - Interactive rebase with origin/master
- `git co-pr <number>` - Checkout GitHub PR locally
- `git-ctags` - Generate ctags for current repository

### Setup and Installation

- **Initial setup**: `env RCRC=$HOME/dotfiles/rcrc rcup`
- **Post-installation hook**: Automatically runs `hooks/post-up` which:
  - Installs Homebrew packages (fzf, tig, neovim, etc.)
  - Sets up Oh-My-Zsh
  - Installs tmux plugin manager (tpm)
  - Configures vim-plug for Vim

## Configuration Architecture

### Core Structure

```
dotfiles/
├── rcrc                    # RCM configuration
├── hooks/post-up          # Post-installation setup script
├── bin/                   # Custom scripts and git commands
├── config/                # XDG config directory contents
│   ├── nvim/             # Neovim LazyVim configuration
│   ├── kitty/            # Kitty terminal configuration
│   └── zellij/           # Zellij terminal multiplexer
├── zsh/                  # Zsh configuration modules
│   ├── configs/          # Modular zsh configurations
│   ├── functions/        # Custom shell functions
│   └── completion/       # Zsh completions
└── vim/                  # Legacy Vim configuration
```

### Neovim Configuration

The Neovim setup is located in `config/nvim/` and uses LazyVim as its foundation:

- **AI Integration**: Configurable via `vim.g.ai_partner` (supports Avante, Claude Code, Copilot)
- **MCPHub**: Model Context Protocol integration for enhanced AI capabilities
- **Language Support**: Go, Ruby/Rails, TypeScript, Python, and more
- **Development Tools**: Integrated testing, debugging, and code navigation

**Key Neovim Commands**:

- `make build` - Create test configuration at `~/.config/nvim_lazy`
- `make clean` - Remove test configuration
- `stylua .` - Format Lua code

### Local Customizations

Create `~/dotfiles-local/` for personal overrides:

- `aliases.local` - Custom aliases
- `gitconfig.local` - Git user configuration
- `vimrc.local` - Vim customizations
- `zshrc.local` - Zsh customizations
- `tmux.conf.local` - Tmux overrides

### Zsh Configuration System

The zsh setup uses a modular approach:

- `zsh/configs/pre/` - Files loaded first
- `zsh/configs/` - Main configuration files
- `zsh/configs/post/` - Files loaded last
- Custom functions in `zsh/functions/`

## Development Environment

### Language-Specific Tools

- **Ruby**: ASDF version management, bundler integration, Rails helpers
- **Go**: Custom build/test commands, coverage integration
- **Git**: Enhanced workflow with thoughtbot-style branch management
- **Terminal**: Tmux with custom prefix (`Ctrl+s`), improved status bar

### Key Aliases and Functions

- `mcd <dir>` - Make directory and cd into it
- `replace foo bar **/*.rb` - Find and replace across files
- `envup` - Source .env files
- `g` - Smart git command (status without args, git with args)
- `migrate` - Rails database migration workflow

### Tool Integration

- **FZF**: Fuzzy finding for files, commands, and git objects
- **Ripgrep**: Fast text search
- **Universal Ctags**: Code navigation and indexing
- **Lazygit/Lazydocker**: Terminal UIs for Git and Docker
- **Tig**: Git repository browser

## Notable Features

### Git Hooks and Automation

- Post-commit ctags regeneration
- Pre-commit hooks for code quality
- Branch management workflows
- GitHub PR integration

### Terminal Multiplexing

- Tmux with custom theme and key bindings
- Automatic session management with `tat`
- Improved copy/paste on macOS

### AI-Powered Development

- Multiple AI provider support in Neovim
- Context-aware assistance through MCPHub
- Integrated code review and generation tools

### Package Management

- Homebrew bundle in post-up hook
- ASDF for language version management
- Vim-plug for legacy Vim plugins
- Lazy.nvim for Neovim plugin management

This dotfiles repository provides a complete, opinionated development environment optimized for Ruby/Rails development while supporting multiple languages and modern development workflows.

