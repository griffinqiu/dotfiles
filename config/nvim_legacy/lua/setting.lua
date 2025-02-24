vim.api.nvim_set_keymap("n", "<space>", "<nop>", {})
vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local installed_mapx = vim.fn.stdpath('data')..'/site/pack/packer/start/mapx.nvim'
if vim.fn.empty(vim.fn.glob(installed_mapx)) > 0 then
  vim.fn.system({'git', 'clone', 'https://github.com/b0o/mapx.nvim', installed_mapx})
end
require('mapx').setup{ global = true }


local enable_extra_plugins = vim.g.enable_plugins
  or {
    -- -- Below are the good extra plugins, but they are disabled by default
    -- codecompanion = "no",
    -- avante = "no",
    -- ["no-neck-pain"] = "no",
    -- harpoon = "no",
    -- blink = "no",
    -- magazine = "yes",
    -- snacks = "yes",
    -- lspsaga = "yes",
    -- ["fold-preview"] = "yes",
    -- wakatime = "yes",
  }

local spec = {
  { import = "core.colorscheme" },
  { import = "core.editor" },
  { import = "core.nvim-tree" },
  { import = "core.nvim-treesitter" },
  { import = "plugins" },
}

require("lazy").setup({
  spec = spec,
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

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
vim.o.colorcolumn='81'
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
vim.o.mouse=''
vim.wo.foldmethod='marker'
