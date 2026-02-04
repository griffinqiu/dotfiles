return {
  {
    "nvim-mini/mini.files",
    keys = {
      {
        "<leader>e",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
          end
        end,
        desc = "Explorer mini.files (Dir of Current File)",
      },
      {
        "<leader>E",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            MiniFiles.open(vim.uv.cwd(), true)
          end
        end,
        desc = "Explorer mini.files (cwd)",
      },
    },
    opts = function(_, opts)
      opts.mappings = opts.mappings or {}
      opts.mappings.go_in_plus = "<CR>"
      return opts
    end,
  },
}
