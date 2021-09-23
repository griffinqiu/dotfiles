" vim: set ft=vim:

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
  let g:completion_enable_snippet = 'vim-vsnip'
  " let g:completion_menu_length=1
  let g:completion_matching_smart_case = 1
  let g:completion_enable_auto_hover = 0
  " let g:completion_enable_auto_signature = 0

Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" Plug 'rafamadriz/friendly-snippets'
  " " Expand
  imap <expr> <C-n>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-n>'
  smap <expr> <C-n>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-n>'

  " " Expand or jump
  imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
  smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

  " " Jump forward or backward
  imap <expr> <c-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<c-j>'
  smap <expr> <c-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<c-j>'
  imap <expr> <c-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<c-k>'
  smap <expr> <c-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<c-k>'

  " " Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
  " " See https://github.com/hrsh7th/vim-vsnip/pull/50
  nmap        s   <Plug>(vsnip-select-text)
  xmap        s   <Plug>(vsnip-select-text)
  nmap        S   <Plug>(vsnip-cut-text)
  xmap        S   <Plug>(vsnip-cut-text)

  " " If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
  let g:vsnip_filetypes = {}
  let g:vsnip_filetypes.javascriptreact = ['javascript']
  let g:vsnip_filetypes.typescriptreact = ['typescript']
