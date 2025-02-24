local M = {}

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>f", group = "file/find", mode = { "n", "v" } },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    config = function()
      local actions    = require('telescope.actions')
      local previewers = require('telescope.previewers')
      local builtin    = require('telescope.builtin')
      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case'
          },
          layout_config = {
            horizontal = {
              mirror = false,
            },
            vertical = {
              mirror = false,
            },
            prompt_position = "top",
          },
          file_sorter      = require('telescope.sorters').get_fzy_sorter,
          prompt_prefix    = ' 🔍 ',
          color_devicons   = true,

          sorting_strategy = "ascending",

          file_previewer   = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer   = require('telescope.previewers').vim_buffer_vimgrep.new,
          qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

          mappings = {
            i = {
              ["<C-x>"] = false,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist,
              ["<C-s>"] = actions.cycle_previewers_next,
              ["<C-a>"] = actions.cycle_previewers_prev,
            },
            n = {
              ["<C-s>"] = actions.cycle_previewers_next,
              ["<C-a>"] = actions.cycle_previewers_prev,
            }
          }
        },
        extensions = {
          fzf = {
            override_generic_sorter = false,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      }

      require('telescope').load_extension('fzf')
      require('telescope').load_extension('repo')

      -- nnoremap('<c-p>', "<CMD>lua require('plugins.telescope').project_files()<CR>")
      -- nnoremap('<leader>ff', "<CMD>lua require('plugins.telescope').find_files()<CR>")


      local delta_bcommits = previewers.new_termopen_previewer {
        get_command = function(entry)
          return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!', '--', entry.current_file }
        end
      }

      local delta = previewers.new_termopen_previewer {
        get_command = function(entry)
          return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!' }
        end
      }

      M.my_git_commits = function(opts) opts = opts or {}
        opts.previewer = {
          delta,
          previewers.git_commit_message.new(opts),
          previewers.git_commit_diff_as_was.new(opts),
        }

        builtin.git_commits(opts)
      end

      M.my_git_bcommits = function(opts)
        opts = opts or {}
        opts.previewer = {
          delta_bcommits,
          previewers.git_commit_message.new(opts),
          previewers.git_commit_diff_as_was.new(opts),
        }

        builtin.git_bcommits(opts)
      end

      M.edit_neovim = function()
        builtin.git_files {
          cwd = "~/.config/nvim",
          prompt = "~ dotfiles ~",
          color_devicons   = true,
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              mirror = false,
            },
            vertical = {
              mirror = false,
            },
            prompt_position = "top",
          },
        }
      end

      M.project_files = function()
        local opts = require('telescope.themes').get_ivy({})
        local ok = pcall(require'telescope.builtin'.git_files, opts)
        if not ok then require"telescope.builtin".find_files(opts) end
      end
    end,
    dependencies = {
      { 'nvim-lua/popup.nvim' },
      { 'nvim-lua/plenary.nvim' },
      {'cljoly/telescope-repo.nvim'},
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = "make",
      },
    },
    keys = {
      { "<C-p>", function() M.project_files() end, desc = "Telescope project_files", mode ="n" },
      { "<leader>fp", function() M.project_files() end, desc = "Telescope project_files", mode ="n" },
      { '<leader>ff', '<CMD>Telescope find_files theme=get_ivy<cr>', desc = "Telescope find_files", mode ="n" },
      { "<leader>fs", "<CMD>Telescope live_grep theme=get_ivy<cr>", desc = "Telescope live_grep", mode ="n" },
      { '<leader>fb', '<CMD>Telescope buffers theme=get_ivy<cr>', desc = "Telescope buffers", mode ="n" },
      { '<leader>fh', '<CMD>Telescope oldfiles theme=get_ivy<cr>', desc = "Telescope oldfiles", mode ="n" },
      { '<leader>fH', '<CMD>Telescope help_tags theme=get_ivy<cr>', desc = "Telescope help_tags", mode ="n" },
      { '<leader>f/', '<CMD>Telescope search_history theme=get_ivy<cr>', desc = "Telescope search_history", mode ="n" },
      { '<leader>f:', '<CMD>Telescope command_history theme=get_ivy<cr>', desc = "Telescope command_history", mode ="n" },
      { '<leader>fm', '<CMD>Telescope marks theme=get_ivy<cr>', desc = "Telescope marks", mode ="n" },
      { '<leader>fq', '<CMD>Telescope quickfix theme=get_ivy<cr>', desc = "Telescope quickfix", mode ="n" },
      { '<leader>fl', '<CMD>Telescope loclist theme=get_ivy<cr>', desc = "Telescope loclist", mode ="n" },
      { '<leader>fM', '<CMD>Telescope keymaps theme=get_ivy<cr>', desc = "Telescope keymaps", mode ="n" },
      { '<leader>fC', '<CMD>Telescope git_commits theme=get_ivy<cr>', desc = "Telescope git_commits", mode ="n" },
      { '<leader>fB', '<CMD>Telescope git_bcommits theme=get_ivy<cr>', desc = "Telescope git_bcommits", mode ="n" },
      -- LSP
      { '<leader>fr', '<cmd>Telescope lsp_references theme=get_ivy<cr> theme=get_ivy<cr>', desc = "Telescope lsp_references", mode ="n" },
      { '<leader>fi', '<cmd>Telescope lsp_implementations theme=get_ivy<cr> theme=get_ivy<cr>', desc = "Telescope lsp_implementations", mode ="n" },
      { '<leader>fa', '<cmd>Telescope lsp_code_actions theme=get_ivy<cr> theme=get_ivy<cr>', desc = "Telescope lsp_code_actions", mode ="n" },
      -- { '<leader>fd', '<cmd>Telescope lsp_definitions theme=get_ivy<cr> theme=get_ivy<cr>', desc = "Telescope lsp_definitions", mode ="n" },
      -- { '<leader>ft', '<cmd>Telescope lsp_type_definitions theme=get_ivy<cr> theme=get_ivy<cr>', desc = "Telescope lsp_type_definitions", mode ="n" },
    },
  },
}
