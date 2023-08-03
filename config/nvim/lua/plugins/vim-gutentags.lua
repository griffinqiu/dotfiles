return {
  "ludovicchabant/vim-gutentags",
  config = function()
    -- Config g:gutentags_ctags_extra_args in ~/ctags.d/config.ctags
    vim.g.gutentags_project_root = { '.root', '.svn', '.git', '.project' }
    vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
    vim.g.gutentags_generate_on_write = 1
    vim.g.gutentags_generate_on_missing = 0
    vim.g.gutentags_generate_on_new = 0
    vim.g.gutentags_ctags_exclude_wildignore = 1
  end,
}
