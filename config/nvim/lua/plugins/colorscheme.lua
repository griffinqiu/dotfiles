return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.component_separators = { left = "|", right = "|" }
      opts.options.section_separators = { left = "", right = "" }

      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, { require("mcphub.extensions.lualine") })
      return opts
    end,
  },
  { "ellisonleao/gruvbox.nvim" },
  { "folke/tokyonight.nvim" }, -- super good
  { "maxmx03/solarized.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "joshdick/onedark.vim" },
  { "NLKNguyen/papercolor-theme" },
  { "sainnhe/everforest" }, -- good
  { "EdenEast/nightfox.nvim" },
  { "rose-pine/neovim" }, -- good

  -- Configure LazyVim to load colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
