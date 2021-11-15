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

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
" Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

nnoremap <c-p> <cmd>Telescope git_files theme=dropdown<cr>
nnoremap <leader>ff <cmd>Telescope find_files theme=dropdown<cr>
nnoremap <leader>fg <cmd>Telescope live_grep theme=dropdown<cr>
nnoremap <leader>fb <cmd>Telescope buffers theme=dropdown<cr>
nnoremap <leader>fh <cmd>Telescope oldfiles theme=dropdown<cr>
nnoremap <leader>fH <cmd>Telescope help_tags theme=dropdown<cr>
nnoremap <leader>f/ <cmd>Telescope search_history theme=dropdown<cr>
nnoremap <leader>f: <cmd>Telescope command_history theme=dropdown<cr>
nnoremap <leader>fm <cmd>Telescope marks theme=dropdown<cr>
nnoremap <leader>fq <cmd>Telescope quickfix theme=dropdown<cr>
nnoremap <leader>fl <cmd>Telescope loclist theme=dropdown<cr>
nnoremap <leader>fM <cmd>Telescope keymaps theme=dropdown<cr>
nnoremap <leader>fc <cmd>Telescope git_commits theme=dropdown<cr>
nnoremap <leader>fbc <cmd>Telescope git_bcommits theme=dropdown<cr>
" LSP
nnoremap <leader>fr <cmd>Telescope lsp_references theme=dropdown<cr>
nnoremap <leader>fa <cmd>Telescope lsp_code_actions theme=dropdown<cr>
nnoremap <leader>fi <cmd>Telescope lsp_implementations theme=dropdown<cr>
nnoremap <leader>fd <cmd>Telescope lsp_definitions theme=dropdown<cr>
nnoremap <leader>ft <cmd>Telescope lsp_type_definitions theme=dropdown<cr>
