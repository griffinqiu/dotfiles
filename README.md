# Griffin's dotfiles

[中文](#中文) | [English](#english)

## 中文

### 概览

这是 Griffin 的 Apple Silicon macOS 开发环境配置，覆盖终端、Zsh、Git、
Vim/MacVim/Neovim、tmux/Herdr/Bootmux、Mise，以及 Claude Code/Codex。

日常只需要记住两个入口：

| 入口 | 作用 |
|---|---|
| `./bin/dotfiles-bootstrap` | 安装或刷新软件包、配置链接、语言运行时和插件 |
| `./bin/dotfiles-doctor` | 独立、只读地检查当前环境 |

Bootstrap 不会自动运行 Doctor。安装完成后单独运行 Doctor，才能得到独立的
环境健康检查结果。

### 系统要求与快速开始

- Apple Silicon Mac（`arm64`）；当前不支持 Intel Mac 或 Linux。
- 已预先安装 [Homebrew](https://brew.sh/)；Bootstrap 不会安装 Homebrew。
- 可用的 Git、GitHub SSH 访问权限和网络连接。Homebrew 依赖、固定 Git 依赖、
  语言运行时及插件的首次安装都需要联网。

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/dotfiles-bootstrap
./bin/dotfiles-doctor
```

Bootstrap 默认依次运行 `packages`、`links`、`runtimes`、`plugins`，完成本仓库
管理范围内的整套安装。

### Bootstrap 组件

| 组件 | 默认行为 |
|---|---|
| `packages` | 通过核心 `Brewfile` 安装缺失的 Homebrew 依赖；缺失时安装固定提交版本的 TPM；默认不升级已有依赖 |
| `links` | 处理受保护路径的迁移，并在仓库根目录上调用 RCM/`rcup` 建立或刷新链接 |
| `runtimes` | 按 `config/mise/config.toml` 和 `config/mise/mise.lock` 安装锁定的 Go、Lua、Node.js、Python、Ruby、Rust 和 Zig |
| `plugins` | 安装或恢复 Neovim 和 tmux 插件 |

`Brewfile` 是核心 Homebrew 依赖的真实 manifest，其中包括 MacVim、Neovim、
RCM、Mise、tmux、Ghostty、Herdr、Bootmux 和开发工具。
`Brewfile.optional` 只保存非必要工具，并不会替代核心 manifest。

只运行部分组件时，Bootstrap 不会自动补跑其依赖。例如，单独运行
`plugins` 前应已经完成 `packages` 和 `links`。

### 参数

| 参数 | 作用与限制 |
|---|---|
| 无参数 | 按 `packages → links → runtimes → plugins` 运行全部组件 |
| `--only COMPONENTS` | 只运行逗号分隔的组件，例如 `--only links,plugins`；可选值为 `packages`、`links`、`runtimes`、`plugins` |
| `--optional` | 在核心 `Brewfile` 之上追加 `Brewfile.optional`；仅适用于包含 `packages` 的运行 |
| `--upgrade` | 升级所选的 `packages` 和/或 `plugins`；不改变 `links`、`runtimes` 的语义 |

`--check` 仅为兼容旧用法而保留，等价于运行 Doctor；新命令和文档应直接使用
`./bin/dotfiles-doctor`。Doctor 的 `--optional` 会检查可选 manifest，`--quiet`
只输出警告、失败项和最终摘要。

### 插件行为

| 范围 | 默认 `plugins` | 配合 `--upgrade` |
|---|---|---|
| Neovim | 以 headless 模式运行 `Lazy restore`，按 `lazy-lock.json` 安装或还原插件 | 运行 `Lazy sync`，更新插件及 lockfile |
| tmux | 通过 TPM 运行 `install_plugins`，安装缺失插件 | 安装缺失插件后运行 `update_plugins all` |

MacVim 和 Neovim 本体都由 `packages` 安装。MacVim 使用无插件管理器的轻量
scratch 配置；`plugins` 只管理 Neovim 与 tmux 插件。TPM、Oh My Zsh，以及
Oh My Zsh 的两个外部插件（`zsh-autosuggestions`、`zsh-syntax-highlighting`，
安装到 `~/.oh-my-zsh/custom/plugins/`）都是 `packages` 中的固定 Git 依赖。

### 更新

在 `~/dotfiles` 中运行：

```sh
git pull --ff-only && ./bin/dotfiles-bootstrap
```

默认更新会补齐缺失依赖、刷新链接、安装锁定的运行时版本，并安装缺失
插件或恢复 lockfile 状态；它不会主动升级 Homebrew 包或未锁定的插件集合。
需要升级时显式加上 `--upgrade`。

### RCM 与本机覆盖

`links` 组件内部调用 RCM/`rcup`。如果 `~/dotfiles-local` 存在，Bootstrap
会先传入该目录，再传入当前仓库；RCM 对重叠路径采用第一个结果，因此
本机目录优先。要完整覆盖某个受管理文件，应在 `~/dotfiles-local` 中使用相同
的相对路径。

`links` 组件的 `rcup` 结束后会运行 `hooks/post-up`。当前 hook 只创建
`~/.cache/nvim/tags`，不会联网，也不会安装或升级软件、运行时或插件。

当前显式支持的 `*.local` 覆盖文件只有：

- `~/.zshrc.local`
- `~/.zshenv.local`
- `~/.tmux.conf.local`

不要把密钥、机器专用 token 或本地服务配置提交到主仓库。

### Claude Code 与 Codex

Claude 路径是指令和可移植 skill 的唯一可编辑来源；Codex 只通过相对符号
链接引用它们，不复制内容。

| 范围 | Claude 唯一来源 | Codex 引用 |
|---|---|---|
| 仓库指令 | `CLAUDE.md` | `AGENTS.md -> CLAUDE.md` |
| 全局个人指令 | `claude/CLAUDE.md` | `codex/AGENTS.md -> ../claude/CLAUDE.md` |
| Neovim 指令 | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md -> CLAUDE.md` |
| 下发到所有项目的 skills | `claude/skills/*` | `agents/skills/*` 中的相对别名 |
| 本仓库独有的 skills | `.claude/skills/*` | `.agents/skills/*` 中的相对别名 |

顶层 `CLAUDE.md` 和 `AGENTS.md` 被 RCM 排除。全局个人指令会链接到
`~/.claude/CLAUDE.md` 和 `~/.codex/AGENTS.md`。

Skill 分两层，区别在于是否发布到 HOME：`claude/skills/*` 及其 `agents/skills/*`
别名由 RCM 发布到 `~/.claude/skills/` 和 `~/.agents/skills/`，所有项目可见；
`.claude/skills/*` 及其 `.agents/skills/*` 别名只在本仓库内可见，不发布。
`dotfiles-theme` 只为本仓库配色，属于后者。`claude/skills/gitlab-mr*` 是
Claude-only 例外，不会镜像到 Codex。

普通项目可使用 `bin/agent-config` 建立并检查同样的指令与 skill 链接拓扑。

### 安全边界与健康检查

- 选择 `links` 时，Bootstrap 会在软件包变更前预检已知的 Agent/Mise 路径。
- 空的 `~/.codex/AGENTS.md`、普通文件形式的 Mise 配置和旧的独立 Mise 文件
  会先保存为对应的 `.pre-dotfiles` 备份；受保护路径发生外部、失效或类型
  冲突时会停止。
- 旧链接只有在目标精确属于当前仓库时才会删除；外部的 `.agrc` 会保留。
- Bootstrap 不运行 `brew bundle cleanup`，也不卸载软件；它不是事务系统，
  后续失败不会回滚已经完成的步骤。

Doctor 检查平台、核心命令、Brewfile 状态、选定的 RCM 链接、Mise 配置与
lockfile、固定 Git 依赖、Agent 别名和部分配置语法。它不安装或修复内容，
也不声称验证插件目录或所有编辑器配置链接；发现失败时返回非零状态。

---

## English

### Overview

These are Griffin's development-environment settings for Apple Silicon macOS,
covering terminals, Zsh, Git, Vim/MacVim/Neovim, tmux/Herdr/Bootmux, Mise, and
Claude Code/Codex.

Only two operational entry points are recommended:

| Entry point | Purpose |
|---|---|
| `./bin/dotfiles-bootstrap` | Install or refresh packages, configuration links, language runtimes, and plugins |
| `./bin/dotfiles-doctor` | Run an independent, read-only health check of the current environment |

Bootstrap does not run Doctor automatically. Run Doctor separately after an
installation to get an independent environment health check.

### Requirements and quick start

- An Apple Silicon Mac (`arm64`); Intel Macs and Linux are not currently
  supported.
- [Homebrew](https://brew.sh/) installed in advance; Bootstrap does not install
  Homebrew.
- Working Git, GitHub SSH access, and a network connection. Initial installation
  of Homebrew dependencies, pinned Git dependencies, language runtimes, and
  plugins requires network access.

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bin/dotfiles-bootstrap
./bin/dotfiles-doctor
```

By default, Bootstrap runs `packages`, `links`, `runtimes`, and `plugins` in that
order, completing the full setup managed by this repository.

### Bootstrap components

| Component | Default behavior |
|---|---|
| `packages` | Install missing Homebrew items from the core `Brewfile`; install the pinned TPM revision when missing; do not upgrade installed items by default |
| `links` | Migrate protected paths and invoke RCM/`rcup` at the repository root to create or refresh links |
| `runtimes` | Install locked Go, Lua, Node.js, Python, Ruby, Rust, and Zig versions from `config/mise/config.toml` and `config/mise/mise.lock` |
| `plugins` | Install or restore Neovim and tmux plugins |

`Brewfile` is the actual manifest for core Homebrew dependencies, including
MacVim, Neovim, RCM, Mise, tmux, Ghostty, Herdr, Bootmux, and development tools.
`Brewfile.optional` contains only non-essential tools and does not replace the
core manifest.

When running selected components, Bootstrap does not add their prerequisites
automatically. For example, `packages` and `links` should already be complete
before running `plugins` alone.

### Options

| Option | Behavior and constraints |
|---|---|
| No option | Run all components as `packages → links → runtimes → plugins` |
| `--only COMPONENTS` | Run only comma-separated components, such as `--only links,plugins`; valid values are `packages`, `links`, `runtimes`, and `plugins` |
| `--optional` | Add `Brewfile.optional` on top of the core `Brewfile`; valid only when `packages` is selected |
| `--upgrade` | Upgrade the selected `packages` and/or `plugins`; does not change `links` or `runtimes` semantics |

`--check` remains only as a compatibility alias for Doctor; new commands and
documentation should use `./bin/dotfiles-doctor` directly. Doctor's `--optional`
includes the optional manifest, while `--quiet` prints only warnings, failures,
and the final summary.

### Plugin behavior

| Scope | Default `plugins` | With `--upgrade` |
|---|---|---|
| Neovim | Run `Lazy restore` headlessly to install or restore plugins from `lazy-lock.json` | Run `Lazy sync` to update plugins and the lockfile |
| tmux | Run TPM `install_plugins` to install missing plugins | Install missing plugins, then run `update_plugins all` |

MacVim and Neovim themselves are installed by `packages`. MacVim uses a lean
scratch configuration with no plugin manager; `plugins` manages only Neovim and
tmux plugins. TPM, Oh My Zsh, and Oh My Zsh's two external plugins
(`zsh-autosuggestions` and `zsh-syntax-highlighting`, installed under
`~/.oh-my-zsh/custom/plugins/`) are pinned Git dependencies of `packages`.

### Updating

From `~/dotfiles`, run:

```sh
git pull --ff-only && ./bin/dotfiles-bootstrap
```

The default update fills missing items, refreshes links, installs locked runtime
versions, and installs missing plugins or restores lockfile state. It does not
proactively upgrade Homebrew packages or unlocked plugin sets. Add `--upgrade`
explicitly when upgrades are intended.

### RCM and local overrides

The `links` component invokes RCM/`rcup` internally. When `~/dotfiles-local`
exists, Bootstrap passes it before the current checkout; RCM uses the first
result for overlapping paths, so the local directory takes precedence. To
replace a managed file completely, use the same relative path under
`~/dotfiles-local`.

`hooks/post-up` runs after the `links` component's `rcup`. It currently only
creates `~/.cache/nvim/tags`; it performs no network access and does not install
or upgrade software, runtimes, or plugins.

The only explicitly supported `*.local` override files are:

- `~/.zshrc.local`
- `~/.zshenv.local`
- `~/.tmux.conf.local`

Do not commit secrets, machine-specific tokens, or local-service configuration
to the main repository.

### Claude Code and Codex

Claude paths are the only editable sources for instructions and portable skills.
Codex references them through relative symbolic links and does not copy content.

| Scope | Claude canonical source | Codex reference |
|---|---|---|
| Repository instructions | `CLAUDE.md` | `AGENTS.md -> CLAUDE.md` |
| Global personal instructions | `claude/CLAUDE.md` | `codex/AGENTS.md -> ../claude/CLAUDE.md` |
| Neovim instructions | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md -> CLAUDE.md` |
| Skills delivered to every project | `claude/skills/*` | Relative aliases under `agents/skills/*` |
| Skills unique to this repository | `.claude/skills/*` | Relative aliases under `.agents/skills/*` |

Top-level `CLAUDE.md` and `AGENTS.md` are excluded from RCM. Global personal
instructions are linked to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`.

Skills come in two layers, separated by whether RCM publishes them into `$HOME`.
`claude/skills/*` and their `agents/skills/*` aliases are published to
`~/.claude/skills/` and `~/.agents/skills/`, so every project sees them.
`.claude/skills/*` and their `.agents/skills/*` aliases stay inside this
repository. `dotfiles-theme` only styles this repository and belongs to the
latter. `claude/skills/gitlab-mr*` are Claude-only exceptions and are not
mirrored into Codex.

Ordinary projects can use `bin/agent-config` to create and verify the same
instruction and skill-link topology.

### Safety boundaries and health checks

- When `links` is selected, Bootstrap preflights known Agent/Mise paths before
  package changes.
- An empty `~/.codex/AGENTS.md`, a regular Mise configuration, and a former
  standalone Mise file are preserved as corresponding `.pre-dotfiles` backups;
  foreign, dangling, or type conflicts on protected paths stop the run.
- Retired links are removed only when their targets belong exactly to the current
  checkout; foreign `.agrc` paths are preserved.
- Bootstrap does not run `brew bundle cleanup` or uninstall software. It is not
  transactional, so a later failure does not roll back completed steps.

Doctor checks the platform, core commands, Brewfile status, selected RCM links,
Mise configuration and lockfile, pinned Git dependencies, Agent aliases, and
selected configuration syntax. It does not install or repair anything, and it
does not claim to verify plugin trees or every editor configuration link. It
exits nonzero when failures are found.
