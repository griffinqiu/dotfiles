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
  -- Lua-native themes
  { "ellisonleao/gruvbox.nvim" },
  { "maxmx03/solarized.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "neanias/everforest-nvim" },
  { "EdenEast/nightfox.nvim" },
  { "rose-pine/neovim" },

  -- Vimscript themes
  { "joshdick/onedark.vim" },
  { "NLKNguyen/papercolor-theme" },

  -- If a theme links DiagnosticError to a group with undercurl (e.g. sainnhe's themes),
  -- undercurl bleeds into Snacks notifier/picker. Fix with on_highlights (Lua themes)
  -- or config callback (Vimscript themes) to redefine as fg-only:
  --
  -- Lua theme example:
  -- { "neanias/everforest-nvim",
  --   opts = { on_highlights = function(hl, palette)
  --     hl.DiagnosticError = { fg = palette.red }
  --     hl.DiagnosticWarn  = { fg = palette.yellow }
  --     hl.DiagnosticInfo  = { fg = palette.blue }
  --     hl.DiagnosticHint  = { fg = palette.green }
  --   end },
  -- },
  --
  -- Vimscript theme example (use config callback):
  -- { "sainnhe/everforest",
  --   config = function() vim.cmd("colorscheme everforest")
  --     for _, name in ipairs({ "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }) do
  --       local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  --       if hl.undercurl or hl.underline then
  --         vim.api.nvim_set_hl(0, name, { fg = hl.fg or hl.sp })
  --       end
  --     end
  --   end,
  -- },

  -- Configure LazyVim to load colorscheme
  -- Available colorschemes (use as value for colorscheme = "..."):
  --   tokyonight, tokyonight-moon*, tokyonight-night, tokyonight-storm, tokyonight-day  (built-in)
  --   catppuccin, catppuccin-mocha*, catppuccin-frappe, catppuccin-macchiato, catppuccin-latte  (built-in)
  --   gruvbox
  --   solarized
  --   kanagawa, kanagawa-wave*, kanagawa-dragon, kanagawa-lotus
  --   everforest
  --   nightfox, duskfox, nordfox, terafox, carbonfox, dawnfox, dayfox
  --   rose-pine, rose-pine-main*, rose-pine-moon, rose-pine-dawn
  --   onedark
  --   PaperColor
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-dragon",
    },
  },
}
