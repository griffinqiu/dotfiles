# Handoff：让 Mac mini 上点击的链接在 MacBook 打开

写于 2026-09-05，来自 `~/github/agents` 会话。目标读者：在 `~/dotfiles` 里开的新会话。所有事实都在 Mac mini 上核实过，来源标在括号里。

## 1. 背景

- 拓扑：MacBook（Ghostty，mosh 客户端）→ Mac mini（`Griffins-MacMini`，Herdr 0.8.2 server + Claude Code）。Tailscale 名：`macbook` 100.93.81.16，`macmini` 100.82.155.5。
- 症状：两条路都在 Mac mini 上打开浏览器。
  1. Herdr 里 Ctrl+点击链接：Herdr 自己 spawn opener 进程（Herdr release notes："Ctrl-click URL openers are now reaped after they exit"）。
  2. Claude Code `/artifacts` 里按 `o`、ctrl+]、以及各种 OAuth 登录：调用 `open`。
- 目标：点击即在 MacBook 打开，**保留** Herdr 的鼠标捕获（`mouse_capture = true`）。

## 2. 已核实的事实

1. Claude Code `openBrowser()`：macOS 下若设了 `BROWSER` 环境变量，执行 `execFile(BROWSER, [url])`，否则 `open`（泄漏源码 `claude-code-mar31/src/utils/browser.ts:44-62`）。
2. Claude Code 复制链接：有 `SSH_CONNECTION` 时发 OSC 52，不调 pbcopy（`src/ink/termio/osc.ts`）。所以 `/artifacts` 里 `c` 理论上能落到 MacBook 剪贴板，取决于 mosh、Herdr、Ghostty 是否放行 OSC 52，未验证。
3. Herdr 插件 v1 的 `[[link_handlers]]`（docs v0.8.2 `plugins.mdx` "Link handlers" 章节，原文要点）：
   - 把**修饰键点击**（所有平台包括 macOS 都是 **Control**，不是 Cmd）命中 `pattern`（Rust 正则）的 URL 路由到同插件的一个 `action`，**不再打开浏览器**。
   - action 命令收到 `HERDR_PLUGIN_CLICKED_URL`、`HERDR_PLUGIN_LINK_HANDLER_ID`，以及 `HERDR_PLUGIN_CONTEXT_JSON`（含 `clicked_url`、`invocation_source = "link_click"`）。
   - `command` 是 argv 数组，不经 shell；运行时 cwd 是插件目录；继承用户环境。
   - 同一插件内按清单顺序匹配。
4. 本地插件注册：`herdr plugin link /path/to/plugin`，对当前用户所有会话全局生效，server 不用重启；`herdr plugin action list --plugin <id>` 列动作，`herdr plugin log list --plugin <id>` 看日志。插件 id 允许点号，action / link handler id 不允许点号。
5. 官方示例（`ogulcancelik/herdr-plugin-examples/github-link-preview/herdr-plugin.toml`，link handler 就是这么写的）：
   ```toml
   id = "examples.github-link-preview"
   name = "GitHub Link Preview"
   version = "0.1.0"
   min_herdr_version = "0.7.0"
   platforms = ["linux", "macos"]

   [[actions]]
   id = "open"
   title = "Open GitHub link preview"
   command = ["bash", "open.sh"]

   [[link_handlers]]
   id = "github-issue-or-pr"
   title = "Preview GitHub issue or PR"
   pattern = "^https://github\\.com/[^/]+/[^/]+/(issues|pull)/[0-9]+/?$"
   action = "open"
   ```
6. 本机现状：`~/.config/herdr/config.toml` → `~/dotfiles/config/herdr/config.toml`；`~/.config/herdr/plugins` 不存在；`~/.ssh/config` 没有 macbook 条目（ssh config 不在 dotfiles）；MacBook 的 Remote Login 已开（22 端口通），但 Mac mini → MacBook **还没有免密**（`ssh -o BatchMode=yes griffin@100.93.81.16` 返回 Permission denied）；Mac mini 公钥在 `~/.ssh/id_rsa.pub`。
7. dotfiles 约定：`bin/` 放脚本、`zshrc` 为 `~/.zshrc` 真身、`claude/CLAUDE.md` 为全局 CLAUDE.md 真身（今天已加"运行环境（远程操作的 Mac mini）"一节，可顺手补一句本方案）。不要替用户 commit。

## 3. 方案

一个转发脚本 + 一个 Herdr 插件 + 两处环境配置。

### 3.1 `bin/remote-open`

```sh
#!/bin/sh
# Open a URL on the MacBook that drives this Mac mini; fall back to local `open`.
# Used as $BROWSER by Claude Code and by the Herdr remote-open plugin.
set -u
url="${1:-}"
host="${REMOTE_OPEN_HOST:-macbook}"
case "$url" in
  http://*|https://*) ;;
  *) exec /usr/bin/open "$@" ;;
esac
if ssh -o BatchMode=yes -o ConnectTimeout=3 -o StrictHostKeyChecking=accept-new "$host" /usr/bin/open "$url" 2>/dev/null; then
  exit 0
fi
exec /usr/bin/open "$url"
```

要点：只转发 http(s)；`BatchMode=yes` 避免卡在密码提示；远端也用绝对路径 `/usr/bin/open`。`chmod +x`。

### 3.2 Herdr 插件 `config/herdr/plugins/remote-open/`

`herdr-plugin.toml`：

```toml
id = "dotfiles.remote-open"
name = "Remote Open"
version = "0.1.0"
min_herdr_version = "0.7.0"
description = "Ctrl-click any http(s) link to open it on the MacBook that drives this session."
platforms = ["macos"]

[[actions]]
id = "open"
title = "Open link on MacBook"
command = ["bash", "open.sh"]

[[link_handlers]]
id = "any-http"
title = "Open on MacBook"
pattern = "^https?://"
action = "open"
```

`open.sh`：

```sh
#!/usr/bin/env bash
set -euo pipefail
url="${HERDR_PLUGIN_CLICKED_URL:-}"
[ -n "$url" ] || exit 0
exec "$HOME/dotfiles/bin/remote-open" "$url"
```

注册：`herdr plugin link ~/dotfiles/config/herdr/plugins/remote-open`。插件目录放在 dotfiles 里是为了跟着仓库走；link 只是登记路径，不复制文件。

### 3.3 `~/.ssh/config`（不在 dotfiles，手工加）

```
Host macbook
  HostName 100.93.81.16
  User griffin
```

免密：在 Mac mini 上跑一次 `ssh-copy-id griffin@100.93.81.16`（交互输一次 MacBook 密码）。若 MagicDNS 可用，HostName 也可写 `macbook`。

### 3.4 `zshrc`

只在 Mac mini 生效，避免影响 MacBook 上同一份 dotfiles：

```sh
# Mac mini is always driven remotely: route browser opens back to the MacBook.
if [[ "$(hostname -s)" == "Griffins-MacMini" ]]; then
  export BROWSER="$HOME/dotfiles/bin/remote-open"
fi
```

不用 `SSH_CONNECTION` 判断：mosh 会话里它是否存在未验证。

## 4. 步骤

1. 写 `bin/remote-open`，`chmod +x`。
2. 写插件两个文件，`chmod +x open.sh`（保险起见，虽然是 `bash open.sh` 调用）。
3. `herdr plugin link ~/dotfiles/config/herdr/plugins/remote-open` → `herdr plugin action list --plugin dotfiles.remote-open` 应列出 `open`。
4. `~/.ssh/config` 加 Host，`ssh-copy-id griffin@100.93.81.16`，再 `ssh -o BatchMode=yes macbook true` 应静默成功。
5. zshrc 加段落。
6. 验证顺序：
   - `~/dotfiles/bin/remote-open https://example.com` → MacBook 浏览器打开。
   - Herdr 任一 pane 里 **Ctrl+点击** 一个 https 链接 → MacBook 打开；失败看 `herdr plugin log list --plugin dotfiles.remote-open`。
   - 新开 shell（让 `BROWSER` 生效）启动 Claude Code，`/artifacts` 按 `o` → MacBook 打开。

## 5. 注意

- Herdr 只把 **Ctrl+点击** 交给 link handler，普通点击行为不变，Cmd+点击仍被 Herdr 捕获。
- `ssh macbook open` 要求 MacBook 有 GUI 登录会话；锁屏时会排队到解锁后打开。
- 插件 `command` 不经 shell，所以 `open.sh` 里再用绝对路径调 `remote-open`，不要依赖 PATH。
- 备选方案（未采用）：`config/herdr/config.toml` 设 `mouse_capture = false`，把点击交还 Ghostty，代价是 Herdr 鼠标 UI 失效；或在 MacBook 开 Tailscale SSH 省掉密钥管理。
- 完成后可在 `claude/CLAUDE.md` 的"运行环境"一节补一句："浏览器打开已通过 `BROWSER=remote-open` 转发到 MacBook；Herdr 里用 Ctrl+点击。"
