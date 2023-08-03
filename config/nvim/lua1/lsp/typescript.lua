local lspconfig = require("lspconfig")

lspconfig.tsserver.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = require'lsp.attacher',
}
lspconfig.pyright.setup {
  capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = require'lsp.attacher',
}

vim.cmd(([[
autocmd FileType typescript lua require'cmp'.setup.buffer {
\   sources = {
\     { name = 'vsnip' },
\     { name = 'nvim_lsp' },
\   },
\ }
autocmd BufWritePre *.ts lua vim.lsp.buf.formatting()
]]))