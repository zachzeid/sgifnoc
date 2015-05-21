set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Bundle 'scrooloose/syntastic'

Plugin 'hynek/vim-python-pep8-indent'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line" Statusline formatting
"
" ----------------------------------------------------------------
"
set laststatus=2
set statusline=%F%m%r\ %l:%c\ (%L\ total)\ %p%%
"set statusline+=%40{strftime(\"%l:%M:%S\ \%p,\ %a\ %b\ %d,\ %Y\")}

set encoding=utf8
set ttyfast

set backspace=eol,start,indent
set expandtab     " insert spaces when hitting TABs
set shiftround    " round indent to multiple of 'shiftwidth'
set autoindent    " align the new line indent with the previous line

" 4 spaces for tabs
set shiftwidth=4  " operation >> indents 4 columns; << unindents 4 columns
set tabstop=4     " an hard TAB displays as 4 columns
set softtabstop=4 " insert/delete 4 spaces when hitting a TAB/BACKSPACE

" Shows line numbers
set number

" Shows column/row of cursor in status line
"set ruler
"set rulerformat=%l\:%c 

" Lines of history to remember
set history=1000

" Highlight search results
set hlsearch
" Search as you type
set incsearch

" Syntax highlighting
syntax on

" Toggle F3 for spell check
map <F3> <ESC>:set spell!<CR>
" Toggle F4 paste mode
map <F4> <ESC>:set paste!<CR>
" Alternate option
":set pastetoggle=<f5>

let g:syntastic_check_on_open = 1
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_json_checkers = ['jsonlint']
let g:syntastic_javascript_checkers = ['jshint']

" Show PEP8 max line width only if editing .py files
autocmd BufNewFile,BufRead *.py set colorcolumn=100
autocmd BufNewFile,BufRead *.py highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
autocmd BufRead,BufNewFile *.json set filetype=json

" Add horizontally spanning line beneath current cursor position
set cursorline 
" Add vertion line at cursor position
set cursorcolumn

" Completion assistance
set wildmenu
set wildmode=list:longest

" Easier insert escape
inoremap jk <esc>
