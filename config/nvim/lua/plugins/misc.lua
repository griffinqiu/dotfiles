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
      colors = { "#e67e80", "#dbbc7f", "#a7c080", "#7fbbb3", "#d699b6", "#83c092", "#e69875" },
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
