--- Check if it's weekend
---@return boolean
local function is_weekend()
  local day = tonumber(os.date("%w"))
  return day == 0 or day == 6
end

--- Check if it's day time
---@return boolean
local function is_day_time()
  local hour = tonumber(os.date("%H"))
  return hour >= 9 and hour < 19
end
local is_transparent = is_day_time() and not is_weekend()

return {
  {
    'morhetz/gruvbox',
    config = function(_, opts)
      vim.g.gruvbox_invert_selection=0
      vim.g.gruvbox_contrast_dark='soft'
      vim.g.gruvbox_contrast_light='soft'
      vim.cmd[[colorscheme gruvbox]]
    end,
  },
  -- {
    -- "rebelot/kanagawa.nvim",
    -- lazy = true,
    -- opts = {
      -- dimInactive = true, -- dim inactive window `:h hl-NormalNC`
      -- -- Remove gutter background
      -- colors = {
        -- theme = {
          -- all = {
            -- ui = {
              -- bg_gutter = "none",
            -- },
          -- },
        -- },
      -- },
      -- overrides = function(colors)
        -- local theme = colors.theme
        -- return {
          -- -- Transparent background
          -- NormalFloat = { bg = "none" },
          -- FloatBorder = { bg = "none" },
          -- FloatTitle = { bg = "none" },

          -- NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
          -- LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          -- MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

          -- -- Snacks.nvim dashboard
          -- SnacksDashboardDesc = { fg = theme.syn.identifier },
          -- SnacksDashboardFooter = { fg = theme.syn.comment },
          -- SnacksDashboardHeader = { fg = theme.vcs.removed },
          -- SnacksDashboardIcon = { fg = theme.ui.special },
          -- SnacksDashboardKey = { fg = theme.syn.special1 },
          -- SnacksDashboardSpecial = { fg = theme.syn.special1 },
          -- SnacksDashboardDir = { link = "Directory" },

          -- -- TODO: support Snacks.nvim picker
          -- SnacksPickerInputBorder = { fg = theme.ui.fg_dim },
          -- SnacksPickerInputTitle = { fg = theme.ui.bg_m3 },
          -- SnacksPickerBoxTitle = { fg = theme.ui.fg_dim },
          -- SnacksPickerSelected = { fg = theme.ui.special },
          -- SnacksPickerMatch = { fg = theme.syn.special1 },
        -- }
      -- end,
    -- },
  -- },
  -- {
    -- "EdenEast/nightfox.nvim",
    -- opts = {
      -- options = {
        -- transparent = is_transparent,
        -- styles = {
          -- comments = "italic",
          -- keywords = "bold",
          -- types = "italic,bold",
        -- },
      -- },
    -- },
    -- lazy = true,
  -- },
  -- {
    -- "rose-pine/neovim",
    -- name = "rose-pine",
    -- opts = {
      -- variant = "moon",
      -- disable_background = is_transparent,
      -- disable_float_background = is_transparent,
      -- styles = {
        -- bold = true,
        -- italic = true,
        -- transparency = is_transparent,
      -- },
    -- },
    -- lazy = true,
  -- },
  -- {
    -- "catppuccin/nvim",
    -- lazy = true,
    -- name = "catppuccin",
    -- opts = {
      -- transparent_background = is_transparent,
      -- integrations = {
        -- cmp = true,
        -- dashboard = true,
        -- flash = true,
        -- gitsigns = true,
        -- headlines = true,
        -- indent_blankline = { enabled = true },
        -- lsp_trouble = true,
        -- mason = true,
        -- markdown = true,
        -- mini = true,
        -- native_lsp = {
          -- enabled = true,
          -- underlines = {
            -- errors = { "undercurl" },
            -- hints = { "undercurl" },
            -- warnings = { "undercurl" },
            -- information = { "undercurl" },
          -- },
        -- },
        -- neotest = true,
        -- noice = true,
        -- notify = true,
        -- semantic_tokens = true,
        -- treesitter = true,
        -- treesitter_context = true,
        -- which_key = true,
        -- fzf = true,
      -- },
    -- },
  -- },
  -- {
    -- "Mofiqul/dracula.nvim",
    -- lazy = true,
    -- opts = {
      -- transparent_bg = is_transparent,
      -- show_end_of_buffer = true,
      -- -- set italic comment
      -- italic_comment = true,
    -- },
    -- config = function(_, opts)
      -- local dracula = require("dracula")
      -- dracula.setup(opts)
      -- -- Disable spell check as it's too red
      -- vim.o.spell = false
    -- end,
  -- },
  -- {
    -- "lalitmee/cobalt2.nvim",
    -- lazy = true,
    -- dependencies = { "tjdevries/colorbuddy.nvim", tag = "v1.0.0" },
    -- init = function()
      -- require("colorbuddy").colorscheme("cobalt2")
      -- -- Disable spell check as it's too red
      -- vim.o.spell = false
    -- end,
  -- },
  -- {
    -- "oxfist/night-owl.nvim",
    -- lazy = true,
    -- opts = {
      -- bold = true,
      -- italics = true,
      -- underline = true,
      -- undercurl = true,
      -- transparent_background = is_transparent,
    -- },
  -- },
  -- {
    -- "folke/tokyonight.nvim",
    -- lazy = true,
    -- opts = {
      -- style = "moon",
      -- transparent = is_transparent,
      -- styles = is_transparent and {
        -- sidebars = "transparent",
        -- floats = "transparent",
      -- } or {},
    -- },
  -- },
}
