return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    enabled = not vim.g.use_codecompanion,
    opts = function(_, opts)
      opts.auto_insert_mode = false
      return opts
    end,
    keys = {
      {
        "<leader>2",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "q",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<c-c>",
        function()
          return require("CopilotChat").stop()
        end,
        desc = "Stop (CopilotChat)",
        mode = { "i", "n", "v" },
      },

      {
        "<leader>ax",
        false,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "gx",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
    },
  },
}
