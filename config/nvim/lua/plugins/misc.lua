return {
  -- MixedCase (crm)
  -- camelCase (crc)
  -- snake_case (crs) or (cr_)
  -- UPPER_CASE (cru)
  -- dash-case (cr-)
  -- dot.case (cr.)
  -- space case (cr<space>)
  -- Title Case (crt)
  { "tpope/vim-abolish" },
  {
    "Mr-LLLLL/interestingwords.nvim",
    opts = {
      colors = { "#e46876", "#e6c384", "#87a987", "#7fb4ca", "#938aa9", "#7aa89f", "#c8c093" },
      search_count = true,
      navigation = true,
      scroll_center = true,
      search_key = "#",
      cancel_search_key = "<leader>M",
      color_key = "<leader>#",
      cancel_color_key = "<leader><esc>",
      select_mode = "random",
    },
  },
}
