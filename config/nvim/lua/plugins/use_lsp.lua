return function(use)
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/nvim-lsp-installer',
    },
    config = [[require('lsp')]]
  }
  vim.api.nvim_command('autocmd BufWritePre *.go lua vim.lsp.buf.formatting()')
  vim.api.nvim_command('autocmd BufWritePre *.go lua goimports(1000)')

  use('ray-x/lsp_signature.nvim')
  use('stevearc/aerial.nvim')

  -- LSP Cmp
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lua',
      'f3fora/cmp-spell',
      'onsails/lspkind-nvim',
      'ray-x/cmp-treesitter',
      'lukas-reineke/cmp-under-comparator',
      -- snippets
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
      'rafamadriz/friendly-snippets',
      'quoyi/rails-vscode',
    },
    config = [[require('cmp-config')]]
  }

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    config = "require('telescope-config')",
    requires = {
      {'nvim-lua/popup.nvim'},
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim'}
    }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {'cljoly/telescope-repo.nvim'}
end
