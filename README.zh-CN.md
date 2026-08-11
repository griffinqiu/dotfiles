# Griffin的dotfiles

[English](README.md)

一套面向Apple Silicon macOS的克制、受管理的开发环境，覆盖终端工具、编辑器、
多路复用器、语言运行时和AI代理配置。

日常工作流只有两个入口：`dotfiles-bootstrap`负责改变环境；
`dotfiles-doctor`只读检查环境。

## 快速开始

系统要求：

- Apple Silicon Mac（`arm64`）；不支持Intel Mac或Linux。
- 预先安装[Homebrew](https://brew.sh/)。
- 可用的Git、GitHub SSH访问权限和网络连接。

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./bin/dotfiles-bootstrap
./bin/dotfiles-doctor
```

Bootstrap不会安装Homebrew，也不会自动运行Doctor。首次安装软件包、运行时和插件
需要网络连接。

## Bootstrap

不带参数时，Bootstrap按顺序运行以下组件：

| 组件 | 职责 |
|---|---|
| `packages` | 通过核心`Brewfile`安装缺失项，不升级已有软件包；安装缺失的固定Git依赖 |
| `links` | 安全迁移受保护路径，再通过RCM/`rcup`建立或刷新链接 |
| `runtimes` | 按`config/mise/config.toml`和`config/mise/mise.lock`安装精确版本 |
| `plugins` | 从lockfile恢复Neovim插件，并安装缺失的tmux插件 |

`Brewfile`是Homebrew Bundle的标准manifest。MacVim和Neovim都是必装的核心依赖；
`Brewfile.optional`是单独启用的附加清单，不会替代核心manifest。

| 参数 | 作用 |
|---|---|
| 无参数 | 按`packages → links → runtimes → plugins`运行全部组件 |
| `--only COMPONENTS` | 运行`packages`、`links`、`runtimes`、`plugins`的逗号分隔子集 |
| `--optional` | 选中`packages`时安装`Brewfile.optional`；配合`--check`时纳入Doctor检查 |
| `--upgrade` | 升级选中的软件包和/或插件集合；不改变`links`或`runtimes`的行为 |

只运行部分组件时不会自动补跑其前置组件。旧命令
`dotfiles-bootstrap --check`仅作为兼容别名保留；应优先使用
`dotfiles-doctor`。它不能与`--only`或`--upgrade`组合。Doctor也支持
`--optional`和`--quiet`。

## 编辑器与插件

| 范围 | 默认行为 | 配合`--upgrade` |
|---|---|---|
| MacVim | 由`packages`安装，使用轻量scratch配置，不使用外部插件管理器 | 选中`packages`时通过Homebrew升级 |
| Neovim | `plugins`从`lazy-lock.json`运行Lazy restore | 运行Lazy sync并更新lockfile |
| tmux | `plugins`通过TPM运行`install_plugins` | 安装缺失插件，再运行`update_plugins all` |

Oh My Zsh、`zsh-autosuggestions`、`zsh-syntax-highlighting`和TPM是由
`packages`管理的固定Git依赖。只有显式使用`--upgrade`时，已有的干净checkout
才会对齐到固定版本。

## 链接与本机覆盖

`links`组件调用RCM/`rcup`。如果存在`~/dotfiles-local`，它会先于当前仓库
传入，并在路径重叠时优先。要完整替换受管理文件，请在那里使用相同的相对路径。

链接完成后，RCM会运行`hooks/post-up`。该hook只创建
`~/.cache/nvim/tags`；它只执行本地操作、保持幂等、不访问网络，也不安装或升级软件。

明确支持的本机覆盖文件：

- `~/.zshrc.local`
- `~/.zshenv.local`
- `~/.tmux.conf.local`

密钥、机器专用token和本地服务配置不应进入主仓库。

## Claude Code与Codex

Claude路径是唯一可编辑来源。Codex通过相对符号链接使用相同的指令和可移植skills。

| 范围 | Claude唯一来源 | Codex引用 |
|---|---|---|
| 仓库指令 | `CLAUDE.md` | `AGENTS.md → CLAUDE.md` |
| 全局个人指令 | `claude/CLAUDE.md` | `codex/AGENTS.md → ../claude/CLAUDE.md` |
| Neovim指令 | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md → CLAUDE.md` |
| 所有项目可用的skills | `claude/skills/*` | `agents/skills/*`中的相对别名 |
| 仅本仓库可用的skills | `.claude/skills/*` | `.agents/skills/*`中的相对别名 |

RCM把全局层发布到`~/.claude`、`~/.codex`和`~/.agents`；点号目录层只保留在
当前仓库。`dotfiles-theme`属于仓库本地skill，`claude/skills/gitlab-mr*`则
刻意保持Claude-only。

在其他项目中先运行`bin/agent-config init`，再运行`bin/agent-config sync`；使用
`bin/agent-config check`验证最终拓扑。每个命令也接受`--project DIR`。
遇到冲突路径时会拒绝操作。

## 安全与验证

- 选中`links`时，会在软件包变更前检查Agent和Mise冲突。
- 已知的普通文件迁移会保存为`.pre-dotfiles`备份。
- 仅当旧链接精确指向当前checkout时才会删除。
- 固定Git checkout存在本地修改或无效时会停止，不会覆盖内容。
- Bootstrap不会运行`brew bundle cleanup`、卸载软件，也不会在后续组件失败时
  回滚已经完成的组件。

Doctor检查平台、命令、Homebrew状态、选定的RCM链接、Mise配置与lockfile、
固定Git依赖、Agent别名和部分配置语法。它不会修复环境，也不声称验证插件目录
和所有编辑器链接。

运行`./test/run`可执行仓库测试套件。

## 更新

```sh
git -C ~/dotfiles pull --ff-only && ~/dotfiles/bin/dotfiles-bootstrap
```

默认更新会重新运行全部受管理组件，但不会主动升级Homebrew软件包或已经漂移的
固定Git checkout。仅在确实需要升级时添加`--upgrade`。
