"Fast reloading of the _vimrc
exec "map <leader><leader>r :source ~/.vimrc<cr>"
"Fast editing of _vimrc
function! SwitchToBuf(filename)
  let fullfn = a:filename
  " find in current tab
  let bufwinnr = bufwinnr(fullfn)
  if bufwinnr != -1
    exec bufwinnr . "wincmd w"
    return
  else
    " find in each tab
    tabfirst
    let tab = 1
    while tab <= tabpagenr("$")
      let bufwinnr = bufwinnr(fullfn)
      if bufwinnr != -1
        exec "normal " . tab . "gt"
        exec bufwinnr . "wincmd w"
        return
      endif
      tabnext
      let tab = tab + 1
    endwhile
    " not exist, new tab
    exec "tabnew " . fullfn
  endif
endfunction
map <silent> <leader><leader>e :call SwitchToBuf("~/.vimrc")<cr>
map <silent> <leader><leader>b :call SwitchToBuf("~/.vimrc.bundles")<cr>
