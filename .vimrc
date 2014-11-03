" Statusline formatting
set laststatus=2
set statusline=%F%m%r\ %l:%c\ (%L\ total)\ %p%%
"set statusline+=%40{strftime(\"%l:%M:%S\ \%p,\ %a\ %b\ %d,\ %Y\")}

set encoding=utf8

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

" Enable filetype plugins?
filetype indent plugin on
" Syntax highlighting
syntax on

" Toggle F3 for spell check
map <F3> <ESC>:set spell!<CR>
" Toggle F4 paste mode
map <F4> <ESC>:set paste!<CR>
