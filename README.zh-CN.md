# Griffin的dotfiles

[English](README.md)

一套面向Apple Silicon macOS和无界面x86_64 Linux的克制、受管理的开发环境，
覆盖终端工具、编辑器、多路复用器、语言运行时和AI代理配置。

日常工作流只有两个入口：`dotfiles-bootstrap`负责改变环境；
`dotfiles-doctor`只读检查环境。

## 快速开始

系统要求：

- 预先装好[Homebrew](https://brew.sh/)的Apple Silicon Mac（`arm64`），或带
  `apt`（Debian、Ubuntu）/`dnf`（Fedora）且有`sudo`权限的x86_64 Linux主机。
  不支持Intel Mac和ARM Linux。
- 可用的Git、GitHub SSH访问权限和网络连接。

```sh
git clone git@github.com:griffinqiu/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./bin/dotfiles-bootstrap
./bin/dotfiles-doctor
```

Bootstrap不会安装Homebrew，也不会自动运行Doctor。首次安装软件包、运行时和插件
需要网络连接。

Linux上需要手动执行一次`chsh -s "$(command -v zsh)"`把登录shell换成zsh；
Bootstrap发现不是zsh时会提示，但不会替你修改。

## Bootstrap

不带参数时，Bootstrap按顺序运行以下组件：

| 组件 | 职责 |
|---|---|
| `packages` | 通过核心`Brewfile`（macOS）或`Linuxfile`（Linux）安装缺失项，不升级已有软件包；安装缺失的固定Git依赖；缺少Claude Code、Codex（Linux上还有Mise）时用官方安装脚本安装 |
| `links` | 安全迁移受保护路径，通过RCM/`rcup`建立或刷新链接，再清理源文件已从本checkout删除的链接 |
| `runtimes` | 按`config/mise/config.toml`和`config/mise/mise.lock`安装精确版本 |
| `plugins` | 从lockfile恢复Neovim插件，并安装缺失的tmux插件 |

`Brewfile`是Homebrew Bundle的标准manifest。MacVim和Neovim都是必装的核心依赖；
`Brewfile.optional`是单独启用的附加清单，不会替代核心manifest。

## Linux

Linux按通过SSH使用的无界面开发机支持；GUI应用（Ghostty、Kitty、Hammerspoon、
MacVim、字体）仍只在macOS上安装。

| 层次 | Linux上的来源 |
|---|---|
| 系统软件包 | `Linuxfile`/`Linuxfile.optional`：每行一个包，先写`apt`包名再写`dnf`包名（`-`表示该包管理器不需要），由`bin/dotfiles-linux-packages`通过`sudo`安装 |
| 发行版太旧或没有的命令行工具 | Neovim、fzf、fd、gh、glab、lazygit、uv、bun、stylua、shfmt、diff-so-fancy、Herdr、Bootmux和1Password CLI在`config/mise/config.toml`中以`os = ["linux"]`固定版本，并锁定`linux-x64` |
| Mise本身 | 官方安装脚本，装到`~/.local/bin/mise` |

`bin/dotfiles-linux-packages check`只报告缺失的包，不做修改；`install`还会生成
shell需要的`en_US.UTF-8` locale。只适用于macOS的shell设置——Keychain凭据助手和
Oh My Zsh的`macos`插件——在Linux上会自动关闭。代理别名在两个平台上都生效，
两边的代理监听同样的本地端口。

Bootstrap是普通的`sh`脚本，用不到这些别名。如果claude.ai、chatgpt.com或GitHub
需要走代理，请显式传入；curl、Mise和Git都会读取它：

```sh
https_proxy=http://127.0.0.1:6152 http_proxy=http://127.0.0.1:6152 ./bin/dotfiles-bootstrap
```

修改固定版本的工具后，同时刷新两个平台的lockfile：

```sh
MISE_GLOBAL_CONFIG_FILE=~/dotfiles/config/mise/config.toml \
  MISE_GLOBAL_CONFIG_ROOT=~/dotfiles/config/mise mise lock -g
```

| 参数 | 作用 |
|---|---|
| 无参数 | 按`packages → links → runtimes → plugins`运行全部组件 |
| `--only COMPONENTS` | 运行`packages`、`links`、`runtimes`、`plugins`的逗号分隔子集 |
| `--optional` | 选中`packages`时安装`Brewfile.optional`或`Linuxfile.optional`；配合`--check`时纳入Doctor检查 |
| `--upgrade` | 升级选中的软件包和/或插件集合；不改变`links`或`runtimes`的行为 |

只运行部分组件时不会自动补跑其前置组件。旧命令
`dotfiles-bootstrap --check`仅作为兼容别名保留；应优先使用
`dotfiles-doctor`。它不能与`--only`或`--upgrade`组合。Doctor也支持
`--optional`和`--quiet`。

## 编辑器与插件

| 范围 | 默认行为 | 配合`--upgrade` |
|---|---|---|
| MacVim | 由`packages`安装，使用轻量scratch配置；gruvbox以固定版本的Vim package加载，仍不使用插件管理器 | 选中`packages`时通过Homebrew升级 |
| Neovim | `plugins`从`lazy-lock.json`运行Lazy restore | 运行Lazy sync并更新lockfile |
| tmux | `plugins`通过TPM运行`install_plugins` | 安装缺失插件，再运行`update_plugins all` |

Oh My Zsh、`zsh-autosuggestions`、`zsh-syntax-highlighting`、TPM和gruvbox
配色是由`packages`管理的固定Git依赖。只有显式使用`--upgrade`时，已有的干净checkout
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

## 通过 Mosh 向 Herdr 粘贴图片

`bin/herdr-mosh HOST [HERDR_ARGUMENTS...]` 通过 Mosh 在远端 Mac 上运行
`/opt/homebrew/bin/herdr`。按 Option-V 会读取本机 macOS 剪贴板中的 PNG，
通过独立的免交互 SSH 连接上传，再粘贴远端路径，不发送回车。终端发出的
空 bracketed paste 信号也会触发图片桥接；普通文本粘贴和 Ctrl-V 原样转发。

新 shell 加载 `zshrc` 时，会将现有的普通 Mosh `herdr-macmini-mosh` 别名
切换到包装脚本，自定义过的别名不会被覆盖。已有会话需要通过该入口重新连接。

图片大小上限为 20 MiB，上传后保留在远端私有的
`/tmp/herdr-mosh-image.*/image.png` 文件中，供 agent 后续读取；不再需要时
可删除这些目录。本机剪贴板保持不变。即使 Mosh 仍然在线，传图也需要 SSH 可用。

## Claude Code与Codex

Claude路径是唯一可编辑来源。Codex通过相对符号链接使用相同的指令和可移植skills。

| 范围 | Claude唯一来源 | Codex引用 |
|---|---|---|
| 仓库指令 | `CLAUDE.md` | `AGENTS.md → CLAUDE.md` |
| 全局个人指令 | `claude/CLAUDE.md` | `codex/AGENTS.md → ../claude/CLAUDE.md` |
| Neovim指令 | `config/nvim/CLAUDE.md` | `config/nvim/AGENTS.md → CLAUDE.md` |
| 所有项目可用的skills | `claude/skills/*` | `agents/skills/*`中的相对别名 |
| 仅本仓库可用的skills | `.claude/skills/*` | `.agents/skills/*`中的相对别名 |

Pi通过`pi/agent/AGENTS.md → ../../claude/CLAUDE.md`读取同一份全局指令，
并自行从`~/.agents/skills`发现skills。可共享的`pi/agent/settings.json`和
`pi/agent/mcp.json`链接到`~/.pi/agent`；凭证、会话和工具自动安装的扩展
保留在本机。Pi本身在Mise配置中固定版本。

RCM把全局层发布到`~/.claude`、`~/.codex`和`~/.agents`；点号目录层只保留在
当前仓库。`dotfiles-theme`属于仓库本地skill，`claude/skills/gitlab-mr*`则
刻意保持Claude-only。

`bin/agentsync [--project DIR]`在其他项目中重建同样的拓扑，遇到冲突路径时拒绝操作。

## 安全与验证

- 选中`links`时，会在软件包变更前检查Agent和Mise冲突。
- 已知的普通文件迁移会保存为`.pre-dotfiles`备份。
- 仅当旧链接精确指向当前checkout时才会删除。RCM只建链接、从不回收，因此删除
  受管理文件会留下悬空链接；`links`组件会清理它们，`bin/dotfiles-prune-links
  [--dry-run]`可随时手动执行。有效链接和指向checkout之外的悬空链接都不会被动。
- 固定Git checkout存在本地修改或无效时会停止，不会覆盖内容。
- Bootstrap不会运行`brew bundle cleanup`、卸载软件，也不会在后续组件失败时
  回滚已经完成的组件。

Doctor检查平台、命令、Homebrew或Linux软件包状态、选定的RCM链接、Mise配置与lockfile、
固定Git依赖、Agent别名和部分配置语法。它不会修复环境，也不声称验证插件目录
和所有编辑器链接。

运行`./test/run`可执行仓库测试套件。

## 更新

```sh
git -C ~/dotfiles pull --ff-only && ~/dotfiles/bin/dotfiles-bootstrap
```

默认更新会重新运行全部受管理组件，但不会主动升级Homebrew软件包或已经漂移的
固定Git checkout。仅在确实需要升级时添加`--upgrade`。
