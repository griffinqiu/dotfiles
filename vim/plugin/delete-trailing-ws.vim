"Delete trailing white space, useful for PHP ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
map <leader>ds :call DeleteTrailingWS()<CR>
autocmd BufWrite *.php :call DeleteTrailingWS()
autocmd BufWrite *.rb :call DeleteTrailingWS()
