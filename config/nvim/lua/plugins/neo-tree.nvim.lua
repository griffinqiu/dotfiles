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
      -- Keys mirror oil: g-prefixed actions, <C-s>/<C-v>/<C-t> splits. The
      -- single-letter originals are dropped so a key means one thing everywhere.
      window = {
        mappings = {
          ["/"] = false,
          ["?"] = false,
          ["P"] = false,
          ["s"] = false,
          ["S"] = false,
          ["t"] = false,
          ["O"] = false,
          ["g?"] = "show_help",
          ["gr"] = "refresh",
          ["gx"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["<C-p>"] = { "toggle_preview", config = { use_float = false } },
          ["<C-s>"] = "open_split",
          ["<C-v>"] = "open_vsplit",
          ["<C-t>"] = "open_tabnew",
        },
      },
      filesystem = {
        window = {
          mappings = {
            ["H"] = false,
            ["g."] = "toggle_hidden",
            ["o"] = false,
            ["oc"] = false,
            ["od"] = false,
            ["og"] = false,
            ["om"] = false,
            ["on"] = false,
            ["os"] = false,
            ["ot"] = false,
            ["gs"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "gs" } },
            ["gsc"] = { "order_by_created", nowait = false },
            ["gsd"] = { "order_by_diagnostics", nowait = false },
            ["gsg"] = { "order_by_git_status", nowait = false },
            ["gsm"] = { "order_by_modified", nowait = false },
            ["gsn"] = { "order_by_name", nowait = false },
            ["gss"] = { "order_by_size", nowait = false },
            ["gst"] = { "order_by_type", nowait = false },
          },
          fuzzy_finder_mappings = {
            ["<CR>"] = "close_keep_filter",
          },
        },
      },
      -- Git actions belong to lazygit; the tree keeps only [g/]g navigation.
      git_status = {
        window = {
          mappings = {
            ["ga"] = false,
            ["gu"] = false,
            ["gU"] = false,
            ["gt"] = false,
            ["gc"] = false,
            ["gp"] = false,
            ["gg"] = false,
            ["gr"] = "refresh",
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
