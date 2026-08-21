return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    -- Splits match snacks.picker and neo-tree: <C-s> stacks, <C-v> side by side.
    -- <C-h>/<C-l>/<C-r> are left to window navigation and redo.
    keymaps = {
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["<C-r>"] = false,
      ["-"] = false,
      ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-v>"] = { "actions.select", opts = { vertical = true } },
      ["gr"] = "actions.refresh",
      ["h"] = "actions.parent",
      ["<BS>"] = "actions.parent",
      ["l"] = "actions.select",
      ["q"] = "actions.close",
      ["<2-LeftMouse>"] = "actions.select",
    },
  },
  keys = {
    {
      "<leader>o",
      function()
        require("oil").toggle_float()
      end,
      desc = "Open parent directory (float)",
    },
    { "<leader>O", "<CMD>Oil<CR>", desc = "Open parent directory" },
  },
}
