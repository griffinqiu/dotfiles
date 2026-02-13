return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = function(_, opts)
      vim.lsp.inlay_hint.enable(false)

      opts.settings = opts.settings or {}
      opts.settings.signatureHelp = opts.settings.signatureHelp or {}
      opts.settings.signatureHelp.triggerCharacters = {}

      opts.servers = opts.servers or {}
      opts.servers.gopls = {}
      opts.servers.lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              disable = {
                "deprecated",
                "unused-local",
                "undefined-field",
                "need-check-nil",
                "missing-fields",
                "undefined-global",
                "redefined-local",
                "undefined-doc-name",
              },
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      }

      opts.setup = opts.setup or {}
      opts.setup.clangd = function(_, clangd_opts)
        clangd_opts.capabilities.offsetEncoding = { "utf-16" }
      end
    end,
  },
}
