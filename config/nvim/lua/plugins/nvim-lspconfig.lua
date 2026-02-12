return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.settings = opts.settings or {}
      opts.settings.signatureHelp = opts.settings.signatureHelp or {}
      opts.settings.signatureHelp.triggerCharacters = {}

      opts.servers = opts.servers or {}
      opts.servers.gopls = {}
      opts.servers.lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      }

      opts.setup = opts.setup or {}
      opts.setup.clangd = function(_, opts)
        opts.capabilities.offsetEncoding = { "utf-16" }
      end
    end,
  },
}
