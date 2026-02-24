local emacs_keys = {
  -- ["<c-a>"] = { "<home>", mode = "i", expr = true },
  -- ["<c-e>"] = { "<end>", mode = "i", expr = true },
  -- ["<c-b>"] = { "<left>", mode = "i", expr = true },
  -- ["<c-f>"] = { "<right>", mode = "i", expr = true },
  -- ["<c-d>"] = { "<delete>", mode = "i", expr = true },
  -- ["<c-h>"] = { "<bs>", mode = "i", expr = true },
}

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = emacs_keys,
        },
      },
    },
    input = {
      keys = emacs_keys,
    },
  },
}
