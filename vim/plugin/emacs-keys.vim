" start of line
:cnoremap <C-A>		<Home>
" end of line
:cnoremap <C-E>		<End>

" back one character
:cnoremap <C-B>		<Left>
" forward one character
:cnoremap <C-F>		<Right>

" recall previous (older) command-line
:cnoremap <C-P>		<Up>
" recall newer command-line
:cnoremap <C-N>		<Down>

" back one word
:cnoremap <Esc><C-B>    <S-Left>
" forward one word
:cnoremap <Esc><C-F>    <S-Right>

" search command line
:cnoremap <C-R>     <C-F>?
