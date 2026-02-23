---
name: dotfiles-theme
description: 管理 dotfiles 中所有工具的配色方案。当用户需要切换主题或更新配色时使用。
---

# Dotfiles Theme Skill

这个 dotfiles 仓库中所有工具的配色需要保持一致。本 skill 说明每个工具的配色位置、规范和修改方法。

---

## 配色文件位置

| 工具 | 文件 | 配置方式 |
|------|------|---------|
| Neovim | `config/nvim/lua/plugins/colorscheme.lua` | 主题名字符串 |
| tmux | `tmux.conf` | 插件选项变体名 |
| Ghostty | `config/ghostty/colors` | 单一颜色文件，切换时更新内容 |
| Kitty | `config/kitty/colors.conf` | 单一颜色文件，切换时更新内容 |
| Zellij | `config/zellij/themes/colors.kdl` | 单一颜色文件，切换时更新内容 |
| interestingwords | `config/nvim/lua/plugins/misc.lua` 和 `vimrc.bundles` | 硬编码 hex，从当前主题 bright 色取最易辨认的亮色 |
| fzf | `zshrc` | 硬编码 hex，注释标注主题名 |
| aider | `aider.conf.yml` | 硬编码 hex，注释标注主题名 |
| lazygit | `config/lazygit/config.yml` | 硬编码 hex，注释标注主题名 |
| Claude 状态栏 | `claude/statusline-command.sh` | 硬编码 hex，注释标注主题名 |

---

## 各工具规范

### 单一颜色文件的工具

**Ghostty、Kitty、Zellij** 遵循"每种工具只有一个颜色配置文件"的规范：

- **绝对禁止新建颜色文件**——无论添加什么主题，只能编辑现有的单一颜色文件
- 切换主题时：直接用新主题的颜色值**替换**文件内容，同时更新文件顶部的注释标注当前主题名
- 主配置文件（`config/ghostty/config`、`config/kitty/kitty.conf`、`config/zellij/config.kdl`）里的引用路径/名称也需同步更新

Zellij 的单一颜色文件 `colors.kdl` 里定义了一个命名主题块，需要同时更新：
1. `colors.kdl` 里的主题名（如 `kanagawa-dragon { ... }` 改为 `tokyonight_moon { ... }`）及其颜色值
2. `config.kdl` 里的 `theme "name"` 引用

Ghostty 和 Kitty 的颜色文件只含颜色值，主配置引用路径固定不变，只需更新颜色文件内容即可。

### tmux powerkit

tmux powerkit 的主题文件由插件自身管理，**不能往插件目录里添加或修改文件**。

- 主配置（`tmux.conf`）只写变体名：`@powerkit_theme_variant`
- 只能使用插件已有的变体。如果目标主题没有对应变体，选视觉上最接近的已有变体

### 硬编码 hex 的工具

**fzf（zshrc）、aider（aider.conf.yml）、lazygit（config/lazygit/config.yml）、Claude 状态栏（claude/statusline-command.sh）** 直接写 hex 颜色值：

- 颜色值上方必须有注释，注明当前使用的主题名及来源链接
- 切换主题时，注释和所有颜色值一起更新
- fzf 的 `bg+`（选中行背景）对应终端的 `selection-background`，该颜色不在终端 16 色调色板内，必须硬编码

---

## 颜色来源策略

修改前先确定颜色来源，按优先级：

### 1. Neovim 主题插件的 extras 目录（最权威）

很多主题插件会为各种终端工具预生成配色文件。安装后可在本地直接读取：

```
~/.local/share/nvim/lazy/<theme-plugin>/extras/
```

里面通常包含针对 fzf、ghostty、kitty、aider 等工具的完整配色文件，**优先从这里复制**，这是主题作者的官方适配。

### 2. 主题插件的颜色定义源文件

如果 extras 没有覆盖目标工具，从插件的颜色定义源文件里取语义颜色变量（如 `bg`、`red`、`blue` 等），再手动映射到目标工具：

```
~/.local/share/nvim/lazy/<theme-plugin>/lua/<plugin>/colors/
```

### 3. 对比多个来源

如果有多个可用来源（如 Neovim 插件 extras 和 tmux 插件主题文件），选覆盖颜色数量更多、更完整的那个。

---

## 切换主题操作步骤

**第一步：获取颜色值**

从 Neovim 插件 extras 目录读取新主题针对各工具的预生成配色文件。

**第二步：更新只改名称/路径的工具**

1. `config/nvim/lua/plugins/colorscheme.lua` — `style` 和 `colorscheme` 字段
2. `tmux.conf` — `@powerkit_theme_variant`（确认插件有该变体，否则选最接近的）

**第三步：更新单一颜色文件的工具**

3. `config/ghostty/colors` — 替换全部颜色值，更新顶部注释主题名（主配置路径不变）
4. `config/kitty/colors.conf` — 替换全部颜色值，更新顶部注释主题名（主配置路径不变）
5. `config/zellij/themes/colors.kdl` — 替换颜色值和主题块名称，同时更新 `config/zellij/config.kdl` 里的 `theme "name"`

**第四步：更新硬编码 hex 的工具**

6. `config/nvim/lua/plugins/misc.lua` — `colors` 数组：从当前主题调色板的 bright 色（color9–color15）中取 7 个最易辨认的亮色，替换数组内容
   `vimrc.bundles` — `g:interestingWordsGUIColors` 数组：同上，保持与 misc.lua 一致（`g:interestingWordsTermColors` 使用终端颜色索引，无需修改）
7. `zshrc` — fzf 配色块：更新注释主题名，替换全部颜色值（从 extras/fzf 复制）
7. `aider.conf.yml` — 更新注释主题名，替换全部颜色值（从颜色定义源文件取语义变量）
8. `config/lazygit/config.yml` — 更新注释主题名，替换 `gui.theme` 下全部颜色值（从 extras/lazygit 或颜色定义源文件取值）
9. `claude/statusline-command.sh` — 更新注释主题名，替换顶部的 hex 颜色变量
