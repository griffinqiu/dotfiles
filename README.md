# Griffin's dotfiles

[简体中文](README.zh-CN.md)

A focused, managed development environment for Apple Silicon macOS,
covering terminal tools, editors, multiplexers, language runtimes, and AI agent
configuration.

The workflow has two entry points: `dotfiles-bootstrap` changes the environment;
`dotfiles-doctor` inspects it without making changes.

## Quick start

Requirements:

- An Apple Silicon Mac (`arm64`). Intel Macs and Linux are not supported.
- [Homebrew](https://brew.sh/) installed in advance.
- Working Git, GitHub SSH access, and a network connection.

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./bin/dotfiles-bootstrap
./bin/dotfiles-doctor
```

Bootstrap does not install Homebrew or run Doctor automatically. Initial package,
runtime, and plugin installation requires network access.

## Bootstrap

With no options, Bootstrap runs the following components in order:

| Component | Responsibility |
|---|---|
| `packages` | Install missing items from the core `Brewfile` without upgrading existing packages; install missing pinned Git dependencies |
| `links` | Safely migrate protected paths, create or refresh links through RCM/`rcup`, then prune links whose source this checkout no longer has |
| `runtimes` | Install exact versions from `config/mise/config.toml` and `config/mise/mise.lock` |
| `plugins` | Restore Neovim plugins from the lockfile and install missing tmux plugins |

`Brewfile` is the standard Homebrew Bundle manifest. MacVim and Neovim are
mandatory core dependencies. `Brewfile.optional` is a separate opt-in inventory
and never replaces the core manifest.

| Option | Effect |
|---|---|
| No option | Run `packages → links → runtimes → plugins` |
| `--only COMPONENTS` | Run a comma-separated subset of `packages`, `links`, `runtimes`, and `plugins` |
| `--optional` | Install `Brewfile.optional` when `packages` is selected; with `--check`, include it in Doctor |
| `--upgrade` | Upgrade selected packages and/or plugin sets; it does not change `links` or `runtimes` |

Selected components do not implicitly run their prerequisites. The legacy
`dotfiles-bootstrap --check` form remains a compatibility alias; prefer
`dotfiles-doctor`. It cannot be combined with `--only` or `--upgrade`. Doctor
also accepts `--optional` and `--quiet`.

## Editors and plugins

| Scope | Default behavior | With `--upgrade` |
|---|---|---|
| MacVim | Installed by `packages` with a lean scratch configuration; gruvbox loads as a pinned Vim package, so there is still no plugin manager | Upgraded through Homebrew when `packages` is selected |
| Neovim | `plugins` runs Lazy restore from `lazy-lock.json` | Runs Lazy sync and updates the lockfile |
| tmux | `plugins` runs TPM `install_plugins` | Installs missing plugins, then runs `update_plugins all` |

Oh My Zsh, `zsh-autosuggestions`, `zsh-syntax-highlighting`, TPM, and the
gruvbox colorscheme are pinned Git dependencies managed by `packages`. Existing clean checkouts are
aligned only when `--upgrade` is explicit.

## Links and local overrides

The `links` component invokes RCM/`rcup`. If `~/dotfiles-local` exists, it
is passed before this repository and takes precedence for overlapping paths.
Use the same relative path there to replace a managed file completely.

After linking, RCM runs `hooks/post-up`. The hook only creates
`~/.cache/nvim/tags`; it is local, idempotent, network-free, and does not
install or upgrade software.

Explicit local override files:

- `~/.zshrc.local`
- `~/.zshenv.local`
- `~/.tmux.conf.local`

Keep secrets, machine-specific tokens, and local-service configuration outside
the main repository.

## Claude Code and Codex

Claude paths are the only editable sources. Codex consumes the same instructions
and portable skills through relative symbolic links.

| Scope | Claude canonical source | Codex reference |
|---|---|---|
| Repository instructions | `CLAUDE.md` | `AGENTS.md → CLAUDE.md` |
| Global personal instructions | `claude/CLAUDE.md` | `codex/AGENTS.md → ../claude/CLAUDE.md` |
| Neovim instructions | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md → CLAUDE.md` |
| Skills available to every project | `claude/skills/*` | Relative aliases under `agents/skills/*` |
| Skills private to this repository | `.claude/skills/*` | Relative aliases under `.agents/skills/*` |

RCM publishes the global layer into `~/.claude`, `~/.codex`, and `~/.agents`;
the dotted layer remains repository-local. `dotfiles-theme` is
repository-local, while `claude/skills/gitlab-mr*` intentionally remains
Claude-only.

`bin/agentsync [--project DIR]` reproduces this topology in another project and
refuses conflicting paths.

## Safety and verification

- Agent and Mise conflicts are detected before package changes when `links` is
  selected.
- Known regular-file migrations are preserved as `.pre-dotfiles` backups.
- Retired links are removed only when they point exactly into this checkout.
  RCM creates links but never reclaims them, so deleting a tracked file leaves a
  dangling link behind; the `links` component removes those, and
  `bin/dotfiles-prune-links [--dry-run]` does the same on demand. Live links and
  dangling links pointing outside the checkout are never touched.
- Dirty or invalid pinned Git checkouts stop the run instead of being overwritten.
- Bootstrap never runs `brew bundle cleanup`, uninstalls software, or rolls back
  earlier components after a later failure.

Doctor checks the platform, commands, Homebrew state, selected RCM links, Mise
configuration and lockfile, pinned Git dependencies, Agent aliases, and selected
configuration syntax. It does not repair the environment or claim to validate
plugin trees and every editor link.

Run the repository test suite with `./test/run`.

## Updating

```sh
git -C ~/dotfiles pull --ff-only && ~/dotfiles/bin/dotfiles-bootstrap
```

The default update reruns all managed components without proactively upgrading
Homebrew packages or drifted pinned Git checkouts. Add `--upgrade` only when an
upgrade is intended.
