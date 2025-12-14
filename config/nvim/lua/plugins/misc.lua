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
      colors = { "#ff899d", "#9fe044", "#faba4a", "#8db0ff", "#c7a9ff", "#a4daff", "#c0caf5" },
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
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
}
