return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<c-i>", desc = "Increment Selection", mode = { "x", "n" } },
        { "<BS>", desc = "Decrement Selection", mode = "x" },
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "RRethy/nvim-treesitter-textsubjects",
    },
    build = ":TSUpdate",
    event = { "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    opts_extend = { "ensure_installed" },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "bash",
          "regex",
          'diff',
          'css',
          'sql',
          'go',
          'html',
          'javascript',
          "json",
          "json5",
          "jsonc",
          "proto",
          'lua',
          'make',
          'markdown',
          "markdown_inline",
          'php',
          'python',
          'ruby',
          'rust',
          'vim',
          'vue',
          'yaml',
          'gitcommit',
          'git_rebase',
        }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        sync_install = false,            -- install languages synchronously (only applied to `ensure_installed`)
        auto_install = true,            -- Automatically install missing parsers when entering buffer
        ignore_install = { "haskell" },  -- list of parsers to ignore installing
        highlight = {
          enable = true,
          -- disable = { "c", "rust" },  -- list of language that will be disabled
          -- additional_vim_regex_highlighting = false,
        },

        -- incremental_selection = {
          -- enable = false,
        -- },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-i>",
            node_incremental = "<c-i>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
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
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
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
    end,
  },

  -- Use treesitter to auto close and auto rename html tag
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPre",
    opts = {},
  },
  -- Auto highlight word under cursor
  {
    "echasnovski/mini.cursorword",
    event = "LspAttach",
    opts = { delay = 100 },
  },
}
