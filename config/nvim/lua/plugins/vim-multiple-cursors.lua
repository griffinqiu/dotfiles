return {
  "terryma/vim-multiple-cursors",
  config = function()
    vim.g.multi_cursor_start_key = '<c-n>'
    vim.g.multi_cursor_start_word_key = 'g<c-n>'
    vim.g.multi_cursor_quit_key = '<Esc>'
  end,
}
