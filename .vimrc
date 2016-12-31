" .vimrc

" Manager Vundle {{{
set nocompatible
filetype off

" if (has("unix"))
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#rc("~/.vim/bundle/")
" else
" 	set rtp+=~/vimfiles/bundle/Vundle.vim/
" 	call vundle#rc("~/vimfiles/bundle/")
" endif

call vundle#begin()

Plugin 'gmarik/Vundle.vim'

" Tools
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'majutsushi/tagbar'
" Plugin 'vim-scripts/buftabs'

" For search 
Plugin 'griffinqiu/star-search'
" Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'dyng/ctrlsf.vim'
Plugin 'mileszs/ack.vim'
Plugin 'terryma/vim-multiple-cursors'
" Plugin 'SirVer/ultisnips'
" Plugin 'honza/vim-snippets'
Plugin 'tpope/vim-fugitive'
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'

" Great plugins
Plugin 'godlygeek/tabular'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'mattn/emmet-vim'
Plugin 'skywind3000/asyncrun.vim'
" Plugin 'tpope/vim-unimpaired'
" Plugin 'tpope/vim-surround'

" Syntax
Plugin 'maksimr/vim-jsbeautify'
Plugin 'groenewege/vim-less'
Plugin 'plasticboy/vim-markdown'
Plugin 'chase/vim-ansible-yaml'
Plugin 'autowitch/hive.vim'
Plugin 'fatih/vim-go'
Plugin 'pangloss/vim-javascript'
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'vim-scripts/matchit.zip'
Plugin 'shawncplus/phpcomplete.vim'
Plugin 'kchmck/vim-coffee-script'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-endwise'
Plugin 'thoughtbot/vim-rspec'
Plugin 'cakebaker/scss-syntax.vim'

" Wiki
Plugin 'mattn/calendar-vim'
Plugin 'vimwiki/vimwiki'
Plugin 'neilagabriel/vim-geeknote'

" Dash
Plugin 'rizzatti/dash.vim'

" Styles
Plugin 'altercation/vim-colors-solarized'
Plugin 'yonchu/accelerated-smooth-scroll'
" Plugin 'Lokaltog/vim-powerline'
" Plugin 'bling/vim-airline'
" Plugin 'edkolev/tmuxline.vim'


" " Static language Complete
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'marijnh/tern_for_vim'
" Plugin 'OrangeT/vim-csharp'
" Plugin 'scrooloose/syntastic'

" Misc
Plugin 'liangfeng/vimcdoc'
Plugin 'vim-scripts/TwitVim'
Plugin 'uguu-org/vim-matrix-screensaver'

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
    autocmd FileType css,scss,less,html setl iskeyword+=-
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

set wrap
set linebreak
"set colorcolumn=120

set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab

" set textwidth=80
set colorcolumn=+1
" let &colorcolumn=join(range(81,999),",")
" highlight ColorColumn ctermbg=grey guibg=#2c2d27
" let &colorcolumn="80,".join(range(120,999),",")

if has("autocmd")
    autocmd Filetype eruby setlocal ts=2 sts=2 sw=2 
    autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
endif

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

set nonumber
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

set sessionoptions=
            \blank,buffers,curdir,folds,globals,help,localoptions,
            \options,tabpages,winsize,resize,winpos,winsize

set formatoptions+=mM
set ttymouse=xterm2

set showcmd
set showmode
set shortmess=atI

set nrformats=
set cinwords=if,else,while,do,for,switch,case

set tagcase=match

" tags
" set tags=.tags;

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
let defualt_wiki = {
    \'path': '~/Gits/vimwiki/_source/',
    \'path_html': '~/Gits/vimwiki/html/',
    \'template_path': '~/Gits/vimwiki/templates/',
    \'template_ext': '.tpl',
    \'template_default': 'default',
    \'nested_syntaxes': {'php': 'php', 'python': 'python', 'c++': 'cpp', 'js': 'javascript', 'bash': 'bash'},
    \'index': 'index',
    \'ext': '.wiki',
    \'syntax': 'default',
    \'auto_export': 1
\}
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
" let g:user_emmet_install_global = 0
" autocmd FileType html,css EmmetInstall

" tagbar
let g:tagbar_type_php = {
    \'ctagstype' : 'php',
    \'kinds'     : [
        \'i:interfaces',
        \'c:classes',
        \'d:constant definitions',
        \'f:functions',
        \'j:javascript functions:1'
    \]
\}"
let g:tagbar_width=30
let g:tagbar_sort=0
let g:tagbar_autofocus=1
let g:Tb_MaxSize=5

" " Ctrl P
" if executable('ag')
    " " Use Ag over Grep
    " " set grepprg=ag\ --nogroup\ --nocolor
    " " Use ag in CtrlP for listing files.
    " " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    " " Ag is fast enough that CtrlP doesn't need to cache
    " let g:ctrlp_use_caching = 0
" endif
" let g:ctrlp_custom_ignore = {
    " \'dir': '\v[\/](\.(git|hg|svn)|env|var|tmp|bower_components|node_modules|semantic|build|vendor)$',
    " \'file': '\v\.(exe|so|dll|meta|pyc|as|so|tags)$',
    " \'link': 'some_bad_symbolic_links'
" \}
" let g:ctrlp_prompt_mappings = {
    " \'AcceptSelection("v")': ['<C-V>', '<RightMouse>'],
    " \'AcceptSelection("h")': ['<C-S>', '<C-CR>'],
    " \'PrtClearCache()':      ['<F6>'],
    " \'PrtCurLeft()': ['<left>', '<c-h>'] 
" \}
" " let g:ctrlp_user_command = 'find %s -type f'
" let g:ctrlp_by_filename = 1
" let g:ctrlp_mruf_case_sensitive = 0
" let g:ctrlp_use_caching = 1
" let g:ctrlp_cache_dir = '~/tmp/ctrlp'
" let g:ctrlp_working_path_mode = 'w'
" let g:ctrlp_tabpage_position = 'f'

" CtrlSF
" CtrlSF -i -C 1 [pattern] /restrict/to/some/dir
if executable('ag')
    let g:ctrlsf_ackprg = 'ag'
endif
let g:ctrlsf_auto_close = 0
let g:ctrlsf_open_left = 0
let g:ctrlsf_winsize = '15' 
let g:ctrlsf_position = 'bottom'
let g:ctrlsf_mapping = {
    \ "next": "<c-d>",
    \ "prev": "<c-u>",
    \ }
"let g:ctrlsf_context = '-B 5 -A 3'
let g:ctrlsf_ignore_dir = ['node_modules', 'build']
" Ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
" let g:ackprg = 'ag --nogroup --nocolor --column'
endif

" CtrlSF
nmap     <C-G>g <Plug>CtrlSFPrompt
nmap     <C-G>G <Plug>CtrlSFCwordPath
nmap     <C-G><C-G> <Plug>CtrlSFCwordExec
vmap     <C-G>g <Plug>CtrlSFVwordPath
vmap     <C-G>G <Plug>CtrlSFVwordPath
vmap     <C-G><C-G> <Plug>CtrlSFVwordExec
nmap     <C-G>p <Plug>CtrlSFPwordPath
nmap     <C-G><C-P> <Plug>CtrlSFPwordExec
nnoremap <C-G><C-O> :CtrlSFOpen<CR>
" nnoremap <C-G><C-T> :CtrlSFToggle<CR>
inoremap <C-G><C-T> <Esc>:CtrlSFToggle<CR>
nmap     <C-G>l <Plug>CtrlSFQuickfixPrompt
vmap     <C-G>l <Plug>CtrlSFQuickfixVwordPath
vmap     <C-G>L <Plug>CtrlSFQuickfixVwordPath
vmap     <C-G><C-L> <Plug>CtrlSFQuickfixVwordExec
nmap     <silent><leader>3 :CtrlSFToggle<CR>

" vim-javascript
let g:javascript_enable_domhtmlcss = 1
let g:javascript_ignore_javaScriptdoc = 1

" NERDTree
nmap <silent> <leader>1			:NERDTreeToggle<CR>
nmap <silent> <leader>nf		:NERDTreeFind<CR>
" Open 'Project'
nmap <silent> <leader>no        :NERDTreeFromBookmark<space>

" TargerBar
nmap <silent> <leader>2         :TagbarToggle<CR>

" Set opened dir to workspace dir
let NERDTreeChDirMode = 2
" let NERDTreeWinPos = 'right'
let NERDTreeShowBookmarks = 1
let NERDTreeWinSize = 30
" NERDTree mapping
let g:NERDTreeMapPreview = "p"
let g:NERDTreeMapOpenSplit = "s"
let g:NERDTreeMapPreviewSplit = "<c-s>"
let g:NERDTreeMapOpenVSplit = "v"
let g:NERDTreeMapPreviewVSplit = "<c-v>"
let g:NERDTreeMapToggleHidden = "I"
let g:NERDTreeIgnore=['\.meta$', '\.pyc$']
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeMapJumpNextSibling = '<c-d>'
let g:NERDTreeMapJumpPrevSibling = '<c-u>'

" " Automatically open a NERDTree if no files where specified
" autocmd vimenter * if !argc() | NERDTree | endif
" " Close vim if the only window left open is a NERDTree
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") 
            " \ && b:NERDTreeType == "primary") | q | endif

let g:NERDTreeIndicatorMapCustom = {
    \"Modified"  : "✹",
    \"Staged"    : "✚",
    \"Untracked" : "✭",
    \"Renamed"   : "➜",
    \"Unmerged"  : "═",
    \"Deleted"   : "✖",
    \"Dirty"     : "✗",
    \"Clean"     : "✔︎",
    \"Unknown"   : "?"
\}
" NERDCommenter
let g:NERDSpaceDelims=1

" " Dash
" noremap <c-g> :call investigate#Investigate()<CR>
" let g:investigate_use_dash=1

" vim-multiple-cursors
let g:multi_cursor_start_key='<c-n>'
let g:multi_cursor_start_word_key='g<c-n>'

" Twitter
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

" buftabs
noremap <left> :bprev<CR> 
noremap <right> :bnext<CR>
noremap <up> :cprev<CR> 
noremap <down> :cnext<CR>

" ctags
nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>
nnoremap g<c-]> <c-]>
vnoremap g<c-]> <c-]>

" easymotion
let g:EasyMotion_leader_key = "'"

" emmet-vim
let g:user_emmet_leader_key='<C-V>'
let g:user_emmet_expandabbr_key='<C-V><C-V>'
let g:user_emmet_expandword_key = '<C-V>v'
let g:user_emmet_update_tag = '<C-V>u'                                                                                                                                                                                               
let g:user_emmet_next_key='<C-V>n'
let g:user_emmet_prev_key='<C-V>p'
let g:user_emmet_togglecomment_key = '<C-V>/'
let g:user_emmet_install_global=1 
autocmd FileType html,css,eruby,erb EmmetInstall

" " YcmCompleter
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

" " Powerline
" let g:Powerline_symbols = 'fancy'

" }}}

" Mapping {{{
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j

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
inoremap <C-h> <left>
inoremap <C-l> <right>
inoremap <C-j> <C-o>gj
inoremap <C-k> <C-o>gk

" Convert all tabs to spaces
map <leader>ct :retab<cr>

" map <silent> <M-1> <ESC>:tabp<CR>
" map <silent> <M-2> <ESC>:tabn<CR>
" map <silent> <M-3> <ESC>:tabnew<CR>
" map <silent> <M-4> <ESC>:tabclose<CR>

map <leader>co :botright cope<cr>

" " Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
" nmap <M-j> mz:m+<cr>`z
" nmap <M-k> mz:m-2<cr>`z
" vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
" vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

" When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>

map <silent> <leader><cr> :nohlsearch<cr>
map <silent> <leader><bs> :set noincsearch<cr>
map <silent> <leader><leader><bs> :set incsearch<cr>

" AutoComple
inoremap <C-]>             <C-X><C-]>
inoremap <C-F>             <C-X><C-F>
inoremap <C-B>             <C-X><C-L>

" " Spell
" map <leader>ss :setlocal spell!<cr>
" map <leader>sn ]s
" map <leader>sp [s
" map <leader>sa zg
" map <leader>s? z=

" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>cm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

nnoremap @p4a :!p4 add %:p<cr>
nnoremap @p4e :!p4 edit %:p<cr>
nnoremap @p4d :!p4 diff %<cr>

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
autocmd BufWrite *.rb :call DeleteTrailingWS()
map <leader>ds :call DeleteTrailingWS()<CR>

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





" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" " Default fzf layout
" " - down / up / left / right
" let g:fzf_layout = { 'down': '~40%' }

" " In Neovim, you can set up fzf window using a Vim command
" let g:fzf_layout = { 'window': 'enew' }
" let g:fzf_layout = { 'window': '-tabnew' }

" " Customize fzf colors to match your color scheme
" let g:fzf_colors =
" \ { 'fg':      ['fg', 'Normal'],
  " \ 'bg':      ['bg', 'Normal'],
  " \ 'hl':      ['fg', 'Comment'],
  " \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  " \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  " \ 'hl+':     ['fg', 'Statement'],
  " \ 'info':    ['fg', 'PreProc'],
  " \ 'prompt':  ['fg', 'Conditional'],
  " \ 'pointer': ['fg', 'Exception'],
  " \ 'marker':  ['fg', 'Keyword'],
  " \ 'spinner': ['fg', 'Label'],
  " \ 'header':  ['fg', 'Comment'] }

" " [Files] Extra options for fzf
" "   e.g. File preview using Highlight
" "        (http://www.andre-simon.de/doku/highlight/en/highlight.html)
" let g:fzf_files_options =
  " \ '--preview "(highlight -O ansi {} || cat {}) 2> /dev/null | head -'.&lines.'"'

" " [Buffers] Jump to the existing window if possible
" let g:fzf_buffers_jump = 1

" " [[B]Commits] Customize the options used by 'git log':
" let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" " [Tags] Command to generate tags file
" let g:fzf_tags_command = 'ctags -R'

" " [Commands] --expect expression for directly executing the command
" let g:fzf_commands_expect = 'alt-enter,ctrl-x'

" " Command for git grep
" " - fzf#vim#grep(command, with_column, [options], [fullscreen])
" command! -bang -nargs=* GGrep
  " \ call fzf#vim#grep('git grep --line-number '.shellescape(<q-args>), 0, <bang>0)

" " We use VimEnter event so that the code is run after fzf.vim is loaded
" autocmd VimEnter * command! -bang Colors
  " \ call fzf#vim#colors({'left': '15%', 'options': '--reverse --margin 30%,0'}, <bang>0)

" " Augmenting Ag command using fzf#vim#with_preview function
" "   * fzf#vim#with_preview([[options], preview window, [toggle keys...]])
" "   * Preview script requires Ruby
" "   * Install Highlight or CodeRay to enable syntax highlighting
" "
" "   :Ag  - Start fzf with hidden preview window that can be enabled with "?" key
" "   :Ag! - Start fzf in fullscreen and display the preview window above
" autocmd VimEnter * command! -bang -nargs=* Ag
  " \ call fzf#vim#ag(<q-args>,
  " \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  " \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
  " \                 <bang>0)

" " Similarly, we can apply it to fzf#vim#grep. To use ripgrep instead of ag:
" command! -bang -nargs=* Rg
  " \ call fzf#vim#grep(
  " \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  " \   <bang>0 ? fzf#vim#with_preview('up:60%')
  " \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  " \   <bang>0)

" Mapping selecting mappings
nmap <c-p> :Files <cr>
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" " Advanced customization using autoload functions
" inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})
