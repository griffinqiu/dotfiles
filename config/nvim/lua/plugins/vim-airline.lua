return {
  'vim-airline/vim-airline',
  config = function()
    vim.cmd[[let g:airline#extensions#gutentags#enabled=1]]
    if vim.fn.exists('g:airline_symbols') == 0 then
      vim.cmd[[let g:airline_symbols={}]]
    end
    vim.cmd[[let g:airline_symbols.maxlinenr='']]
    vim.cmd[[let g:airline_symbols.colnr=':']]
  end,
}
