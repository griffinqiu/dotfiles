return function(use)
  -- use 'yonchu/accelerated-smooth-scroll'
  use 'morhetz/gruvbox'
  vim.g.gruvbox_invert_selection=0
  vim.g.gruvbox_contrast_dark='soft'
  vim.g.gruvbox_contrast_light='soft'
  vim.cmd[[colorscheme gruvbox]]

  use {
    'vim-airline/vim-airline',
    config = function()
      vim.cmd[[let airline#extensions#gutentags#enabled=1]]
      vim.cmd[[let g:airline#extensions#gutentags#enabled=1]]
      vim.cmd[[let g:airline#extensions#tabline#enabled=1]]
      vim.cmd[[let g:airline#extensions#tabline#formatter='unique_tail']]
      vim.cmd[[let g:airline#extensions#tabline#show_buffers=0]]
      vim.cmd[[let g:airline#extensions#tabline#show_splits=0]]
      vim.cmd[[let g:airline#extensions#tabline#show_tabs=1]]
      vim.cmd[[let g:airline#extensions#tabline#show_close_button=0]]
      vim.cmd[[let g:airline#extensions#tabline#tab_min_count=2]]
      if vim.fn.exists('g:airline_symbols') == 0 then
        vim.cmd[[let g:airline_symbols={}]]
      end
      vim.cmd[[let g:airline_symbols.maxlinenr='']]
      vim.cmd[[let g:airline_symbols.colnr=':']]
    end
  }
end
