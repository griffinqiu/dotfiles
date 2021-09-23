Plug 'neovim/nvim-lspconfig'
  autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.go lua goimports(1000)
Plug 'nvim-lua/completion-nvim'
  autocmd BufEnter * lua require'completion'.on_attach()
  imap <tab> <Plug>(completion_smart_tab)
  " " Set completeopt to have a better completion experience
  set completeopt=menuone,noinsert,noselect
  " " Avoid showing message extra message when using completion
  set shortmess+=c
  let g:completion_enable_auto_popup = 0
  let g:completion_enable_snippet = 'UltiSnips'
  let g:completion_menu_length=1
  let g:completion_matching_smart_case = 1
  " let g:completion_enable_auto_hover = 0
  " let g:completion_enable_auto_signature = 0
