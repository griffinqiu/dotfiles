# CLAUDE.md

This is the canonical project instruction file. `AGENTS.md` is the relative
symlink `AGENTS.md -> CLAUDE.md`, so Claude Code and Codex read the same content.

## Repository Purpose

This macOS dotfiles repository uses RCM to link tracked configuration into the
home directory. `~/dotfiles-local` has precedence for machine-specific
overrides. Preserve unrelated working-tree changes and never absorb local-only
configuration into this repository without an explicit request.

## Shared Agent Configuration

- Keep project instructions in `CLAUDE.md`; never replace `AGENTS.md` with a
  copied file.
- Keep global personal instructions in `claude/CLAUDE.md`; expose them through
  `codex/AGENTS.md -> ../claude/CLAUDE.md`.
- Keep skill bodies in Claude discovery paths; every Codex entry is a relative
  symlink to one. Which Claude path decides the scope:
  - `claude/skills/` with an `agents/skills/` alias is published by RCM into
    `$HOME`, so every project sees it.
  - `.claude/skills/` with an `.agents/skills/` alias stays in this repository.
    A skill that only acts on this repository, such as `dotfiles-theme`,
    belongs here and must not be given an `agents/skills/` alias.
- Keep `claude/skills/gitlab-mr*` Claude-only.
- Use `bin/agent-config init|sync|check [--project DIR]` for the same topology in
  other projects. Run `test/agent-config.sh` after changing this workflow.

## Setup and Validation

- `./bin/dotfiles-bootstrap` installs missing core dependencies and links the
  repository. Package upgrades require the explicit `--upgrade` option.
- `./bin/dotfiles-bootstrap --optional` includes optional packages.
- `./bin/dotfiles-bootstrap --check` and `./bin/dotfiles-doctor` are read-only
  environment checks; add `--optional` to include optional dependencies.
- `./test/run` runs the repository shell test suite.
- Run a focused test file, such as `./test/agent-config.sh`, while iterating.

The `hooks/post-up` hook must remain fast, local, idempotent, and network-free.
Package installation, downloads, and upgrades belong in
`bin/dotfiles-bootstrap`, not in the RCM hook.

## Git Branch Handling

Do not hardcode `main` or `master` in Git helpers. Use
`bin/git-default-branch [REMOTE]`, which checks the remote HEAD and then known
fallback refs. `git-up` and `git-churn` are expected to use this helper.

## Main Layout

- `bin/`: executable workflow and Git helpers.
- `config/`: XDG application configuration, including Neovim, Ghostty, Herdr,
  Kitty, Lazygit, mise, and Zellij.
- `hooks/`: RCM lifecycle hooks.
- `test/`: standalone shell tests collected by `test/run`.
- `claude/` and `agents/`: global Claude canonical configuration and Codex
  aliases.
- `.claude/`: project-scoped Claude configuration and skills.

Neovim-specific instructions live in `config/nvim/CLAUDE.md`, with
`config/nvim/AGENTS.md` as its Codex symlink.

## Change Discipline

- Inspect `git status --short` before editing and treat existing changes as
  user-owned.
- Use `apply_patch` for repository file edits and avoid broad rewrites.
- Validate only the affected surface first, then run `./test/run` when shared
  setup, hooks, or helpers change.
- Do not commit, push, or create a pull or merge request without an explicit
  instruction in the current turn.
