return {
  'tpope/vim-surround',
  config = function()
    -- let g:surround_no_insert_mappings = 1
    -- imap <C-d> <Plug>Isurround
    -- imap <C-e> <Plug>ISurround
  end,
  keys = {
    { '<c-d>', "<Plug>Isurround", mode = 'i', silent = true, buffer = true },
    { '<c-e>', "<Plug>ISurround", mode = 'i', silent = true, buffer = true },
  },
}
