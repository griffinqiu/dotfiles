-- Both entry points pin the tab's cwd to the project root so `=` and relative
-- paths resolve there, while the view stays on the current file's directory.
local function pin_cwd_to_root()
  local root = LazyVim.root()
  if vim.uv.cwd() ~= root then
    vim.cmd.tcd(vim.fn.fnameescape(root))
  end
end

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
      ["_"] = false,
      ["="] = "actions.open_cwd",
    },
  },
  keys = {
    {
      "<leader>o",
      function()
        pin_cwd_to_root()
        require("oil").toggle_float()
      end,
      desc = "Open parent directory (float)",
    },
    {
      "<leader>O",
      function()
        pin_cwd_to_root()
        vim.cmd.Oil()
      end,
      desc = "Open parent directory",
    },
  },
}
