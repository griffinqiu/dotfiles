" .vimrc — MacVim as a scratch editor. No plugin manager: Vim 9.2 already ships
" the only pieces worth having. Real editing happens in Neovim (config/nvim).

set nocompatible
syntax on
filetype plugin indent on

" Built-in packages that replace the plugins this file used to load.
packadd! comment
packadd! editorconfig
packadd! matchit

map <space> <nop>
let mapleader = " "

set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
set fileformats=unix,dos,mac
set nobomb

" A scratch editor should leave nothing behind.
set nobackup nowritebackup noswapfile noundofile

set hidden autoread belloff=all nojoinspaces
set backspace=indent,eol,start
set history=1024 undoreload=1024
set foldmethod=marker
set nospell spelllang=en_us,cjk
" Spellfile lives outside this repository so it can be synced separately.
set spellfile=$HOME/Sync/vim-spell-en.utf-8.add

set shiftwidth=2 softtabstop=2 tabstop=2 expandtab autoindent
set wrap linebreak
set scrolloff=5 sidescroll=1 sidescrolloff=10
set splitbelow splitright equalalways
set colorcolumn=81 nonumber norelativenumber numberwidth=4
set linespace=3 lazyredraw
set timeoutlen=500 ttimeoutlen=10 updatetime=100
set mouse=a ttymouse=sgr
" Modeless selections, the ones mouse=a cannot turn into a Visual selection,
" still copy themselves the way the terminal used to.
set clipboard+=autoselectml
set shortmess=atIc nrformats=

set ignorecase smartcase magic hlsearch incsearch showmatch matchtime=2
set wildmenu wildmode=longest:full,full
set wildignore+=.hg,.git,.svn,*.o,*.obj,*.pyc,*.sw?,*.orig,*.DS_Store
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg

set ruler showcmd showmode cmdheight=2 laststatus=2
highlight StatusLine term=bold,reverse cterm=bold,reverse
set statusline=%<\ [%F]
set statusline+=\ [%{&encoding},
set statusline+=%{&fileformat}%{\"\".((exists(\"+bomb\")\ &&\ &bomb)?\",BOM\":\"\").\"\"}]%m
set statusline+=%=\ %y\ %l,\ %c\ \<%P\>
set complete+=kspell complete-=u complete-=i complete-=t

" gruvbox is a Vim package installed by bin/dotfiles-bootstrap. retrobox, Vim's
" built-in port of it, covers hosts where that checkout is missing.
set background=dark
let g:gruvbox_contrast_dark = 'soft'
let g:gruvbox_contrast_light = 'soft'
let g:gruvbox_invert_selection = 0
silent! packadd! gruvbox
if empty(globpath(&runtimepath, 'colors/gruvbox.vim'))
  colorscheme retrobox
else
  colorscheme gruvbox
endif

" MacVim: mirror config/ghostty/config so Nerd Font glyphs render the same here
" as they do for Neovim in the terminal. guifontwide covers CJK.
if has("gui_running")
  set guifont=Hack\ Nerd\ Font\ Mono:h18
  set guifontwide=Source\ Han\ Sans\ SC:h18
endif

augroup vimrcEx
  autocmd!
  " Jump to the last known cursor position, except in commit messages.
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \     exe "normal g`\"" |
    \ endif
  autocmd BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown
  autocmd FileType css,scss,less,html setl iskeyword+=-
augroup END

let g:is_posix = 1

" Mappings below mirror Neovim. Keys Neovim leaves at their default are left
" alone here too, so the same key never means two things across the editors.
map <silent> , <Nop>

" Move by display line unless a count is given (LazyVim's j/k behavior).
nnoremap <expr> <silent> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> <silent> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> <silent> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> <silent> k v:count == 0 ? 'gk' : 'k'

" Search results keep their direction and open folds, as in Neovim.
nnoremap <expr> n 'Nn'[v:searchforward] . 'zv'
nnoremap <expr> N 'nN'[v:searchforward] . 'zv'
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Copy the current file name in various forms
nmap ,cn :let @*=expand("%:."). ':' . line(".")<CR>
nmap ,cs :let @*=expand("%:.")<CR>
nmap ,cf :let @*=expand("%:t")<CR>
nmap ,cl :let @*=expand("%:p")<CR>

" A mouse drag now builds a Visual selection instead of a terminal one, so copy
" it on release.
xnoremap <LeftRelease> <LeftRelease>"+ygv

nnoremap [b :bprevious<CR>
nnoremap ]b :bnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [l :lprevious<CR>
nnoremap ]l :lnext<CR>

noremap <silent> <C-s> :update!<CR>
vnoremap <silent> <C-s> <C-c>:update!<CR>
inoremap <silent> <C-s> <C-o>:update!<CR>

" netrw replaces the NERDTree mapping this file used to define; <leader>e opens
" the file explorer in Neovim too.
nnoremap <silent> <leader>e :Explore<CR>

" MacVim-only helpers: Neovim binds nothing on these keys.
map <leader>co :botright copen<cr>
" Spell check stays off by default; <leader>ss turns it on for the buffer.
map <leader>ss :setlocal spell!<cr>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

" Visual mode search with proper escaping (aligned with nvim)
function! s:VSetSearch(cmdtype)
  let temp = @s
  norm! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = temp
endfunction
xnoremap * :<C-u>call <SID>VSetSearch('/')<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u>call <SID>VSetSearch('?')<CR>?<C-R>=@/<CR><CR>

" Command-mode navigation (Emacs-style, aligned with nvim)
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Delete>
cnoremap <C-h> <BS>
cnoremap <C-g> <C-f>
cnoremap <Esc><C-b> <S-Left>
cnoremap <Esc><C-f> <S-Right>
