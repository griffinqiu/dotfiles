-- generate_tmux_theme.lua
local lualine_theme = require("lualine.themes.tokyonight") -- 替换为你的主题名

-- 提取颜色变量（严格匹配 lualine 结构）
local colors = {
  normal = {
    a = lualine_theme.normal.a,
    b = lualine_theme.normal.b,
    c = lualine_theme.normal.c,
  },
  insert = lualine_theme.insert.a,
  visual = lualine_theme.visual.a,
  bg = lualine_theme.normal.c.bg, -- 主背景色
  fg = lualine_theme.normal.b.fg, -- 默认文字色
}

-- 生成 tmux 配置（修复颜色和符号方向）
local tmux_conf = string.format(
  [[
# Generated by lualine-to-tmux (修正版)

# 真彩色支持
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# 基础样式
set -g status-style "bg=%s,fg=%s"
set -g pane-border-style "fg=%s"
set -g pane-active-border-style "fg=%s"
set -g message-style "bg=%s,fg=%s"
set -g mode-style "bg=%s,fg=%s"

# 状态栏左侧（会话名）
set -g status-left "#[bg=%s,fg=%s,bold]  #S #[bg=%s,fg=%s,nobold]"

# 窗口列表
setw -g window-status-format "#[fg=%s,bg=%s] #I: #W "
setw -g window-status-current-format "#[fg=%s,bg=%s,bold]#[fg=%s,bg=%s]#I: #W #[fg=%s,bg=%s]"

# 状态栏右侧（时间、日期）
set -g status-right "#[fg=%s,bg=%s]#[fg=%s,bg=%s] %%H:%%M #[fg=%s,bg=%s]#[fg=%s,bg=%s] %%Y-%%m-%%d "

# 高亮配置（复制模式）
set -g @prefix_highlight_copy_mode_attr "bg=%s,fg=%s"
]],
  -- 基础样式
  colors.bg,
  colors.fg, -- status-style
  colors.normal.b.bg, -- pane-border-style (非活动边框)
  colors.normal.a.bg, -- pane-active-border (活动边框)
  colors.normal.a.bg,
  colors.normal.a.fg, -- message-style (提示消息)
  colors.visual.bg,
  colors.visual.fg, -- mode-style (复制模式)

  -- 状态栏左侧
  colors.normal.a.bg,
  colors.normal.a.fg, -- 会话名背景/文字
  colors.bg,
  colors.normal.a.bg, -- 右侧箭头颜色过渡

  -- 窗口列表
  colors.fg,
  colors.bg, -- 非活动窗口文字/背景
  colors.normal.a.bg,
  colors.normal.a.fg, -- 当前窗口左侧箭头 (背景/文字)
  colors.normal.a.fg,
  colors.normal.a.bg, -- 当前窗口文字/背景
  colors.normal.a.bg,
  colors.bg, -- 当前窗口右侧箭头 (背景/文字)

  -- 状态栏右侧
  colors.insert.bg,
  colors.bg, -- 时间左侧箭头 (背景过渡)
  colors.insert.fg,
  colors.insert.bg, -- 时间文字/背景
  colors.visual.bg,
  colors.insert.bg, -- 日期左侧箭头 (背景过渡)
  colors.visual.fg,
  colors.visual.bg, -- 日期文字/背景

  -- 复制模式高亮
  colors.visual.bg,
  colors.visual.fg
)

-- 保存到文件
local file = io.open("tmux_tokyonight.conf", "w")
file:write(tmux_conf)
file:close()

print("生成完成！保存为 tmux_tokyonight.conf")
