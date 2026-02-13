local GRUG_FAR_INSTANCE = "far"

local function close_grug_far()
  local ok, grug_far = pcall(require, "grug-far")
  if ok and grug_far.is_instance_open(GRUG_FAR_INSTANCE) then
    grug_far.toggle_instance({ instanceName = GRUG_FAR_INSTANCE })
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["/"] = false,
        },
      },
      filesystem = {
        window = {
          fuzzy_finder_mappings = {
            ["<CR>"] = "close_keep_filter",
          },
        },
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          close_grug_far()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>E",
        function()
          close_grug_far()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
    },
  },
}
