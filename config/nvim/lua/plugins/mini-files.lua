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
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(vim.api.nvim_buf_get_name(0), true)
        end
      end,
      desc = "Toggle mini.files (current file directory)",
    },
    {
      "<leader>M",
      function()
        local mf = require("mini.files")
        if not mf.close() then
          mf.open(vim.uv.cwd(), true)
        end
      end,
      desc = "Toggle mini.files (cwd)",
    },
  },
}
