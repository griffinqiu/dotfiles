-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

map("n", ",", "<Nop>", { silent = true })
map("c", "<c-a>", "<home>", { desc = "Move to start of the line" })
map("c", "<c-e>", "<end>", { desc = "Move to end of the line" })
map("c", "<c-b>", "<left>", { desc = "Move cursor left" })
map("c", "<c-f>", "<right>", { desc = "Move cursor right" })
map("c", "<c-d>", "<delete>", { desc = "Delete character under the cursor" })
map("c", "<c-h>", "<bs>", { desc = "Delete character before the cursor" })
map("n", ",cn", ":let @*=expand('%'). ':' . line('.')<CR>", { desc = "Copy relative file path with line number" })
map("n", ",cs", ':let @*=expand("%")<CR>', { desc = "Copy relative file path" })
map("n", ",cf", ':let @*=expand("%:t")<CR>', { desc = "Copy filename" })
map("n", ",cl", ':let @*=expand("%:p")<CR>', { desc = "Copy full file path" })
map("n", "<C-s>", ":update!<CR>", { silent = true, desc = "Save file" })
map("v", "<C-s>", "<C-c>:update!<CR>", { silent = true, desc = "Save file" })
map("i", "<C-s>", "<C-o>:update!<CR>", { silent = true, desc = "Save file" })
map("n", "#", "#g``", { desc = "Previous search result, center and keep cursor position" })
map("n", "*", "*g``", { desc = "Next search result, center and keep cursor position" })

-- Disable LazyVim terminal keymaps
map("n", "<leader>fT", "<nop>", { desc = "which_key_ignore" })
map("n", "<leader>ft", "<nop>", { desc = "which_key_ignore" })

if vim.fn.executable("lazygit") == 1 then
  vim.keymap.del("n", "<leader>gg")
end
