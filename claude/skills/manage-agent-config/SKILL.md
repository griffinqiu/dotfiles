---
name: manage-agent-config
description: Maintain Claude-canonical instructions and skills with Codex symlink aliases in this dotfiles repository or another project. Use when adding, changing, migrating, syncing, or diagnosing CLAUDE.md, AGENTS.md, portable Agent Skills, discovery symlinks, or bin/agent-config; preserve one source of truth and refuse conflicting overwrites.
---

# Manage Agent Config

Keep shared behavior in Claude discovery paths and expose it to Codex through
relative symlinks. Never maintain copied instruction or skill bodies.

## Canonical Topology

| Scope | Claude canonical source | Codex alias |
|---|---|---|
| Personal instructions | `claude/CLAUDE.md` | `codex/AGENTS.md -> ../claude/CLAUDE.md` |
| Repository instructions | `CLAUDE.md` | `AGENTS.md -> CLAUDE.md` |
| Neovim instructions | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md -> CLAUDE.md` |
| Personal portable skills | `claude/skills/<name>/` | `agents/skills/<name>` is a relative symlink |
| Repository portable skills | `.claude/skills/<name>/` | `.agents/skills/<name>` is a relative symlink |

Keep product-specific instructions or skills only in their native tree. Keep
`claude/skills/gitlab-mr*` Claude-only unless the user explicitly requests a
portability review. In this repository, keep the existing
`.claude/skills/dotfiles-theme` body in place and expose it to Codex only through
`.agents/skills/dotfiles-theme`.

## Workflow

1. Resolve the repository root and read its active `CLAUDE.md` files.
2. Inspect `git status --short`, the target files, and existing symlinks. Treat
   unrelated changes as user-owned. Stop rather than overwrite a conflicting
   change.
3. Classify the change as personal or repository scoped and as portable or
   product-specific.
4. Edit the Claude canonical source first. Keep the matching Codex entry as a
   relative symlink, never as copied prose or an import wrapper.
5. For a portable skill, use only the common Agent Skills frontmatter fields
   `name` and `description` in `SKILL.md`. Put product metadata under
   `<canonical-skill>/agents/` and keep scripts and references relative to the
   canonical skill directory.
6. Create the matching Codex symlink with a relative target. Do not replace an
   existing non-link or a link to another target.
7. For another project, run `bin/agent-config init` to establish the instruction
   pair, `bin/agent-config sync` to add missing portable-skill aliases, and
   `bin/agent-config check` to verify both directions.
8. Validate every new or changed skill with the active skill-creator package's
   `scripts/quick_validate.py`, and run `test/agent-config.sh` when topology or
   sync behavior changes.

## Guardrails

- Do not use Codex fallback filenames to consume `CLAUDE.md`; use the native
  `AGENTS.md` symlink.
- Do not duplicate shared prose in both native entry files.
- Do not assume nested instruction loading is identical: Codex discovers from
  the repository root down to its launch directory, while Claude can load
  nested instructions on demand.
- Do not prune unknown skills or links. `sync` may create missing links but must
  refuse real directories, foreign links, and orphaned reverse entries.
- `bin/agent-config` checks another project's root instruction pair and project
  skills only. In this dotfiles repository, separately verify the personal and
  Neovim aliases listed in the topology table.
- Report the canonical file changed, adapter links affected, and validation
  actually run.
