set guifont=Hack\ NF:h20
call plug#begin('~/.vim/plugged')
" Make sure you use single quotes
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'pangloss/vim-javascript'
Plug 'overcache/NeoSolarized'
Plug 'NLKNguyen/papercolor-theme'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'nanotech/jellybeans.vim'
Plug 'glepnir/lspsaga.nvim'
Plug 'sbdchd/neoformat'
" main one
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
" 9000+ Snippets
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

Plug 'windwp/nvim-autopairs'
Plug 'neovim/nvim-lspconfig'


" Initialize plugin system
call plug#end()
let g:coq_settings = { 'auto_start': 'shut-up' }
set number
syntax on
set termguicolors
set mouse +=a
colorscheme NeoSolarized
set background=dark
nnoremap q <c-v>
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <F1> :Files<CR>
nnoremap <C-p> :Ag<CR>
nnoremap <Space> :nohlsearch<CR>
imap jk <ESC>
imap JK <ESC>
let mapleader = ","

" lsp saga
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent>gh :Lspsaga lsp_finder<CR>
nnoremap <silent><leader>ca :Lspsaga code_action<CR>
vnoremap <silent><leader>ca :<C-U>Lspsaga range_code_action<CR>
nnoremap <silent>gr :Lspsaga rename<CR>
nnoremap <silent> gd :Lspsaga preview_definition<CR>
nnoremap <silent> <C-t> :Lspsaga open_floaterm<CR>



set encoding=utf-8

lua << EOF

local nvim_lsp = require('lspconfig')
local saga = require 'lspsaga'
local coq = require "coq" -- add this


require'lspconfig'.pyright.setup{
cmd =  {"pyright-langserver", "--stdio"},
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true
        }
      }
    },
  filetypes = { "python" }

}
require'lspconfig'.html.setup{
cmd = { "vscode-html-language-server", "--stdio" },
    filetypes = { "html" },
    init_options = {
      configurationSection = { "html", "css", "javascript" },
      embeddedLanguages = {
        css = true,
        javascript = true
      }
}
}
require'lspconfig'.tsserver.setup{
cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
    init_options = {
      hostInfo = "neovim"
    }
  }

require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})

local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false } }

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.CR = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<c-y>')
    else
      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
    end
  else
    return npairs.autopairs_cr()
  end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
    return npairs.esc('<c-e>') .. npairs.autopairs_bs()
  else
    return npairs.autopairs_bs()
  end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })



saga.init_lsp_saga {
  error_sign = '❌',
  warn_sign = '❕',
  hint_sign = '⁉',
  infor_sign = '',
  border_style = "round",
}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'html', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF


augroup fmt
  autocmd!
  autocmd BufWritePre * undojoin | Neoformat
augroup END
highlight clear LineNr
set cmdheight=1


" neovide
let neovide_remember_window_size = v:true
let g:coq_settings = { 'display.pum.fast_close': v:false }
