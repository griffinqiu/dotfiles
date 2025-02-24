return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
      }
      opts.lsp.signature = {
        auto_open = { enabled = false },
      }
    end,
  },
}
