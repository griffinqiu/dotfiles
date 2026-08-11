# Griffin's dotfiles

Apple-silicon macOS terminal, shell, Git, editor, multiplexer, and agent
configuration.
Tracked files are linked into the home directory with
[rcm](https://github.com/thoughtbot/rcm); machine-specific overrides belong in
`~/dotfiles-local`.

## Install

Install Homebrew from [brew.sh](https://brew.sh/), then clone and bootstrap:

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/dotfiles-bootstrap
```

The default installs the core Brewfile, checks out pinned Oh My Zsh and TPM
revisions when missing, links the repository with rcm, and installs the exact
runtime versions from the committed Mise config and lockfile. MacVim is part of
the mandatory core toolset, alongside Neovim.

Useful non-essential tools are separate:

```sh
./bin/dotfiles-bootstrap --optional
```

Existing Homebrew packages are not upgraded unless requested explicitly:

```sh
./bin/dotfiles-bootstrap --upgrade
./bin/dotfiles-bootstrap --upgrade --optional
```

Bootstrap never runs `brew bundle cleanup` and never uninstalls software.

## Check and update

Run the complete read-only doctor without installing, linking, or upgrading:

```sh
./bin/dotfiles-bootstrap --check
./bin/dotfiles-bootstrap --check --optional
# equivalent direct entry point
./bin/dotfiles-doctor
```

After pulling repository changes, `rcup` refreshes links. Its `post-up` hook is
deliberately limited to creating local cache directories; package, runtime, and
plugin installation never occurs implicitly during `rcup`.

Mise runtime versions are exact pins in `config/mise/config.toml`, with
macOS-arm64 download resolution in `config/mise/mise.lock`. Bootstrap installs
them with `mise install --locked -y`; refresh the lock intentionally when
changing a version. The 1Password CLI is deliberately owned by the core
Homebrew cask instead of Mise: its vfox backend does not expose a download asset
that satisfies strict locked installation.

Bootstrap preflights agent and Mise paths before package mutation. It preserves
an existing empty regular `~/.codex/AGENTS.md` as `AGENTS.md.pre-dotfiles` and
an existing regular `~/.config/mise/config.toml` as
`config.toml.pre-dotfiles` before rcm creates their managed symlinks. Foreign,
dangling, and non-regular conflicts stop bootstrap without overwriting them.
The former standalone `~/.local/bin/mise` is likewise moved to
`mise.pre-dotfiles`, leaving Homebrew as the single Mise owner.
It also removes only four retired symlinks when their targets exactly match this
checkout: root-level `.CLAUDE.md`/`.AGENTS.md` and the deleted `.agrc`/`_ag`
entries. Unrelated files are never deleted.

## Agent configuration

Claude paths are the only editable source of instructions and portable skills.
Codex consumes relative symlinks to those sources:

- Repository instructions: `CLAUDE.md`; `AGENTS.md -> CLAUDE.md`.
- Personal instructions: `claude/CLAUDE.md`;
  `codex/AGENTS.md -> ../claude/CLAUDE.md`.
- Project skills: `.claude/skills/`; `.agents/skills/` contains only aliases.

This dotfiles checkout is the installer for global configuration, so its
portable Codex aliases live under `agents/skills/` for RCM to publish into
`~/.agents/skills/`. The `dotfiles-theme` body remains canonical under
`.claude/skills/`. Ordinary project repositories use the project-level paths
created by `agent-config`.

Use the checked helper rather than copying files between agent directories:

```sh
agent-config init --project /path/to/project
agent-config sync --project /path/to/project
agent-config check --project /path/to/project
```

## Validation

Run the complete self-contained shell suite:

```sh
./test/run
```

The focused bootstrap regression test uses a temporary home directory:

```sh
./test/bootstrap.sh
```

It verifies no-upgrade defaults, read-only check mode, Brewfile boundaries,
the RCM/Git-ignore invariant, the network-free hook, and locked Mise resolution.
