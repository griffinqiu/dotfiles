return {
  'fatih/vim-go',
  dependencies = {
    'fatih/gomodifytags'
  },
  lazy = true,
  ft = { 'go' },
  build = ':GoUpdateBinaries',
  init = function()
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
  end,
}
