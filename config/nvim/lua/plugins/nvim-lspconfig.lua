return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.settings = opts.settings or {}
      opts.settings.signatureHelp = opts.settings.signatureHelp or {}
      opts.settings.signatureHelp.triggerCharacters = {}

      opts.diagnostics = opts.diagnostics or {}
      opts.diagnostics.virtual_text = false
      opts.diagnostics.virtual_lines = opts.diagnostics.virtual_lines or {}
      opts.diagnostics.virtual_lines.only_current_line = true

      opts.servers = opts.servers or {}
      opts.servers.gopls = {}
      opts.servers.marksman = {
        on_attach = function(_, bufnr)
          vim.diagnostic.disable(bufnr)
        end,
        settings = {
          marksman = {
            diagnostics = {
              enabled = false,
            },
          },
        },
      }
    end,
  },
}
