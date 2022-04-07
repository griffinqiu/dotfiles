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

local M = {}

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

M.my_git_commits = function(opts)
  opts = opts or {}
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
  local opts = {} -- define here if you want to define something
  local ok = pcall(require"telescope.builtin".git_files, opts)
  if not ok then require"telescope.builtin".find_files(opts) end
end

-- nnoremap("<C-p>", "<CMD>lua require('telescope-config').project_files() theme=ivy<CR>")
nnoremap('<C-p>', '<CMD>Telescope git_files theme=get_ivy<cr>')
nnoremap('<leader>ff', '<CMD>Telescope find_files theme=get_ivy<cr>')
nnoremap("<leader>fs", "<CMD>Telescope live_grep<CR> theme=get_ivy<cr>")
nnoremap('<leader>fg', '<CMD>Telescope live_grep<cr> theme=get_ivy<cr>')
nnoremap('<leader>fb', '<CMD>Telescope buffers<cr> theme=get_ivy<cr>')
nnoremap('<leader>fh', '<CMD>Telescope oldfiles<cr> theme=get_ivy<cr>')
nnoremap('<leader>fH', '<CMD>Telescope help_tags<cr> theme=get_ivy<cr>')
nnoremap('<leader>f/', '<CMD>Telescope search_history<cr> theme=get_ivy<cr>')
nnoremap('<leader>f:', '<CMD>Telescope command_history<cr> theme=get_ivy<cr>')
nnoremap('<leader>fm', '<CMD>Telescope marks<cr> theme=get_ivy<cr>')
nnoremap('<leader>fq', '<CMD>Telescope quickfix<cr> theme=get_ivy<cr>')
nnoremap('<leader>fl', '<CMD>Telescope loclist<cr> theme=get_ivy<cr>')
nnoremap('<leader>fM', '<CMD>Telescope keymaps<cr> theme=get_ivy<cr>')
nnoremap('<leader>fc', '<CMD>Telescope git_commits<cr> theme=get_ivy<cr>')
nnoremap('<leader>fbc', '<CMD>Telescope git_bcommits<cr> theme=get_ivy<cr>')
-- LSP
nnoremap('<leader>fr', '<cmd>Telescope lsp_references theme=get_ivy<cr> theme=get_ivy<cr>')
nnoremap('<leader>fa', '<cmd>Telescope lsp_code_actions theme=get_ivy<cr> theme=get_ivy<cr>')
nnoremap('<leader>fi', '<cmd>Telescope lsp_implementations theme=get_ivy<cr> theme=get_ivy<cr>')
nnoremap('<leader>fd', '<cmd>Telescope lsp_definitions theme=get_ivy<cr> theme=get_ivy<cr>')
nnoremap('<leader>ft', '<cmd>Telescope lsp_type_definitions theme=get_ivy<cr> theme=get_ivy<cr>')

return M
