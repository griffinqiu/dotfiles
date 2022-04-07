" vim: set ft=vim:

Plug 'neovim/nvim-lspconfig'
  autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.go lua goimports(1000)
Plug 'williamboman/nvim-lsp-installer'
Plug 'ray-x/lsp_signature.nvim'
Plug 'stevearc/aerial.nvim'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
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
Plug 'onsails/lspkind-nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'crispgm/telescope-heading.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

nnoremap <c-p> <cmd>Telescope git_files theme=get_ivy<cr>
nnoremap <leader>ff <cmd>Telescope find_files theme=get_ivy<cr>
nnoremap <leader>fg <cmd>Telescope live_grep theme=get_ivy<cr>
nnoremap <leader>fb <cmd>Telescope buffers theme=get_ivy<cr>
nnoremap <leader>fH <cmd>Telescope help_tags theme=get_ivy<cr>
nnoremap <leader>f/ <cmd>Telescope search_history theme=get_ivy<cr>
nnoremap <leader>f: <cmd>Telescope command_history theme=get_ivy<cr>
nnoremap <leader>fm <cmd>Telescope marks theme=get_ivy<cr>
nnoremap <leader>fq <cmd>Telescope quickfix theme=get_ivy<cr>
nnoremap <leader>fl <cmd>Telescope loclist theme=get_ivy<cr>
nnoremap <leader>fM <cmd>Telescope keymaps theme=get_ivy<cr>
nnoremap <leader>fc <cmd>Telescope git_commits theme=get_ivy<cr>
nnoremap <leader>fC <cmd>Telescope commands theme=get_ivy<cr>
nnoremap <leader>fB <cmd>Telescope git_bcommits theme=get_ivy<cr>
nnoremap <leader>fh <cmd>Telescope heading theme=get_ivy<cr>
" LSP
nnoremap <leader>fr <cmd>Telescope lsp_references theme=get_ivy<cr>
nnoremap <leader>fa <cmd>Telescope lsp_code_actions theme=get_ivy<cr>
nnoremap <leader>fi <cmd>Telescope lsp_implementations theme=get_ivy<cr>
nnoremap <leader>fd <cmd>Telescope lsp_definitions theme=get_ivy<cr>
nnoremap <leader>ft <cmd>Telescope lsp_type_definitions theme=get_ivy<cr>
