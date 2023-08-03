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
      vim.cmd[[let g:airline#extensions#gutentags#enabled=1]]
      if vim.fn.exists('g:airline_symbols') == 0 then
        vim.cmd[[let g:airline_symbols={}]]
      end
      vim.cmd[[let g:airline_symbols.maxlinenr='']]
      vim.cmd[[let g:airline_symbols.colnr=':']]
    end
  }
end
