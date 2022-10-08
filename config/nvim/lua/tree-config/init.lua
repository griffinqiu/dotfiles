local keymappings = {
  { key = {"<CR>", "o"},              action = "edit" },
  { key = {"p"},                      action = "preview" },
  { key = "v",                        action = "vsplit" },
  { key = "s",                        action = "split" },
  { key = "t",                        action = "tabnew" },
  { key = "<c-k>",                    action = "prev_sibling" },
  { key = "<c-j>",                    action = "next_sibling" },
  { key = {"C"},                      action = "cd" },
  { key = "K",                        action = "first_sibling" },
  { key = "J",                        action = "last_sibling" },
  { key = "I",                        action = "toggle_ignored" },
  { key = "H",                        action = "toggle_dotfiles" },
  { key = "R",                        action = "refresh" },
  { key = "ma",                       action = "create" },
  { key = "md",                       action = "remove" },
  { key = "mo",                       action = "system_open" },
  { key = "mr",                       action = "rename" },
  { key = "[c",                       action = "prev_git_item" },
  { key = "]c",                       action = "next_git_item" },
  { key = "q",                        action = "close" },
  { key = "?",                        action = "toggle_help" },
  { key = "X",                        action = "collapse_all" },
  { key = "P",                        action = "parent_node" },
  { key = "x",                        action = "collapse_all" },
  { key = "<c-x>",                    action = "cut" },
  { key = "<c-c>",                    action = "copy" },
  { key = "<c-p>",                    action = "paste" },
}

require'nvim-tree'.setup {
  respect_buf_cwd     = true,
  -- disables netrw completely
  disable_netrw       = false,
  -- hijack netrw window on startup
  hijack_netrw        = true,
  -- open the tree when running this setup function
  open_on_setup       = false,
  -- will not open on setup if the filetype is in this list
  ignore_ft_on_setup  = {},
  -- closes neovim automatically when the tree is the last **WINDOW** in the view
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  open_on_tab         = false,
  -- hijack the cursor in the tree to put it at the start of the filename
  hijack_cursor       = true,
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_cwd          = true,
  -- opens in place of the unnamed buffer if it's empty
  hijack_unnamed_buffer_when_opening = false,
  -- show lsp diagnostics in the signcolumn
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
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable      = false,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd  = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  -- configuration options for the system open command (`s` in the tree by default)
  system_open = {
    -- the command to run this, leaving nil should work in most cases
    cmd  = nil,
    -- the command arguments as a list
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
    -- width of the window, can be either a number (columns) or a string in `%`
    width = 40,
    hide_root_folder = false,
    -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    side = 'left',
    mappings = {
      -- custom only false will merge the list with the default mappings
      -- if true, it will only use your list to set the mappings
      custom_only = true,
      -- list of mappings to set on the tree manually
      list = keymappings
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes",
  },
}
nnoremap("<leader>1", "<cmd>lua require'nvim-tree'.toggle()<CR>", "silent")
nnoremap("<leader>nf", "<cmd>lua require'nvim-tree'.find_file()<CR>10<c-w>h", "silent")
