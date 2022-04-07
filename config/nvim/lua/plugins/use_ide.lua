return function(use)
  use {
    'scrooloose/nerdtree',
    on = 'NERDTreeToggle',
    config = function()
      vim.g.NERDTreeMapPreview = "p"
      vim.g.NERDTreeMapOpenSplit = "s"
      vim.g.NERDTreeMapOpenVSplit = "v"
      vim.g.NERDTreeMapOpenInTab = "t"
      vim.g.NERDTreeMapToggleHidden = "I"
      vim.g.NERDTreeMapJumpRoot = "<c-p>"
      vim.g.NERDTreeMapJumpParent = "P"
      vim.g.NERDTreeMapJumpFirstChild = "^"
      vim.g.NERDTreeIgnore={ '.meta$', '.pyc$' }
      vim.g.NERDTreeMapOpenExpl="<nop>"
    end,
  }
  nnoremap("<leader>1", ":NERDTreeToggle<cr>", "silent")
  nnoremap("<leader>nf", ":NERDTreeFind<cr>", "silent")

  use {
    'Xuyuanp/nerdtree-git-plugin',
    config = function()
      vim.g.NERDTreeGitStatusIndicatorMapCustom = {
        Modified  = '✹',
        Staged    = '✚',
        Untracked = '✭',
        Renamed   = '➜',
        Unmerged  = '═',
        Deleted   = '✖',
        Dirty     = '✗',
        Ignored   = '☒',
        Clean     = '✔︎',
        Unknown   = '?',
      }
      vim.g.NERDTreeGitStatusUseNerdFonts = 1
    end
  }

	use {
    'scrooloose/nerdcommenter',
    config = function()
      vim.g.NERDSpaceDelims = 1
    end
  }

  use('griffinqiu/star-search')
  use 'dyng/ctrlsf.vim'
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
  nmap('<C-G>g', '<Plug>CtrlSFPrompt', 'buffer')
  nmap('<C-G>G', '<Plug>CtrlSFCwordPath', 'buffer')
  nmap('<C-G><C-G>', '<Plug>CtrlSFCwordExec', 'buffer')
  vmap('<C-G>g', '<Plug>CtrlSFVwordPath', 'buffer')
  vmap('<C-G>G', '<Plug>CtrlSFVwordPath', 'buffer')
  vmap('<C-G><C-G>', '<Plug>CtrlSFVwordExec', 'buffer')
  nmap('<C-G>p', '<Plug>CtrlSFPwordPath', 'buffer')
  nmap('<C-G><C-P>', '<Plug>CtrlSFPwordExec', 'buffer')
  nnoremap('<C-G><C-O>', ':CtrlSFOpen<CR>', 'buffer')
  nmap('<C-G>l', '<Plug>CtrlSFQuickfixPrompt', 'buffer')
  vmap('<C-G>l', '<Plug>CtrlSFQuilkfixVwordPath', 'buffer')
  vmap('<C-G>L', '<Plug>CtrSFQuickfixVwordPath', 'buffer')
  vmap('<C-G><C-L>', '<Plug>CtrlSFQuickfixVwordExec', 'buffer')
  nmap('<leader>3', ':CtrlSFToggle<CR>', 'buffer', 'silent')
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
  vim.g.gutentags_cache_dir = '~/tmp/tags'
  vim.g.gutentags_generate_on_write = 1
  vim.g.gutentags_generate_on_missing = 0
  vim.g.gutentags_generate_on_new = 0
  vim.g.gutentags_ctags_exclude_wildignore = 1

  use('Valloric/ListToggle')
  vim.g.lt_location_list_toggle_map = '<leader>l'
  vim.g.lt_quickfix_list_toggle_map = '<leader>q'
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
end
