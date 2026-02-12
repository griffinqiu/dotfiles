return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.component_separators = { left = "|", right = "|" }
      opts.options.section_separators = { left = "", right = "" }

      -- Disable lualine for avante windows (except AvanteInput/ask panel)
      opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
      opts.options.disabled_filetypes.statusline = opts.options.disabled_filetypes.statusline or {}
      table.insert(opts.options.disabled_filetypes.statusline, "Avante")
      table.insert(opts.options.disabled_filetypes.statusline, "AvanteSelectedFiles")

      opts.sections = opts.sections or {}
      opts.sections.lualine_a = {}

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
