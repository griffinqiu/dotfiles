return {
  {
    "L3MON4D3/LuaSnip",
    keys = {
      {
        "<C-l>",
        function()
          if require("luasnip").expand_or_jumpable() then
            require("luasnip").expand_or_jump()
          end
        end,
        desc = "Expand or jump to next snippet",
        mode = { "i", "s" },
      },
      {
        "<C-h>",
        function()
          return require("luasnip").jump(-1)
        end,
        desc = "Jump to previous snippet",
        mode = { "i", "s" },
      },
    },
  },
}
