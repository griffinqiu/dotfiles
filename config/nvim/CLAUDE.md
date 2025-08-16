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

**MCPHub Integration**:
- MCPHub provides Model Context Protocol (MCP) server integration for Avante
- Extends AI capabilities with custom tools and server resources
- Auto-approves MCP tool calls and allows LLMs to start/stop servers automatically
- Configuration in `~/.config/mcphub/servers.json`
- Command: `:MCPHub` to access interface
- Port: 37373 (default), configurable in plugin settings

### Development Commands

**Makefile targets:**
- `make build` - Sets up symlinked config at `~/.config/nvim_lazy` for testing
- `make clean` - Removes test configuration
- `make try` - Runs configuration in Docker container for testing

**Code formatting:**
- Uses StyLua for Lua code formatting (configured in `stylua.toml`)
- Settings: 2-space indentation, 120 character column width
- Format command: `stylua .` (run from repository root)

**Language-specific commands:**
- Go: `<leader>gg` - Build Go files or run tests (auto-detects test files)
- Go: `<leader>gC` - Toggle test coverage

**AI/Avante commands:**
- `<leader>an` - Start new Avante chat session
- `<leader>ac` - Clear Avante chat
- `<leader>aa` - Toggle Avante sidebar
- `<leader>ad` - Toggle Avante debug mode
- `<leader>ah` - Toggle Avante hints
- `<leader>aR` - Toggle Avante repomap
- In Avante input: `<M-CR>` - Insert newline (insert mode)

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

**LazyVim Extras Enabled** (configured in `lazyvim.json`):
- **AI**: copilot, copilot-chat
- **Coding**: luasnip, mini-comment, mini-surround, nvim-cmp, yanky
- **Editor**: dial, inc-rename, mini-diff, mini-move, neo-tree, refactoring, telescope
- **Languages**: cmake, docker, git, go, json, markdown, python, ruby, sql, toml, typescript, yaml
- **Testing**: core test framework
- **Utilities**: dot, mini-hipatterns, project

**Custom Plugins**:
- File management: neo-tree, telescope, ctrlsf
- AI assistance: avante.nvim, claude-code.nvim, copilot, codecompanion
- Language support: vim-go, vim-rails, LSP configurations
- UI enhancements: bufferline, noice, colorscheme customizations

**Plugin States**: Many plugins can be enabled/disabled based on global variables:
- `vim.g.ai_partner` - Controls which AI provider is active (default: "avante")
- `vim.g.snacks_animate` - Disables snacks animations (set to false)
- `vim.g.minipairs_disable` - Disables mini.pairs plugin (set to true)
- `vim.env.USER` - Sets user name to "Griffin" for personalization

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

### Advanced AI Configuration

**Avante System Prompts**: The Avante configuration uses dynamic system prompts via MCPHub integration:
- System prompt function calls `require("mcphub").get_hub_instance():get_active_servers_prompt()`
- Custom tools are provided through `require("mcphub.extensions.avante").mcp_tool()`
- This allows context-aware AI assistance based on active MCP servers

**Multi-Provider Setup**: Avante supports "dual boost" mode combining Claude and OpenAI responses for enhanced output quality.