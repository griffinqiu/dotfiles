-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "TelescopePrompt",
    "snacks_input",
    "snacks_picker_input",
    "neo-tree-popup",
    "AvantePromptInput",
    "AvanteInput",
  },
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "i", "<c-a>", "<home>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "i", "<c-e>", "<end>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "i", "<c-b>", "<left>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "i", "<c-f>", "<right>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "i", "<c-d>", "<delete>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "i", "<c-h>", "<bs>", { noremap = true, silent = true })
  end,
})
