return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = function(picker)
            require("telescope.actions").move_selection_next(picker)
          end,
          ["<C-k>"] = function(picker)
            require("telescope.actions").move_selection_previous(picker)
          end,
        },
      },
    },
  },
}
