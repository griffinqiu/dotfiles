" .vimrc

" Manager Vundle {{{
set nocompatible
filetype off

if (has("unix"))
	set rtp+=~/.vim/bundle/Vundle.vim/
	call vundle#rc()
else
	set rtp+=~/vimfiles/bundle/Vundle.vim/
	call vundle#rc("~/vimfiles/bundle/")
endif

call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'vim-scripts/matchit.zip'
Plugin 'vim-scripts/buftabs'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-commentary'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'shawncplus/phpcomplete.vim'
Plugin 'liangfeng/vimcdoc'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-surround'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/TwitVim'
" Plugin 'tpope/vim-unimpaired'
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'marijnh/tern_for_vim'
" Plugin 'OrangeT/vim-csharp'
" Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'dyng/ctrlsf.vim'
Plugin 'groenewege/vim-less'
Plugin 'uguu-org/vim-matrix-screensaver'
" Plugin 'godlygeek/tabular'

Plugin 'maksimr/vim-jsbeautify'

" Wiki
Plugin 'mattn/calendar-vim'
Plugin 'vimwiki/vimwiki'
Plugin 'neilagabriel/vim-geeknote'

" Dash
Plugin 'Keithbsmiley/investigate.vim'
Plugin 'rizzatti/funcoo.vim'
Plugin 'rizzatti/dash.vim'

Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'kchmck/vim-coffee-script'
Plugin 'chase/vim-ansible-yaml'

"Plugin 'Lokaltog/vim-powerline'
Plugin 'altercation/vim-colors-solarized'

Plugin 'mileszs/ack.vim'
Plugin 'yonchu/accelerated-smooth-scroll'
Plugin 'fatih/vim-go'
Plugin 'autowitch/hive.vim'

" Plugin 'bling/vim-airline'
Plugin 'edkolev/tmuxline.vim'


call vundle#end()
filetype plugin indent on
" }}}

" Vim Settings {{{

set nocompatible
filetype off

set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
set fileformats=unix,dos,mac
set nobomb

map <Space> <nop>
let mapleader=" "
let g:mapleader=" "

if v:version >= 703
    "undo settings
	exec "set undodir=~/tmp/undofiles"
    set undofile
endif
exec "set backupdir=~/tmp/backups"
exec "set directory=~/tmp/"

if has("autocmd")
    autocmd FileType c set omnifunc=ccomplete#Complete
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    autocmd FileType ada set omnifunc=adacomplete#Complete
    autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType phtml set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
    autocmd FileType php set omnifunc=phpcomplete#CompletePHP
	autocmd FileType tpl set omnifunc=htmlcomplete#CompleteTags
    autocmd FileType ruby set omnifunc=rubycomplete#Completeruby
    autocmd FileType sql set omnifunc=sqlcomplete#Completesql
	autocmd BufNewFile,BufRead *.hql set filetype=hive expandtab
	autocmd BufNewFile,BufRead *.q set filetype=hive expandtab
	" au BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn}   set filetype=mkd
endif

set hidden
filetype on
filetype plugin on
syntax on

set autoread
set nobackup
set noswapfile
set nowritebackup
set novisualbell

set nowrap
set linebreak
"set colorcolumn=120

set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

set nolist
set listchars=tab:▸\ ,trail:¶

set sidescroll=1
set sidescrolloff=10

set splitbelow
set splitright
set equalalways

set autoindent
set linespace=3

set history=1024
set undoreload=1024

set iskeyword+=_,$
set backspace=indent,eol,start
set matchpairs=(:),[:],{:},<:>
set whichwrap=b,s

set number
set numberwidth=4

set foldmethod=marker

set wildmenu
set wildmode=longest:full,full
"set wildmode=list:longest
set wildignore+=.hg,.git,.svn                    " Version control
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg   " binary images
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.sw?                            " Vim swap files
set wildignore+=*.DS_Store                       " OSX bullshit
set wildignore+=*.pyc                            " Python byte code
set wildignore+=*.orig                           " Merge resolution files
set ofu=syntaxcomplete#Complete

set ruler
set matchtime=2

set magic
set ignorecase
set smartcase
set hlsearch
set incsearch
set showmatch

set cmdheight=2
set laststatus=2
highlight StatusLine term=bold,reverse cterm=bold,reverse
set statusline=%<\ [%F]
set statusline+=\ [%{&encoding}, " encoding
set statusline+=%{&fileformat}%{\"\".((exists(\"+bomb\")\ &&\ &bomb)?\",BOM\":\"\").\"\"}]%m
set statusline+=%=\ %y\ %l,\ %c\ \<%P\>
set complete+=kspell
set complete-=u
set complete-=i

set sessionoptions=blank,buffers,curdir,folds,globals,help,localoptions,options,tabpages,winsize,resize,winpos,winsize

set formatoptions+=mM
set ttymouse=xterm2

set showcmd
set showmode
set shortmess=atI

set nrformats=
set cinwords=if,else,while,do,for,switch,case

" tags
set tags=.tags;

let g:solarized_termcolors = 256
" set background=dark
" colorscheme solarized

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" }}}

" Plugins {{{

" Geeknote
autocmd FileType geeknote setlocal nonumber
let g:GeeknoteExplorerNodeClosed = '+'
let g:GeeknoteExplorerNodeOpened = '-'

" Vimwiki
let defualt_wiki = {'path': '~/Gits/vimwiki/_source/',
\ 'path_html': '~/Gits/vimwiki/html/',
\ 'template_path': '~/Gits/vimwiki/templates/',
\ 'template_ext': '.tpl',
\ 'template_default': 'default',
\ 'nested_syntaxes': {'php': 'php', 'python': 'python', 'c++': 'cpp', 'js': 'javascript', 'bash': 'bash'},
\ 'index': 'index',
\ 'ext': '.wiki',
\ 'syntax': 'default',
\ 'auto_export': 1}
let g:vimwiki_use_calendar = 1
let g:vimwiki_use_mouse = 1
let g:vimwiki_list = [defualt_wiki]
"nmap <S-Space> <Plug>VimwikiToggleListItem
"let g:vimwiki_hl_cb_checked = 1
"let g:vimwiki_valid_html_tags='strong,em,del,blockquote,ins,code'
"let g:vimwiki_file_exts = 'php, c'
"let g:vimwiki_browsers = ['google-chrome']

" Markdown
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_initial_foldlevel=1

" Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" tagbar
let g:tagbar_type_php  = {
    \ 'ctagstype' : 'php',
    \ 'kinds'     : [
        \ 'i:interfaces',
        \ 'c:classes',
        \ 'd:constant definitions',
        \ 'f:functions',
        \ 'j:javascript functions:1'
    \ ]
  \ }"
let g:tagbar_width=30
let g:tagbar_sort=0
let g:Tb_MaxSize=5

" 取消flag:i来禁止打开文件时输出文件信息
let g:proj_flags='mst'

" Ctrl P
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|\.hg$\|\.svn$|Client',
  \ 'file': '\.meta\|\.as$\|\.so$\|^tags$|\.exe$'
  \ }
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("v")': ['<c-v>', '<RightMouse>'],
  \ 'AcceptSelection("h")': ['<c-s>', '<c-cr>'],
  \ 'PrtClearCache()':      ['<F6>'],
  \ }

" CtrlSF
" CtrlSF -i -C 1 [pattern] /restrict/to/some/dir
let g:ctrlsf_ackprg = 'ag'
let g:ctrlsf_auto_close = 0
let g:ctrlsf_open_left = 0
"let g:ctrlsf_context = '-B 5 -A 3'

" TargerBar
map <silent> <leader>tb	<ESC>:Tagbar<CR>

" NERDTree
map <silent> <c-n>			<ESC>:NERDTreeToggle<CR>
map <silent> <leader>nf		<ESC>:NERDTreeFind<CR>
" 打开项目
map <silent> <leader>no :NERDTreeFromBookmark<space>

" Set opened dir to workspace dir
let NERDTreeChDirMode=1
" NERDTree mapping
let g:NERDTreeMapPreview = "<c-o>"
let g:NERDTreeMapOpenSplit = "s"
let g:NERDTreeMapPreviewSplit = "<c-s>"
let g:NERDTreeMapOpenVSplit = "v"
let g:NERDTreeMapPreviewVSplit = "<c-v>"
let g:NERDTreeMapToggleHidden = "I"
let g:NERDTreeIgnore=['\.meta$']
let g:NERDSpaceDelims=1

" Dash
noremap <c-g> :call investigate#Investigate()<CR>
let g:investigate_use_dash=1

" Twitter 快捷键
let g:twitvim_browser_cmd='open'
let g:twitvim_force_ssl=1
nmap <silent> <leader>tt :FriendsTwitter<cr>
nmap <silent> <leader>tp :PosttoTwitter<cr>
vmap <silent> <leader>tp <Plug>TwitvimVisual<cr>
nmap <silent> <leader>tcp :CPosttoTwitter<cr>
nmap <silent> <leader>tu :UserTwitter<cr>
nmap <silent> <leader>tm :MentionsTwitter<cr>
nmap <silent> <leader>td :DMTwitter<cr>
nmap <silent> <leader>tn :NextTwitter<cr>
"nmap <silent> <leader>tl :PreviousTwitter<cr>

" noremap <c-]> :YcmCompleter GoToDefinitionElseDeclaration<CR>
" set completeopt-=preview
" let g:ycm_key_list_select_completion=['<Down>']
" let g:ycm_key_list_previous_completion=['<Up>']
" let g:ycm_seed_identifiers_with_syntax=1
" let g:ycm_complete_in_comments=1
" let g:ycm_confirm_extra_conf=0
" " let g:ycm_collect_identifiers_from_tags_files=1
" let g:ycm_key_invoke_completion='<C-Space>'
" let g:ycm_auto_trigger=0
" let g:ycm_filetype_blacklist = {
      " \ 'tagbar' : 1,
      " \ 'qf' : 1,
      " \ 'notes' : 1,
      " \ 'markdown' : 1,
      " \ 'unite' : 1,
      " \ 'text' : 1,
      " \ 'vimwiki' : 1,
      " \ 'pandoc' : 1,
      " \ 'infolog' : 1,
      " \ 'mail' : 1
      " \}
" let g:ycm_semantic_triggers =  {
  " \   'c' : ['->', '.'],
  " \   'objc' : ['->', '.'],
  " \   'ocaml' : ['.', '#'],
  " \   'cpp,objcpp' : ['->', '.', '::'],
  " \   'perl' : ['->'],
  " \   'php' : ['->', '::'],
  " \   'cs,java,javascript,d,python,perl6,scala,vb,elixir,go' : ['.'],
  " \   'vim' : ['re![_a-zA-Z]+[_\w]*\.'],
  " \   'ruby' : ['.', '::'],
  " \   'lua' : ['.', ':'],
  " \   'erlang' : [':'],
  " \ }

" }}}

" Mapping {{{
noremap <silent> <C-s> :update!<CR>
vnoremap <silent> <C-s> <C-c>:update!<CR>
inoremap <silent> <C-s> <C-o>:update!<CR>

nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap g; g;zz
nnoremap g, g,zz

map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l
inoremap <C-h> <left>
inoremap <C-l> <right>
inoremap <C-j> <C-o>gj
inoremap <C-k> <C-o>gk

" 强制将tab转换成空格
map <leader>ct :retab<cr>

" easymotion
let g:EasyMotion_leader_key = "'"

"map <silent> <M-1> <ESC>:tabp<CR>
"map <silent> <M-2> <ESC>:tabn<CR>
"map <silent> <M-3> <ESC>:tabnew<CR>
"map <silent> <M-4> <ESC>:tabclose<CR>

" Powerline
" let g:Powerline_symbols = 'fancy'

map <leader>co :botright cope<cr>

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
" nmap <M-j> mz:m+<cr>`z
" nmap <M-k> mz:m-2<cr>`z
" vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
" vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>

map <silent> <leader><cr> :nohlsearch<cr>
map <silent> <leader><bs> :set noincsearch<cr>
map <silent> <leader><leader><bs> :set incsearch<cr>

" 自动补全
inoremap <C-]>             <C-X><C-]>
inoremap <C-F>             <C-X><C-F>
inoremap <C-B>             <C-X><C-L>

" 拼写检查
"map <leader>ss :setlocal spell!<cr>
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>s? z=

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>cm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

nnoremap @p4a :!p4 add %:p<cr>
nnoremap @p4e :!p4 edit %:p<cr>
nnoremap @p4d :!p4 diff %<cr>

" Youdao
map <leader>yd :Ydc<CR>

"Fast reloading of the _vimrc
exec "map <leader><leader>l :source ~/.vimrc<cr>"
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

" -- ctags --
"function! RefreshCtags()
    "!ctags -R
"endfunction
" map <ctrl>+F12 to generate ctags for current folder:
"map <M-F12> :call RefreshCtags()<CR>

" Close other Buffers
command! BcloseOthers call <SID>BufCloseOthers()  
function! <SID>BufCloseOthers()  
   let l:currentBufNum   = bufnr("%")  
   let l:alternateBufNum = bufnr("#")  
   for i in range(1,bufnr("$"))  
     if buflisted(i)  
       if i!=l:currentBufNum  
         execute("bdelete ".i)  
       endif  
     endif  
   endfor  
endfunction
map <leader>bdo :BcloseOthers<cr>

"Delete trailing white space, useful for PHP ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.php :call DeleteTrailingWS()
map <leader>ds :call DeleteTrailingWS()<CR>

function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s =temp
endfunction
vnoremap * :<c-u>call <SID>VSetSearch()<CR>/<c-r>=@/<CR><CR>
vnoremap # :<c-u>call <SID>VSetSearch()<CR>?<c-r>=@/<CR><CR>

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
	au!
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\     execute 'normal! g`"zvzz' |
		\ endif
augroup END


" }}}
