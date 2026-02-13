return {
  "nvim-mini/mini.files",
  opts = {
    mappings = {
      go_in_plus = "<CR>",
    },
  },
  keys = {
    {
      "<leader>m",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (current file directory)",
    },
    {
      "<leader>M",
      function()
        require("mini.files").open(vim.loop.cwd(), true)
      end,
      desc = "Open mini.files (cwd)",
    },
  },
}
