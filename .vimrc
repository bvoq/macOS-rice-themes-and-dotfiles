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
" echom "OS is" g:os

Plug 'will133/vim-dirdiff'

if g:os == "Darwin"
elseif g:os == "Linux"
elseif g:os == "Windows"
Plug 'neomake/neomake' " nvim-lspconfig takes care of most things I cared about.
Plug 'OmniSharp/omnisharp-vim'
let g:OmniSharp_server_use_net6 = 1
Plug 'dense-analysis/ale'
endif




Plug 'kassio/neoterm' " better terminal, launch with T
Plug 'jnurmine/Zenburn'
" Plug 'ervandew/supertab' " tab instead of ctrl-n and ctrl-p

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

" OmniSharp - for C# development
" tab completion
inoremap <expr> <Tab> pumvisible() ? '<C-n>' :
\ getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>'
let g:OmniSharp_host = "http://localhost:2000" " default
set completeopt=longest,menuone,preview
" this setting controls how long to wait (in ms) before fetching type / symbol
set updatetime=500
" if using syntastic
" let g:syntastic_cs_checkers = ['code_checker']
augroup omnisharp_commands
    autocmd!
    "Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    " Synchronous build (blocks Vim)
    autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
    " Builds can also run asynchronously with vim-dispatch installed
    "autocmd FileType cs nnoremap <leader>b :wa!<cr>:OmniSharpBuildAsync<cr>
    " if syntastic: automatic syntax check on events (TextChanged requires Vim 7.4)
    " autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck
    " Automatically add new cs files to the nearest project on save (outdated)
    " autocmd BufWritePost *.cs call OmniSharp#AddToProject()
    "show type information automatically when the cursor stops moving
    " autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
    autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
    autocmd FileType cs nnoremap = :OmniSharpCodeFormat<cr>
    autocmd FileType cs nnoremap <leader>fi :OmniSharpFindImplementations<cr>
    autocmd FileType cs nnoremap <leader>ft :OmniSharpFindType<cr>
    autocmd FileType cs nnoremap <leader>fs :OmniSharpFindSymbol<cr>
    autocmd FileType cs nnoremap <leader>fu :OmniSharpFindUsages<cr>
    "finds members in the current buffer
    autocmd FileType cs nnoremap <leader>fm :OmniSharpFindMembers<cr>
    " cursor can be anywhere on the line containing an issue
    autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr>
    autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
    autocmd FileType cs nnoremap <leader>tt :OmniSharpTypeLookup<cr>
    autocmd FileType cs nnoremap <leader>dc :OmniSharpDocumentation<cr>
    "navigate up by method/property/field
    autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr>
    "navigate down by method/property/field
    autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr>
augroup END
" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
" Contextual code actions (requires CtrlP or unite.vim)
nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
" Run code actions with text selected in visual mode to extract method
vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>
" rename with dialog
nnoremap <leader>nm :OmniSharpRename<cr>
nnoremap <F2> :OmniSharpRename<cr>
" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")
" Force OmniSharp to reload the solution. Useful when switching branches etc.
nnoremap <leader>rl :OmniSharpReloadSolution<cr>
nnoremap <leader>cf :OmniSharpCodeFormat<cr>
" Load the current .cs file to the nearest project
" nnoremap <leader>tp :OmniSharpAddToProject<cr>
" Start the omnisharp server for the current solution
nnoremap <leader>ss :OmniSharpStartServer<cr>
nnoremap <leader>sp :OmniSharpStopServer<cr>
" Add syntax highlighting for types and interfaces
nnoremap <leader>th :OmniSharpHighlightTypes<cr>
" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
" Enable heavy omni completion.
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
" more emacs like keybindings
nnoremap <C-o><C-u> :OmniSharpFindUsages<CR>
nnoremap <C-o><C-d> :OmniSharpGotoDefinition<CR>
nnoremap <C-o><C-d><C-p> :OmniSharpPreviewDefinition<CR>




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
" Fzf plugin
set rtp+=/usr/local/opt/fzf


""" Custom commands
command! ErrorRegex execute "/\\v\([a-zA-Z_-]\)\@<!\(error\|missing\|unknown\|except\|not found\|fail\|unavailable\|issue\|problem\|fault\|code 1\|crash(\\%(!lytics))\)"


""" Various vim settings
syntax on
set ignorecase
set hlsearch
set smartcase
set nobackup " swap files are enough
set hidden " hide buffers instead of closing them.
set switchbuf=usetab,newtab,useopen
"set nu " set rnu for relative numbering.
set paste " only set if needed
set list
set showbreak=↪\
set listchars=tab:↦-,nbsp:␣,trail:∙,extends:⟩,precedes:⟨
set autoindent tabstop=4 softtabstop=0 shiftwidth=4 expandtab
set splitbelow "move preview window to below, so it doesn't move the code
" some people prefer , as leader, default is \
" let mapleader = ","
" let localmapleader = "\Space"

if g:os == "Windows"
  set mouse-=a
endif

" Vim Rabbit Hole Hierarchy:
" ---
" BUFFERS
" use buffers when navigating code in the same context.
" when closing vim only unsaved buffers will block you from quitting
" for example when looking up a definition using gd, gD, \ti, \ti
" :bp :bn buffer previous/next

" TAB PAGES
" gt gT 3gt to switch between tabs
" :tabn :tabp to switch between tabs
" :tabs
" spread buffers into tab pages: sball

" WINDOWS
" :vsplit and :split
" <c-w><c-w> to switch between windows
" spread buffers into windows :vertical ball 
" VIMGREP , note ** is globstar
" :vimgrep /DistributionStatus/g %:h/** 
" use :cnext :cprevious :clist or :lnext :lprevious :llist for :lvimgrep
