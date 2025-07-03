# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a **LazyVim-based Neovim configuration** that extends the LazyVim starter template with custom plugins and configurations. The setup follows LazyVim's modular architecture:

- **Base**: Uses LazyVim as the foundation (`LazyVim/LazyVim`)
- **Plugin Management**: Lazy.nvim handles all plugin loading and management
- **Configuration Structure**: 
  - `lua/config/` - Core Neovim configuration (options, keymaps, autocmds)
  - `lua/plugins/` - Individual plugin configurations as separate modules
  - `init.lua` - Entry point that bootstraps the lazy loader

## Key Configuration Details

### AI Integration
- Configurable AI partner via `vim.g.ai_partner` (defaults to "avante")
- Multiple AI providers supported: Avante.nvim, Claude Code, Copilot, CodeCompanion
- Avante uses Claude Sonnet 4 by default with custom endpoint configurations

### Development Commands

**Makefile targets:**
- `make build` - Sets up symlinked config at `~/.config/nvim_lazy` for testing
- `make clean` - Removes test configuration
- `make try` - Runs configuration in Docker container for testing

**Code formatting:**
- Uses StyLua for Lua code formatting (configured in `stylua.toml`)
- Settings: 2-space indentation, 120 character column width

### Custom Configuration Highlights

**Options** (`lua/config/options.lua`):
- Leader key: `<space>`, local leader: `\`
- 2-space indentation, no swap/backup files, line numbers enabled
- Color column at 81 characters, split windows open below/right
- Fast update times (100ms) and short timeouts (500ms)

**Key Mappings** (`lua/config/keymaps.lua`):
- Enhanced file path copying commands (`,cn`, `,cs`, `,cf`, `,cl`)
- Emacs-style command line navigation (`<C-a>`, `<C-e>`, etc.)
- `<C-s>` for saving in all modes
- Improved search behavior (`*`, `#` with cursor position restore)

### Plugin Architecture

**Plugin Loading**: All plugins in `lua/plugins/` are automatically loaded by LazyVim's spec system. Each file returns a Lua table with plugin specifications.

**Notable Plugins**:
- File management: neo-tree, telescope, ctrlsf
- AI assistance: avante.nvim, claude-code.nvim, copilot, codecompanion
- Language support: vim-go, vim-rails, LSP configurations
- UI enhancements: bufferline, noice, colorscheme customizations

**Plugin States**: Many plugins can be enabled/disabled based on global variables (e.g., `vim.g.ai_partner`)

### Directory Structure
```
lua/
├── config/          # Core Neovim configuration
│   ├── lazy.lua     # Lazy.nvim bootstrap and setup
│   ├── options.lua  # Vim options and global variables
│   ├── keymaps.lua  # Custom key mappings
│   └── autocmds.lua # Auto commands
└── plugins/         # Plugin configurations (one file per plugin/group)
    ├── disabled.lua # Empty file for disabling default LazyVim plugins
    └── *.lua        # Individual plugin configurations
```

## Development Workflow

When working with this configuration:

1. **Testing Changes**: Use `make build` to create a test environment at `~/.config/nvim_lazy`
2. **Plugin Modifications**: Edit files in `lua/plugins/` - each file should return a plugin spec table
3. **Core Changes**: Modify files in `lua/config/` for fundamental Neovim behavior
4. **Code Style**: Run StyLua for formatting consistency
5. **AI Partner Switching**: Set `vim.g.ai_partner` to switch between AI providers