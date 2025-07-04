-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.api.nvim_set_keymap("n", "<space>", "<nop>", {})
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.ai_partner = "avante"
vim.g.snacks_animate = false
vim.g.minipairs_disable = true
vim.env.USER = "Griffin"
vim.g.root_spec = { ".git", "lsp", "cwd" }

local opt = vim.opt
opt.background = "dark"
opt.autowrite = false
opt.bomb = false
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.clipboard = ""
opt.ruler = true
opt.showcmd = true
opt.showmode = false
opt.wrap = true
opt.linebreak = true
opt.autoread = true
opt.number = true
opt.relativenumber = false
opt.hidden = true
opt.belloff = "all"
opt.joinspaces = false
opt.magic = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.showmatch = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.expandtab = true
opt.scrolloff = 5
opt.sidescroll = 1 -- zh zl
opt.sidescrolloff = 10
opt.undofile = true
opt.tagcase = "match"
opt.colorcolumn = "81"
opt.numberwidth = 4
opt.sidescroll = 1
opt.sidescrolloff = 10
opt.splitbelow = true
opt.splitright = true
opt.equalalways = true
opt.autoindent = true
opt.linespace = 3
opt.history = 1024
opt.undoreload = 1024
opt.timeoutlen = 200
opt.ttimeoutlen = 10
opt.updatetime = 100
opt.matchtime = 2
opt.cmdheight = 2
opt.laststatus = 2
opt.encoding = "utf-8"
opt.fileencodings = "utf-8,chinese,latin-1"
opt.fileformats = "unix,dos,mac"
opt.mouse = ""
vim.wo.foldmethod = "marker"
opt.complete = ".,w,b,t,i,u"
opt.completeopt = { "menuone", "noselect", "noinsert" }

