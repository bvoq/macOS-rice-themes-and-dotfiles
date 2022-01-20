set encoding=utf-8
set nocp " don't need arcane vi support

if has('nvim')
call plug#begin('~/.local/share/nvim/plugged')
else
call plug#begin('~/.vim/plugged')
end

Plug 'kassio/neoterm' " better terminal, launch with T
Plug 'jnurmine/Zenburn'

" Allows :History
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Smoother scrolling
Plug 'petertriho/nvim-scrollbar'

""" neovim only
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

""" Plugins I stopped using
"Plug 'Valloric/YouCompleteMe' " now using nvim-lspconfig (language servers) instead. Pain to setup.
"Plug 'neomake/neomake' " nvim-lspconfig takes care of most things I cared about.
"Plug 'jupyter-vim/jupyter-vim'
"Plug 'vim-airline/vim-airline' " prefer using minimal vim look
"Plug 'vim-airline/vim-airline-themes'
"Plug 'jceb/vim-orgmode'
"Plug 'tpope/vim-speeddating' " required for org-mode

call plug#end()


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
autocmd BufRead,BufNewFile *.py let python_highlight_all=1
"let g:neomake_place_signs = 0 " disable the error column
"set signcolumn=no " needed for some neomake configs
"autocmd FileType python map <buffer> <leader>s :Neomake<CR><c-w><c-w>
"autocmd BufWritePost * :Neomake
"hi NeomakeErrorSign ctermfg=160 guifg=#ff0000
"hi NeomakeVirtualtextError ctermfg=203 guifg=#bfbfbf


""" nvim-lspconfig
set completeopt=menu,menuone,noselect

lua << EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- other language servers: clangd', 'rust_analyzer', 'pyright', 'tsserver'
  -- TODO: Add your own languageservers here.
  -- See: https://github.com/neovim/nvim-lspconfig/blob/b01c0d0542c7a942f8f2ebf1232e0557a85a9045/doc/server_configurations.md
  require('lspconfig')['pyright'].setup {
    capabilities = capabilities
  }
  require'lspconfig'.bashls.setup{
    capabilities = capabilities
  }

EOF

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gD <plug>(lsp-declaration)
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    inoremap <buffer> <expr><c-f> lsp#scroll(+4)
    inoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


""" Tamarin source code (for .spthy and .sapic)
augroup filetypedetect
au BufNewFile,BufRead *.spthy	setf spthy
au BufNewFile,BufRead *.sapic	setf sapic
augroup END

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
set hidden " hide buffers instead of closing them.
"set nu " set rnu for relative numbering.
set paste
set list
set ruler
set showbreak=↪\
set listchars=tab:↦-,nbsp:␣,trail:∙,extends:⟩,precedes:⟨
set autoindent tabstop=4 softtabstop=0 shiftwidth=4 expandtab
" let mapleader = ","
nnoremap <F6> yiw:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>
vnoremap <F6> y:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>
" delete the black hole register: https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text
" so i can use vi"p
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>
" repeat last macro
nnoremap Q @@
if has('nvim')
    set inccommand=nosplit
endif
set mouse=a " for mouse to work in tmux and vim
