# CLAUDE.md

This is the canonical instruction file for the Neovim configuration.
`AGENTS.md -> CLAUDE.md` exposes the same guidance to Codex.

## Structure

- `init.lua` bootstraps the configuration.
- `lua/config/` contains core options, keymaps, autocommands, and Lazy setup.
- `lua/plugins/` contains Lazy.nvim plugin specifications and local integration
  logic.
- `lazyvim.json` records enabled LazyVim extras.
- `lazy-lock.json` pins resolved plugin commits.
- `stylua.toml` defines Lua formatting.

Do not document a provider, model, enabled extra, or plugin behavior as stable
without checking the current source. For example, the active AI partner is set
in `lua/config/options.lua`, and provider integrations live in separate plugin
specifications.

## Editing Rules

- Keep each plugin module a valid Lazy.nvim specification returning a Lua table.
- Put fundamental editor behavior in `lua/config/`; keep integration-specific
  behavior in `lua/plugins/`.
- Preserve lazy loading and existing enable conditions when changing a plugin.
- Keep Lua formatted according to `stylua.toml`.
- Update `lazy-lock.json` only through an intentional plugin resolution/update,
  not by hand.

## Commands

Run from `config/nvim/`:

- `stylua --check .` checks Lua formatting without rewriting files.
- `stylua .` formats Lua files.
- `make build` replaces the isolated `~/.config/nvim_lazy` test application with
  a symlink to this directory; it does not alter the primary Neovim config.
- `make clean` removes that isolated test application's config, data, state, and
  cache directories.

Treat `make build` and `make clean` as explicit filesystem-changing validation;
do not run them when the user requested a read-only review.
