local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
  vim.keymap.set('n', 'p', api.node.open.preview, opts('Open Preview'))
  vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
  vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
  vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
  vim.keymap.set('n', '<c-k>', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  vim.keymap.set('n', '<c-j>', api.node.navigate.sibling.next, opts('Next Sibling'))
  vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
  vim.keymap.set('n', 'ma', api.fs.create, opts('Create'))
  vim.keymap.set('n', 'md', api.fs.remove, opts('Delete'))
  vim.keymap.set('n', 'mo', api.node.run.system, opts('Run System'))
  vim.keymap.set('n', 'mr', api.fs.rename, opts('Rename'))
  vim.keymap.set('n', 'mm', api.fs.rename_sub,                     opts('Rename: Omit Filename'))
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
  vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', 'X', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  vim.keymap.set('n', 'x', api.tree.collapse_all, opts('Collapse'))
  vim.keymap.set('n', '<c-x>', api.fs.cut, opts('Cut'))
  vim.keymap.set('n', '<c-c>', api.fs.copy.node, opts('Copy'))
  vim.keymap.set('n', '<c-p>', api.fs.paste, opts('Paste'))
end

require("nvim-tree").setup({
  on_attach = on_attach,
  respect_buf_cwd     = true,
  disable_netrw       = false,
  hijack_netrw        = true,
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  open_on_tab         = false,
  hijack_cursor       = true,
  update_cwd          = true,
  hijack_unnamed_buffer_when_opening = false,
  diagnostics         = {
    enable = false,
    icons  = {
      hint    = "",
      info    = "",
      warning = "",
      error   = "",
    }
  },
  actions = {
    open_file = {
      resize_window = true,
      window_picker = {
        enable = false,
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame", },
          buftype  = { "nofile", "terminal", "help", },
        }
      },
    },
  },
  update_focused_file = {
    enable      = false,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 40,
    hide_root_folder = false,
    side = 'left',
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
})
nnoremap("<leader>1", ":NvimTreeToggle<CR>", "silent")
nnoremap("<leader>nf", ":NvimTreeFindFile<CR>10<c-w>h", "silent")
