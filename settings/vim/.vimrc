execute pathogen#infect()

filetype plugin indent on

function! StatusLine(current, width)
  return (a:current ? crystalline#mode() . '%#Crystalline#' : '%#CrystallineInactive#')
        \ . ' %f%h%w%m%r '
        \ . (a:current ? '%#CrystallineFill# %{fugitive#head()} ' : '')
        \ . '%=' . (a:current ? '%#Crystalline# %{&paste?"PASTE ":""}%{&spell?"SPELL ":""}' . crystalline#mode_color() : '')
        \ . (a:width > 80 ? ' %{&ft}[%{&enc}][%{&ffs}] %l/%L %c%V %P ' : ' ')
endfunction

let g:crystalline_statusline_fn = 'StatusLine'
let g:crystalline_theme = 'default'

set laststatus=2

call plug#begin()
Plug('rbong/vim-crystalline')
call plug#end()

syntax on
filetype on

"set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set number
