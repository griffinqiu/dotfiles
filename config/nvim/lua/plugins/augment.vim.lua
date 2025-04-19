return {
  {
    "augmentcode/augment.vim",
    enabled = vim.g.ai_partner == "augment",
    keys = {
      { "<leader>ac", ":Augment chat<CR>", mode = "n" },
      { "<leader>ac", ":Augment chat<CR>", mode = "v" },
      { "<leader>an", ":Augment chat-new<CR>", mode = "n" },
      { "<leader>at", ":Augment chat-toggle<CR>", mode = "n" },
    },
  },
}
