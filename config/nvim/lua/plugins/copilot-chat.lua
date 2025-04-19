return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "VeryLazy",
    enabled = vim.g.ai_partner == "copilot-chat",
    opts = function(_, opts)
      opts.auto_insert_mode = false
      return opts
    end,
    keys = {
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
