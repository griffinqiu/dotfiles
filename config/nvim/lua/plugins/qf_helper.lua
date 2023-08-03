return {
  "stevearc/qf_helper.nvim",
  config = function()
    require'qf_helper'.setup({
      prefer_loclist = false,      -- Used for QNext/QPrev (see Commands below)
      sort_lsp_diagnostics = true, -- Sort LSP diagnostic results
      quickfix = {
        autoclose = true,          -- Autoclose qf if it's the only open window
        default_bindings = true,   -- Set up recommended bindings in qf window
        default_options = true,    -- Set recommended buffer and window options
        max_height = 10,           -- Max qf height when using open() or toggle()
        min_height = 1,            -- Min qf height when using open() or toggle()
        track_location = 'cursor', -- Keep qf updated with your current location
                                   -- Use `true` to update position as well
      },
      loclist = {                  -- The same options, but for the loclist
        autoclose = true,
        default_bindings = true,
        default_options = true,
        max_height = 10,
        min_height = 1,
        track_location = 'cursor',
      },
    })
  end,
  keys = {
    { "]q", "<cmd>QNext<CR>", mode="n" },
    { "[q", "<cmd>QPrev<CR>", mode="n" },
    { "<leader>q", "<cmd>QFToggle!<CR>", mode="n" },
    { "<leader>l", "<cmd>LLToggle!<CR>", mode="n" },
  },
}
