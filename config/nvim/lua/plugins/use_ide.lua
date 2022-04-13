return function(use)
	use {
    'scrooloose/nerdcommenter',
    config = function()
      vim.g.NERDSpaceDelims = 1
    end
  }

  use('griffinqiu/star-search')
  use('griffinqiu/powerful-vim')
  use('dyng/ctrlsf.vim')
  vim.g.ctrlsf_mapping = {
    next = "<c-n>",
    prev = "<c-p>",
  }
  vim.g.ctrlsf_auto_close = 0
  vim.g.ctrlsf_open_left = 0
  vim.g.ctrlsf_position = 'right'
  vim.g.ctrlsf_winsize = '30%'
  vim.g.ctrlsf_ignore_dir = { 'node_modules', 'build', 'tmp', 'proto' }
  vim.g.ctrlsf_position = 'right'
  nmap('<C-G>g', '<Plug>CtrlSFPrompt')
  nmap('<C-G>G', '<Plug>CtrlSFCwordPath')
  nmap('<C-G><C-G>', '<Plug>CtrlSFCwordExec')
  vmap('<C-G>g', '<Plug>CtrlSFVwordPath')
  vmap('<C-G><C-G>', '<Plug>CtrlSFVwordExec')
  nmap('<C-G>p', '<Plug>CtrlSFPwordPath')
  nmap('<C-G><C-P>', '<Plug>CtrlSFPwordExec')
  nnoremap('<C-G><C-O>', ':CtrlSFOpen<CR>')
  nmap('<C-G>l', '<Plug>CtrlSFQuickfixPrompt')
  vmap('<C-G>l', '<Plug>CtrlSFQuilkfixVwordPath')
  vmap('<C-G>L', '<Plug>CtrSFQuickfixVwordPath')
  vmap('<C-G><C-L>', '<Plug>CtrlSFQuickfixVwordExec')
  nmap('<leader>3', ':CtrlSFToggle<CR>')
  nnoremap('\\', ':CtrlSF<SPACE>')

  use('terryma/vim-multiple-cursors')
  vim.g.multi_cursor_start_key = '<c-n>'
  vim.g.multi_cursor_start_word_key = 'g<c-n>'
  vim.g.multi_cursor_quit_key = '<Esc>'

  use('Lokaltog/vim-easymotion')
  nmap("'", "<Plug>(easymotion-prefix)", 'buffer')
  nmap("<leader>'", '<Plug>(easymotion-overwin-w)', 'buffer')

  use('ludovicchabant/vim-gutentags')
  -- Config g:gutentags_ctags_extra_args in ~/ctags.d/config.ctags
  vim.g.gutentags_project_root = { '.root', '.svn', '.git', '.project' }
  vim.g.gutentags_cache_dir = vim.fn.stdpath('cache') .. '/tags'
  vim.g.gutentags_generate_on_write = 1
  vim.g.gutentags_generate_on_missing = 0
  vim.g.gutentags_generate_on_new = 0
  vim.g.gutentags_ctags_exclude_wildignore = 1
  -- }}}

  use('mattn/emmet-vim')
  -- let g:user_emmet_mode='i'
  vim.api.nvim_command('autocmd FileType html,css,less,sass,eruby,erb,javascript,jsx,vue EmmetInstall')
  vim.g.user_emmet_mode='i'
  vim.g.user_emmet_leader_key='<c-e>'
  vim.g.user_emmet_expandabbr_key='<c-e><c-e>'
  vim.g.user_emmet_expandword_key = '<C-e>v'
  vim.g.user_emmet_update_tag = '<C-e>u'
  vim.g.user_emmet_next_key='<C-e>n'
  vim.g.user_emmet_prev_key='<C-e>p'
  vim.g.user_emmet_settings = {
    html = {
      quote_char = "'",
    },
    javascript = {
      extends = 'jsx',
    }
  }

  -- Nvim Tree
  use 'kyazdani42/nvim-web-devicons'
  use {'kyazdani42/nvim-tree.lua', config = "require('tree-config')"}
  use {
    'airblade/vim-rooter',
    setup = function()
      vim.g.rooter_patterns = {'.git'}
      vim.g.rooter_manual_only = 1
    end
  }
  -- automatically close the tab/vim when nvim-tree is the last window in the tab
  vim.cmd([[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]])
  use 'scrooloose/nerdtree'
  vim.cmd([[let NERDTreeWinPos = "right"]])
end
