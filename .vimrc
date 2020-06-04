" Note: https://ricostacruz.com/til/neovim-with-python-on-osx
" Note: https://github.com/neovim/neovim/wiki/FAQ#python-support-isnt-working
" Note: https://github.com/neovim/neovim/wiki/Following-HEAD#20181118
" Note: Updating vim or installing/updating YouCompleteMe
" pip3 uninstall neovim pynvim
" pip3 install pynvim
" pip3 install neovim
" For Neovim: ~/.local/share/nvim/plugged/YouCompleteMe/install.py --clang-completer
" For Vim8: ~/.vim/plugged/YouCompleteMe/install.py --clang-completer
" Note: Better python error checking for neomake:
" pip3 install flake8

let g:python3_host_prog = '/usr/local/bin/python3'

set encoding=utf-8
set nocp
let python_highlight_all=1
syntax on
"set nu " set rnu for relative numbering
set hidden

set tabstop=4
set autoindent softtabstop=0 noexpandtab
set shiftwidth=4

tnoremap <Esc> <C-\><C-n>
" make sure that the ESC button works the same in the terminal window (useful to change the window)

if has('nvim')
call plug#begin('~/.local/share/nvim/plugged')
else
call plug#begin('~/.vim/plugged')
end
Plug 'Valloric/YouCompleteMe' " for auto completion, see note for installation)
Plug 'kassio/neoterm' " better terminal, launch with T
Plug 'jupyter-vim/jupyter-vim'
Plug 'jnurmine/Zenburn'
"Plug 'vim-airline/vim-airline' " nice 
"Plug 'vim-airline/vim-airline-themes'
Plug 'neomake/neomake'
"Plug 'jceb/vim-orgmode'
"Plug 'tpope/vim-speeddating' " required for org-mode
call plug#end()

" Zenburn theme options (background is 1D1C1C)
:let g:zenburn_high_Contrast=1
:colors zenburn

" if you use zenburn high_contrast use raven
let g:airline_theme = 'zenburn' " use with standard contrast zenburn
" let g:airline_theme = 'raven' " use with high contrast zenburn



""" YouCompleteMe
" Cycle through suggestions using tab or <C-P> or <C-N>
" Force auto-complete with <C-Space>
" go to definition else declaration ,jd (where ,=leader)
" use <S-K> to open documentation
let g:ycm_global_ycm_extra_conf = "'.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'"
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_confirm_extra_conf = 0

let mapleader = ","
let g:ycm_goto_buffer_command = 'vertical-split'
" nnoremap <leader>jd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <leader>gd :YcmCompleter GoToDeclaration<CR>
" also use shift+K for documentation



""" Neomake
" use :lopen and :lclose to see a list of errors!
let g:neomake_place_signs = 0 " disable the error column
set signcolumn=no " needed for some neomake configs
"let g:neomake_highlight_columns = 0
"let g:neomake_highlight_lines = 0
autocmd FileType python map <buffer> <leader>s :Neomake<CR><c-w><c-w>
autocmd BufWritePost * :Neomake

hi NeomakeErrorSign ctermfg=160 guifg=#ff0000
hi NeomakeVirtualtextError ctermfg=203 guifg=#bfbfbf



""" Tamarin source code (for .spthy and .sapic)
augroup filetypedetect
au BufNewFile,BufRead *.spthy	setf spthy
au BufNewFile,BufRead *.sapic	setf sapic
augroup END



""" File executions
" Run with Shift+R
autocmd FileType python map <buffer> <S-r> :w<CR>:exec 'w !python3' shellescape(@%, 1)<CR>
autocmd FileType cpp map <buffer> <S-r> :w<CR>:exec 'w !g++ -std=c++17 -Wall -Wextra -g3 -ggdb3 -fsanitize=address ' shellescape(@%, 1) ';./a.out' <CR>
