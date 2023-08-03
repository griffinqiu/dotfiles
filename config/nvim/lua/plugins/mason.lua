return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls",
        "pyright",
        "solargraph",
        "lua_ls",
        "tsserver",
      },
      automatic_installation = true,
      handlers = {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
          require("lspconfig")[server_name].setup {}
        end,
         -- -- Next, you can provide targeted overrides for specific servers.
         -- ["rust_analyzer"] = function ()
             -- require("rust-tools").setup {}
         -- end,
        -- ["lua_ls"] = function ()
        -- lspconfig.lua_ls.setup {
          -- settings = {
            -- Lua = {
              -- diagnostics = {
                -- globals = { "vim" }
              -- }
            -- }
          -- }
        -- }
        -- end,
      },
    })
    local lspconfig = require('lspconfig')
    lspconfig.gopls.setup {}
    lspconfig.pyright.setup {}
    lspconfig.solargraph.setup {}
    lspconfig.lua_ls.setup {}
    lspconfig.tsserver.setup {}

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts) -- gt
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts) -- ga
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end,
    })


    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Enable underline, use default values
        underline = true,
        -- Enable virtual text, override spacing to 8
        -- virtual_text = {
          -- spacing = 8,
          -- prefix = '~',
        -- },
        virtual_text = false,
        -- Use a function to dynamically turn signs off
        -- and on, using buffer local variables
        signs = function(bufnr, client_id)
          local ok, result = pcall(vim.api.nvim_buf_get_var, bufnr, 'show_signs')
          -- No buffer local variable set, so just enable by default
          if not ok then
            return true
          end

          return result
        end,
        -- Disable a feature
        update_in_insert = false,
      }
    )
  end,
}
