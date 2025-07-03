-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Fix tmux compatibility issues by disabling problematic LazyVim autocmds
if vim.env.TMUX then
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimKeymaps",
    callback = function()
      -- Disable LazyVim's resize_splits autocmd that causes "Not enough room" errors
      pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_resize_splits")

      -- Disable LazyVim's auto_create_dir autocmd that can conflict with tmux
      pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_auto_create_dir")

      -- Create a safer resize handler for tmux
      vim.api.nvim_create_augroup("tmux_safe_resize", { clear = true })
      vim.api.nvim_create_autocmd("VimResized", {
        group = "tmux_safe_resize",
        callback = function()
          -- Only attempt resize if we're not in a plugin window
          local current_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          if current_ft == "Avante" or current_ft == "AvanteInput" then
            return
          end

          -- Safe resize that won't fail
          local ok, _ = pcall(vim.cmd, "wincmd =")
          if not ok then
            -- If resize fails, just return silently
            return
          end
        end,
      })
    end,
  })
end

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "Dockerfile.builder",
  command = "set filetype=dockerfile",
})

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
