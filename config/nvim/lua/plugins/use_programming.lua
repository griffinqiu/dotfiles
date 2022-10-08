return function(use)
  -- use{'mxw/vim-jsx', ft = {'javascript' }}
  -- use('chrisbra/csv.vim')

  -- use{'Keithbsmiley/rspec.vim', ft = {'ruby'}}
  -- use{'ecomba/vim-ruby-refactoring', ft = {'ruby'}}
  -- use{'vim-ruby/vim-ruby', ft = {'ruby' }}
  -- use{'tpope/vim-rails', ft = {'ruby', 'eruby'}}
  -- use{'tpope/vim-rbenv', ft = {'ruby' }}
  -- use{'tpope/vim-bundler', ft = {'ruby'}}
  -- use{'tpope/vim-pathogen', ft = {'ruby' }}
  use('AndrewRadev/switch.vim')
  vim.g.switch_mapping = "-"

  -- use('plasticboy/vim-markdown')
  -- use('mzlogin/vim-markdown-toc')
  -- vim.g.vim_markdown_folding_disabled=1
  -- vim.g.vim_markdown_initial_foldlevel=1

  -- use {
    -- -- 'yriveiro/dap-go.nvim',
    -- 'jhchabran/dap-go.nvim',
    -- branch = 'hotfix',
    -- -- '~/perso/dap-go.nvim',
    -- requires = { {'nvim-lua/plenary.nvim'} },
    -- config = function()
      -- require('dap-go').setup()
    -- end
  -- }
  use { "golang/vscode-go" }
  -- use { 'ray-x/go.nvim', config = function()
    -- require('go').setup()
  -- end}
  use {
    'fatih/vim-go',
    requires = {{'fatih/gomodifytags'}},
    ft = {'go'},
    run = ':GoUpdateBinaries',
  }
  vim.cmd([[
    let g:go_fmt_fail_silently = 1
    let g:go_highlight_trailing_whitespace_error = 0
    let g:go_list_height = 10
    let g:go_def_mapping_enabled = 0
    let g:go_auto_sameids = 0
    let g:go_code_completion_enabled = 0
    function! s:build_go_files()
     let l:file = expand('%')
     if l:file =~# '^\f\+_test\.go$'
      call go#test#Test(0, 1)
     elseif l:file =~# '^\f\+\.go$'
      call go#cmd#Build(0)
     endif
    endfunction
    autocmd FileType go nmap <leader>go  <Plug>(go-imports)
    autocmd FileType go nmap <leader>gg :<C-u>call <SID>build_go_files()<CR>
    autocmd FileType go nmap <leader>gO :GoImport<SPACE>
    autocmd FileType go nmap <Leader>gh <Plug>(go-info)
    autocmd FileType go nmap <leader>gc  <Plug>(go-coverage-toggle)
    autocmd Filetype go command! -bang A  call go#alternate#Switch(<bang>0, 'edit')
    autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
    autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  ]])

  -- Treesitter
  use {'nvim-treesitter/nvim-treesitter', config = "require('treesitter-config')"}
  use {'nvim-treesitter/nvim-treesitter-textobjects', after = {'nvim-treesitter'}}
  use {'RRethy/nvim-treesitter-textsubjects', after = {'nvim-treesitter'}}

  use{
    'github/copilot.vim',
    setup = function()
      vim.g.copilot_filetypes = {
        ["TelescopePrompt"] = false,
        ["DressingInput"] = false,
      }
    end,
  }
  vim.g.copilot_no_tab_map = true
  vim.cmd([[imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")]])
end
