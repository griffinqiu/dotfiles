return function(use)
  -- use{'mxw/vim-jsx', ft = {'javascript' }}
  -- use('chrisbra/csv.vim')

  -- use{'Keithbsmiley/rspec.vim', ft = {'ruby'}}
  -- use{'ecomba/vim-ruby-refactoring', ft = {'ruby'}}
  -- use{'vim-ruby/vim-ruby', ft = {'ruby' }}
  -- use{'tpope/vim-rails', ft = {'ruby', 'eruby'}}
  -- use{'tpope/vim-rbenv', ft = {'ruby' }}
  -- use{'tpope/vim-bundler', ft = {'ruby'}}
  -- use{'tpope/vim-pathogen', ft = {'ruby' }}
  use('AndrewRadev/switch.vim')
  vim.g.switch_mapping = "-"

  -- use('plasticboy/vim-markdown')
  -- use('mzlogin/vim-markdown-toc')
  -- vim.g.vim_markdown_folding_disabled=1
  -- vim.g.vim_markdown_initial_foldlevel=1

  -- use {
    -- 'fatih/vim-go',
    -- run = ':GoUpdateBinaries',
    -- config = 'require("go-config")',
  -- }
  -- use {
    -- -- 'yriveiro/dap-go.nvim',
    -- 'jhchabran/dap-go.nvim',
    -- branch = 'hotfix',
    -- -- '~/perso/dap-go.nvim',
    -- requires = { {'nvim-lua/plenary.nvim'} },
    -- config = function()
      -- require('dap-go').setup()
    -- end
  -- }
  use { "golang/vscode-go" }
  use { 'ray-x/go.nvim', config = function()
    require('go').setup()
  end}

  -- Treesitter
  use {'nvim-treesitter/nvim-treesitter', config = "require('treesitter-config')"}
  use {'nvim-treesitter/nvim-treesitter-textobjects', after = {'nvim-treesitter'}}
  use {'RRethy/nvim-treesitter-textsubjects', after = {'nvim-treesitter'}}

  use{
    'github/copilot.vim',
    setup = function()
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
        ["DressingInput"] = false,
      }
    end,
  }
  vim.g.copilot_no_tab_map = true
  vim.cmd([[imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")]])
end
