" .vimrc

" Vim Settings {{{
map <space> <nop>
let mapleader = " "
" let g:mapleader = " "

set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
set fileformats=unix,dos,mac

set nobomb
set nobackup
set nowritebackup
set noswapfile
set history=1024
set ruler
set showcmd
set wrap
set linebreak
set autoread
" set autowrite
set hidden
set novisualbell
set nojoinspaces
set backspace=indent,eol,start

set foldmethod=marker

set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
" set nolist
" set list listchars=tab:»·,trail:·,nbsp:·

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
    syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif

set nocompatible
filetype plugin indent on
augroup vimrcEx
    autocmd!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it for commit messages, when the position is invalid, or when
    " inside an event handler (happens when dropping a file on gvim).
    autocmd BufReadPost *
        \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
        \     exe "normal g`\"" |
        \ endif

    " Set syntax highlighting for specific file types
    autocmd BufRead,BufNewFile Appraisals set filetype=ruby
    autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown
    autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
    autocmd BufNewFile,BufRead *.hql set filetype=hive expandtab
    autocmd BufNewFile,BufRead *.q set filetype=hive expandtab
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
    autocmd FileType sql set omnifunc=sqlcomplete#Completesql
    autocmd FileType css,scss,less,html setl iskeyword+=-
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

if v:version >= 703
    set undofile
    set undodir=~/tmp/undofiles
endif
if v:version >= 800
    set tagcase=match
endif
set backupdir=~/tmp/backups
set directory=~/tmp/

" set textwidth=80
set colorcolumn=81

set nonumber
set numberwidth=4

set sidescroll=1
set sidescrolloff=10

set splitbelow
set splitright
set equalalways

set autoindent
set linespace=3

set history=1024
set undoreload=1024

" Always use vertical diffs
set diffopt+=vertical
set whichwrap=b,s

set wildmenu
" set wildmode=list:longest,list:full
set wildmode=longest:full,full
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

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" set sessionoptions=
    " \blank,buffers,curdir,folds,globals,help,localoptions,
    " \options,tabpages,winsize,resize,winpos,winsize

set formatoptions+=mM
set ttymouse=xterm2

set showcmd
set showmode
set shortmess=atI

set nrformats=
set tags+=gems.tags

" Speed up for macros
set lazyredraw

" }}}

" Mapping {{{
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j

nnoremap gT :tabprevious<CR>
nnoremap gt :tabnext<CR>
nnoremap t<C-]> :tabnew %<CR>g<C-]>
vnoremap t<C-]> <Esc>:tabnew %<CR>gvg<C-]>

" nnoremap B ^
" nnoremap E $

" highlight last inserted text
nnoremap gV `[v`]

" Copy filename to clipboard
nmap ,cn :let @*=expand("%"). ':' . line(".")<CR>
nmap ,cs :let @*=expand("%")<CR>
nmap ,cl :let @*=expand("%:p")<CR>

" Move to prev/next buffer
noremap <left> :bprev<CR>
noremap <right> :bnext<CR>

noremap <silent> <C-s> :update!<CR>
vnoremap <silent> <C-s> <C-c>:update!<CR>
inoremap <silent> <C-s> <C-o>:update!<CR>

nnoremap n nzzzv
nnoremap N Nzzzv

nnoremap g; g;zz
nnoremap g, g,zz

nmap <leader><c-g> <c-g>
nmap <leader><c-l> <c-l>

inoremap <C-e> <C-k>
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l
map <C-w>; <C-w>p
" inoremap <C-h> <left>
" inoremap <C-l> <right>
" inoremap <C-j> <C-o>gj
" inoremap <C-k> <C-o>gk

" Convert all tabs to spaces
map <leader>ct :retab<cr>

map <leader>co :botright copen<cr>

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>

map <silent> <leader><cr> :nohlsearch<cr>
map <silent> <leader><bs> :set noincsearch<cr>
map <silent> <leader><leader><bs> :set incsearch<cr>

" " Spell
" map <leader>ss :setlocal spell!<cr>
" map <leader>sn ]s
" map <leader>sp [s
" map <leader>sa zg
" map <leader>s? z=

" Remove the Windows ^M - when the encodings gets messed up
noremap <leader><leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

if executable('p4')
    nnoremap @p4a :!p4 add %:p<cr>
    nnoremap @p4e :!p4 edit %:p<cr>
    nnoremap @p4d :!p4 diff %<cr>
endif

" }}}
