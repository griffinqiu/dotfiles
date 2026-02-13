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

      opts.setup = opts.setup or {}
    end,
  },
}
