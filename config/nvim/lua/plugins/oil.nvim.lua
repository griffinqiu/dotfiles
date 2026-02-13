return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    keymaps = {
      ["<C-r>"] = "actions.refresh",
      ["<C-l>"] = false,
      ["-"] = false,
      ["h"] = "actions.parent",
      ["l"] = "actions.select",
      ["q"] = "actions.close",
    },
  },
  keys = {
    { "<leader>fo", "<CMD>Oil<CR>", desc = "Open parent directory" },
    {
      "<leader>o",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open parent directory (float)",
    },
  },
}
