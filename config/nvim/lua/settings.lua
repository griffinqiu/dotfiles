local execute = vim.api.nvim_command
local fn = vim.fn

local installed_packer = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(installed_packer)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', installed_packer})
end
execute 'packadd packer.nvim'

local installed_mapx = fn.stdpath('data')..'/site/pack/packer/start/mapx.nvim'
if fn.empty(fn.glob(installed_mapx)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/b0o/mapx.nvim', installed_mapx})
end
execute 'packadd mapx.nvim'
require('mapx').setup{ global = true }

nmap('<space>', '<nop>')
vim.g.mapleader = ' '

vim.o.background='dark'

vim.o.bomb=false
vim.o.backup=false
vim.o.writebackup=false
vim.o.swapfile=false
vim.o.ruler=true
vim.o.showcmd=true
vim.o.showmode=true
vim.o.wrap=true
vim.o.linebreak=true
vim.o.autoread=true
vim.o.number=false
vim.o.relativenumber=false
vim.o.hidden=true
vim.o.belloff='all'
vim.o.joinspaces=false
vim.o.magic=true
vim.o.ignorecase=true
vim.o.smartcase=true
vim.o.hlsearch=true
vim.o.incsearch=true
vim.o.showmatch=true
vim.o.ruler=true
-- vim.o.lazyredraw=true

vim.o.shiftwidth=2
vim.o.softtabstop=2
vim.o.tabstop=2
vim.o.expandtab=true
vim.o.scrolloff=5
vim.o.sidescroll=1 -- zh zl
vim.o.sidescrolloff=10


vim.o.undofile=true
vim.o.undodir= vim.fn.stdpath('cache') .. '/undoes'
vim.o.tagcase='match'
vim.o.backupdir= vim.fn.stdpath('cache') .. '/backups'
vim.o.colorcolumn=81
vim.o.numberwidth=4
vim.o.sidescroll=1
vim.o.sidescrolloff=10
vim.o.splitbelow=true
vim.o.splitright=true
vim.o.equalalways=true
vim.o.autoindent=true
vim.o.linespace=3
vim.o.history=1024
vim.o.undoreload=1024
vim.o.timeoutlen=500
vim.o.ttimeoutlen=10
vim.o.updatetime=100
vim.o.matchtime=2
vim.o.cmdheight=2
vim.o.laststatus=2

vim.o.spellfile='~/Sync/vim-spell-en.utf-8.add'
vim.cmd[[set nospell spelllang=en_us,cjk]]

vim.o.encoding='utf-8'
vim.o.fileencodings='utf-8,chinese,latin-1'
vim.o.fileformats='unix,dos,mac'
vim.o.ttymouse='xterm2'
