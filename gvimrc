if(has("win32") || has("win64"))
    set diffexpr=MyDiff()
    function! MyDiff()
      let opt = '-a --binary '
      if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
      if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
      let arg1 = v:fname_in
      if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
      let arg2 = v:fname_new
      if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
      let arg3 = v:fname_out
      if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
      let eq = ''
      if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
          let cmd = '""' . $VIMRUNTIME . '\diff"'
          let eq = '"'
        else
          let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
      else
        let cmd = $VIMRUNTIME . '\diff'
      endif
      silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction

    "set guifont=Monaco:h10:cANSI
    set gfn=Bitstream\ Vera\ Sans\ Mono:h14

    set langmenu=en_US
    let $LANG='en_US'
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim

    nmap <F8> :!start explorer /select, %:p<CR>

    " CTRL-X
    vnoremap <C-X> "+x

    " CTRL-C
    vnoremap <C-C> "+y

    " CTRL-V
    map <C-V>       "+gP
    cmap <C-V>b <C-R>+

    exe 'inoremap <script> <C-V>' paste#paste_cmd['i']
    exe 'vnoremap <script> <C-V>' paste#paste_cmd['v']

    " Use CTRL-S for saving, also in Insert mode
    noremap <C-S>       :update!<CR>
    vnoremap <C-S>      <C-C>:update!<CR>
    inoremap <C-S>      <C-O>:update!<CR>

    " CTRL-A is Select all
    noremap <C-A> gggH<C-O>G
    inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
    cnoremap <C-A> <C-C>gggH<C-O>G
    onoremap <C-A> <C-C>gggH<C-O>G
    snoremap <C-A> <C-C>gggH<C-O>G
    xnoremap <C-A> <C-C>ggVG

    " Use CTRL-Q to do what CTRL-V used to do
    noremap <C-Q>       <C-V>
else
    set gfn=Menlo:h16
endif

" No audible bell
set visualbell

" Use console dialogs
set guioptions+=c
set winaltkeys=no
set guioptions-=b
set guioptions-=R
set guioptions-=r
set guioptions-=l
set guioptions-=L
"set guioptions-=m
set guioptions-=T

set t_Co=256
set background=dark
colorscheme desert
set mouse+=a
set mousehide

if has("gui_macvim")
    macmenu &File.Save key=<nop>
    macmenu &File.New\ Window key=<nop>
    macmenu &File.Open\.\.\. key=<nop>
    macmenu &File.Open\ Tab\.\.\. key=<nop>
    macmenu &File.Close\ Window key=<nop>
    macmenu &File.Close key=<nop>
    macmenu &File.Save\ As\.\.\. key=<nop>
    macmenu &File.Print key=<nop>
    macmenu &Edit.Undo key=<nop>
    macmenu &Edit.Redo key=<nop>
    macmenu &Edit.Cut key=<nop>
    macmenu &Edit.Select\ All key=<nop>
    macmenu &Edit.Find.Find\.\.\. key=<nop>
    macmenu &Edit.Find.Find\ Next key=<nop>
    macmenu &Edit.Find.Find\ Previous key=<nop>
    macmenu &Edit.Find.Use\ Selection\ for\ Find key=<nop>
    macmenu &Edit.Font.Bigger key=<nop>
    macmenu &Edit.Font.Smaller key=<nop>
    macmenu &Tools.Spelling.To\ Next\ Error key=<nop>
    macmenu &Tools.Spelling.To\ Previous\ Error key=<nop>
    macmenu &Tools.Make key=<nop>
    macmenu &Tools.List\ Errors key=<nop>
    macmenu &Tools.Next\ Error key=<nop>
    macmenu &Tools.Previous\ Error key=<nop>
    macmenu &Tools.Older\ List key=<nop>
    macmenu &Tools.Newer\ List key=<nop>

    set transparency=5
endif
" set noimdisable
set iminsert=2
set imsearch=2

" Local config
if filereadable($HOME . "/.gvimrc.local")
  source ~/.gvimrc.local
endif
