require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'css',
    'go',
    'html',
    'javascript',
    'json',
    'lua',
    'make',
    'php',
    'python',
    'ruby',
    'rust',
    'vim',
    'vue',
    'yaml',
  }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false,            -- install languages synchronously (only applied to `ensure_installed`)
  auto_install = true,            -- Automatically install missing parsers when entering buffer
  ignore_install = { "haskell" },  -- list of parsers to ignore installing
  highlight = {
    enable = true,
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- additional_vim_regex_highlighting = false,
  },

  incremental_selection = {
    enable = false,
  },

  indent = {
    enable = true
  },

  rainbow = {
    enable = true
  },

  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },

  textobjects = {
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]]"] = "@function.outer",
        ["]m"] = "@class.outer",
      },
      goto_next_end = {
        ["]["] = "@function.outer",
        ["]M"] = "@class.outer",
      },
      goto_previous_start = {
        ["[["] = "@function.outer",
        ["[m"] = "@class.outer",
      },
      goto_previous_end = {
        ["[]"] = "@function.outer",
        ["[M"] = "@class.outer",
      },
    },
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },

  textsubjects = {
      enable = true,
      keymaps = {
          ['<cr>'] = 'textsubjects-smart', -- works in visual mode
      }
    },
}
vim.wo.foldmethod = 'marker'
-- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
