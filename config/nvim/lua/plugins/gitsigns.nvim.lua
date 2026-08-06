return {
  -- Swap LazyVim defaults: <leader>gb blames the buffer (see config/keymaps.lua),
  -- <leader>ghB picks the git log of the current line.
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local lazyvim_on_attach = opts.on_attach

    opts.on_attach = function(buffer)
      if lazyvim_on_attach then
        lazyvim_on_attach(buffer)
      end
      vim.keymap.set("n", "<leader>ghB", function()
        Snacks.picker.git_log_line()
      end, { buffer = buffer, desc = "Git Blame Line" })
    end
  end,
}
