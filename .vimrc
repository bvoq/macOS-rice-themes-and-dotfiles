set encoding=utf-8
set nocp " don't need arcane vi support

if has('nvim')
call plug#begin('~/.local/share/nvim/plugged')
else
call plug#begin('~/.vim/plugged')
end

if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" List messages using :messages
echom "OS is" g:os

if g:os == "Darwin"
elseif g:os == "Linux"
elseif g:os == "Windows"
Plug 'neomake/neomake' " nvim-lspconfig takes care of most things I cared about.
endif

Plug 'kassio/neoterm' " better terminal, launch with T
Plug 'jnurmine/Zenburn'

""" neovim only
"Plug 'neovim/nvim-lspconfig'
"Plug 'hrsh7th/cmp-nvim-lsp'
"Plug 'hrsh7th/cmp-buffer'
"Plug 'hrsh7th/cmp-path'
"Plug 'hrsh7th/cmp-cmdline'
"Plug 'hrsh7th/nvim-cmp'
"Plug 'hrsh7th/cmp-vsnip'
"Plug 'hrsh7th/vim-vsnip'

""" Plugins I stopped using
"Plug 'Valloric/YouCompleteMe' " now using nvim-lspconfig (language servers) instead. Pain to setup.
"Plug 'neomake/neomake' " nvim-lspconfig takes care of most things I cared about.
"Plug 'jupyter-vim/jupyter-vim'
"Plug 'vim-airline/vim-airline' " prefer using minimal vim look
"Plug 'vim-airline/vim-airline-themes'
"Plug 'jceb/vim-orgmode'
"Plug 'tpope/vim-speeddating' " required for org-mode

call plug#end()

autocmd BufRead,BufNewFile *.py let python_highlight_all=1

""" Zenburn theme
:let g:zenburn_high_Contrast=1
:colors zenburn

""" airline-theme compatible with Zenburn
let g:airline_theme = 'zenburn'

""" YouCompleteMe (Now using nvim-lspconfig instead)
" pip3 uninstall neovim pynvim
" pip3 install pynvim
" pip3 install neovim
" Note: https://ricostacruz.com/til/neovim-with-python-on-osx
" Note: https://github.com/neovim/neovim/wiki/FAQ#python-support-isnt-working
" Note: https://github.com/neovim/neovim/wiki/Following-HEAD#20181118
" For Neovim: ~/.local/share/nvim/plugged/YouCompleteMe/install.py --clang-completer
" For Vim8: ~/.vim/plugged/YouCompleteMe/install.py --clang-completer
let g:ycm_global_ycm_extra_conf = "'.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'"
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_confirm_extra_conf = 0
let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'debug'
let g:ycm_goto_buffer_command = 'vertical-split'
" nnoremap <leader>jd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<CR>
nnoremap <leader>gd :YcmCompleter GoToDeclaration<CR>


""" Neomake
" Note: Better python error checking for neomake:
" pip3 install flake8
" use :lopen and :lclose to see a list of errors!
let g:neomake_place_signs = 0 " disable the error column
set signcolumn=no " needed for some neomake configs
autocmd FileType python map <buffer> <leader>s :Neomake<CR><c-w><c-w>
autocmd BufWritePost * :Neomake
hi NeomakeErrorSign ctermfg=160 guifg=#ff0000
hi NeomakeVirtualtextError ctermfg=203 guifg=#bfbfbf


""" Tamarin source code (for .spthy and .sapic)
" augroup filetypedetect
" au BufNewFile,BufRead *.spthy	setf spthy
" au BufNewFile,BufRead *.sapic	setf sapic
" augroup END

"""" File executions
"" Run with Shift+R
"autocmd FileType python map <buffer> <S-r> :w<CR>:exec 'w !python3' shellescape(@%, 1)<CR>
"autocmd FileType cpp map <buffer> <S-r> :w<CR>:exec 'w !g++ -std=c++17 -Wall -Wextra -g3 -ggdb3 -fsanitize=address ' shellescape(@%, 1) ';./a.out' <CR>


" Trim Whitespace at the end of the line.
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! TrimWhitespace call TrimWhitespace()


""" Various vim settings
syntax on
set nobackup " swap files are enough
set hidden " hide buffers instead of closing them.
"set nu " set rnu for relative numbering.
set paste
set list
set showbreak=↪\
set listchars=tab:↦-,nbsp:␣,trail:∙,extends:⟩,precedes:⟨
set autoindent tabstop=4 softtabstop=0 shiftwidth=4 expandtab
" let mapleader = ","

" useful commands
" :vimgrep /DistributionStatus/g %:h/*

