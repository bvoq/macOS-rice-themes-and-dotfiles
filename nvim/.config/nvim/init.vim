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

Plug 'quarto-dev/quarto-nvim'
Plug 'jmbuhr/otter.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" color codes:
Plug 'norcalli/nvim-colorizer.lua'

" DirDiff
Plug 'will133/vim-dirdiff'

" copilot
Plug 'github/copilot.vim'

""" Plugins I stopped using
"Plug 'neomake/neomake' " nvim-lspconfig takes care of most things I cared about.
"Plug 'jupyter-vim/jupyter-vim'
"Plug 'vim-airline/vim-airline' " prefer using minimal vim look
"Plug 'vim-airline/vim-airline-themes'
"Plug 'jceb/vim-orgmode'
"Plug 'tpope/vim-speeddating' " required for org-mode

call plug#end()

lua << EOF
  -- Compatibility shim for plugins that still call deprecated vim.tbl_flatten.
  if vim.fn.has('nvim-0.11') == 1 and vim.iter then
    vim.tbl_flatten = function(t)
      return vim.iter(t):flatten(math.huge):totable()
    end
  end
EOF

lua << EOF
  local ok, quarto = pcall(require, 'quarto')

  if ok then
    quarto.setup({
      lspFeatures = {
        enabled = true,
        diagnostics = {
          enabled = true,
          triggers = { 'BufWritePost' },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = false,
      },
    })

    vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true, desc = 'Quarto preview' })
  end
EOF


""" Zenburn theme
:let g:zenburn_high_Contrast=1
:colors zenburn

""" airline-theme compatible with Zenburn
let g:airline_theme = 'zenburn'

""" colorizer
if (has("termguicolors"))
  if $TERM_PROGRAM != "Apple_Terminal"
    set termguicolors
    lua require 'colorizer'.setup()
  endif
endif

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
      ['<C-n>'] = cmp.mapping({
        c = function()
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                vim.api.nvim_feedkeys(t("<Down>"), "n", true)
            end
        end,
        i = function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end,
    }),
    ['<C-p>'] = cmp.mapping({
        c = function()
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
                vim.api.nvim_feedkeys(t("<Up>"), "n", true)
            end
        end,
        i = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end,
    }),
    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --   if require("copilot.suggestion").is_visible() then
    --     require("copilot.suggestion").accept()
    --   elseif cmp.visible() then
    --     cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
    --   elseif luasnip.expandable() then
    --     luasnip.expand()
    --   elseif has_words_before() then
    --     cmp.complete()
    --   else
    --     fallback()
    --   end
    -- end, {
    --   "i",
    --   "s",
    -- }),
    -- ['<S-Tab>'] = cmp.mapping(function()
    --   if cmp.visible() then
    --     cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
    --   end
    -- end, {
    --   "i",
    --   "s",
    -- }),
 
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

  -- Setup LSP servers using Neovim 0.11+ APIs.
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- other language servers: clangd', 'rust_analyzer', 'pyright', 'tsserver'
  -- TODO: Add your own languageservers here.
  -- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
  vim.lsp.config('pyright', {
    capabilities = capabilities
  })
  vim.lsp.enable('pyright')

  vim.lsp.config('bashls', {
    capabilities = capabilities
  })
  vim.lsp.enable('bashls')

  vim.lsp.config('dartls', {
    cmd = { "dart", 'language-server', '--protocol=lsp' },
    capabilities = capabilities
  })
  vim.lsp.enable('dartls')

EOF

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

" Fzf plugin
if has('macunix')
  set rtp+=/opt/homebrew/opt/fzf
else
  set rtp+=/usr/local/opt/fzf
endif

" Copilot
imap <silent> <C-j> <Plug>(copilot-next)
imap <silent> <C-k> <Plug>(copilot-previous)

""" Custom commands
command! ErrorRegex execute "/\\v\([a-zA-Z_-]\)\@<!\(error\|missing\|unknown\|except\|not found\|fail\|unavailable\|issue\|problem\|fault\|invalid\|code 1\|crash(\\%(!lytics))\)"



""" Various vim settings
syntax on
set ignorecase
set hidden " hide buffers instead of closing them.
"set nu " set rnu for relative numbering.
set list
set ruler
set smartcase " sets case sensitivity if there is a capital letter
" If you still want to search without case sensitivity, do "\C" before the search.
set showbreak=↪\
set listchars=tab:↦-,nbsp:␣,trail:∙,extends:⟩,precedes:⟨
set autoindent tabstop=4 softtabstop=0 shiftwidth=4 expandtab
set splitbelow  "move preview window to below, so it doesn't move the code
" some people prefer , as leader, default is \
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
" VIMGREP
" :vimgrep /DistributionStatus/g %:h/**
" use :cnext :cprevious :clist or :lnext :lprevious :llist for :lvimgrep
