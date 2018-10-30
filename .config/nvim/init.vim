" TODO Before running
" Note: https://ricostacruz.com/til/neovim-with-python-on-osx
" Note: If you initialise vim instead of nvim make sure to change plug#begin
" and also the location of ycm_extra_conf.py
" Note: Then run PlugInstall
" Note: Lastly compile YCM by going to the location specified by plug#begin
" and then compile using ./install.py --clang-completer

set encoding=utf-8
set nocp
syntax on
set rnu nu

set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4


call plug#begin('~/.local/share/nvim/plugged') " for regular VIM location is '~/.vim/plugged'
Plug 'Valloric/YouCompleteMe' " for auto completion, see note for installation
Plug 'neomake/neomake' " async linting
Plug 'jnurmine/Zenburn'
" Plug 'vim-airline/vim-airline' " nice 
" Plug 'vim-airline/vim-airline-themes'
Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating' " required for org-mode
call plug#end()

" Zenburn theme options (background is 1D1C1C)
:let g:zenburn_high_Contrast=1
:colors zenburn

let g:airline_theme = 'raven' " good ones include deus, minimalist, onedark, raven


let g:ycm_global_ycm_extra_conf = "~/.config/nvim/ycm_extra_conf.py"
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_confirm_extra_conf = 0
let g:ycm_python_binary_path = 'python'
