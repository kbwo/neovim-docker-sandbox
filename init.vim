" init.vim example for Neovim LSP setup
let mapleader="\<Space>"

set ignorecase
set smartcase
set wildignorecase

map K gt
map J gT
nmap j gj
nmap k gk
nmap Q :CloseToggletermBuffers<CR>:confirm qa<CR>
nmap R :join<CR>
nmap <Down> gj
nmap <Up> gk
nmap + <C-a>
nmap - <C-x>
nmap <c-t> :tabnew<CR>
nmap <Leader>l :lcd %:h<CR>
nmap <Leader>h :noh<CR>

call plug#begin('~/.local/share/nvim/plugged')

" LSP plugins
Plug 'neovim/nvim-lspconfig'         " Collection of configurations for the built-in LSP client
Plug 'nvim-lua/plenary.nvim'         " Useful Lua functions for other plugins
Plug 'nvim-telescope/telescope.nvim' " Fuzzy finder for enhanced navigation
Plug 'simrat39/rust-tools.nvim'      " Extra functionality for Rust development

" Add Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Add a colorscheme (you can choose a different one if you prefer)
Plug 'folke/tokyonight.nvim'

" Add mason.nvim and related plugins
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

call plug#end()

" Enable LSP for Python and Rust
lua << EOF
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')
local util = require "lspconfig/util"

-- Check if the config already exists to avoid redefining it
-- if not configs.testing_ls then
  configs.testing_ls = {
    default_config = {
      cmd = { "testing-language-server" },
      filetypes = { "rust" },
      root_dir = util.root_pattern(".git", "Cargo.toml"),
        init_options = {
          enable = true,
          fileTypes = { "rust" },
          adapterCommand = {
            rust = {
              {
                path = "testing-ls-adapter",
                extra_args = { "--test-kind=cargo-test", "--workspace" },
                include_patterns = { "/**/*.rs" },
                exclude_patterns = { "/demo/**/*" },
                workspace_dir = "."
              }
            }
          },
          enableWorkspaceDiagnostics = true,
          trace = {
            server = "verbose"
          }
        }
    },
    -- You can keep the on_new_config if needed
    -- on_new_config = function(new_config) end,
    docs = {
      description = [[
        https://github.com/agda/agda-language-server

        Language Server for Agda.
      ]],
    },
  }
-- end

-- Enable debug logging for LSP
vim.lsp.set_log_level("debug")

-- Setup the testing_ls server
lspconfig.testing_ls.setup{
    on_attach = function(client, bufnr)
        print("testing_ls on_attach called for buffer:", bufnr)
        print("Client name:", client.name)
        print("Client capabilities:", vim.inspect(client.server_capabilities))
    end,
    on_init = function(client)
        print("testing_ls server initialized")
        print("Client config:", vim.inspect(client.config))
    end,
    on_exit = function(code, signal, client_id)
        print("testing_ls server exited with code:", code)
        print("Signal:", signal)
        print("Client ID:", client_id)
    end,
}

local rt = require("rust-tools")

rt.setup({
server = {
  on_attach = function(_, bufnr)
  -- Hover actions
  vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
  -- Code action groups
  vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
  end,
},
})

require("mason").setup()
require("mason-lspconfig").setup({
ensure_installed = { "pyright", "rust_analyzer" },
})

local lspconfig = require('lspconfig')

-- Setup language servers
lspconfig.rust_analyzer.setup {}

-- ... existing Rust Tools setup ...
EOF

" Configure Treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "rust", "vim", "lua" },
  highlight = {
    enable = true,
  },
}
EOF

" Set colorscheme
set termguicolors
colorscheme tokyonight

" General settings
syntax on
set number
set relativenumber

" Keybindings for LSP
nnoremap <silent> gd :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> csd :lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gr :lua vim.lsp.buf.references()<CR>
nnoremap <silent> gD :lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gi :lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <leader>rn :lua vim.lsp.buf.rename()<CR>

" Telescope keybinding
nnoremap <silent> <c-p> :Telescope find_files<CR>
nnoremap <silent> <leader>rr :Telescope live_grep<CR>

" Add a command to open the LSP log
command! LspLog execute 'edit ' .. vim.lsp.get_log_path()

" ... rest of your init.vim ...
