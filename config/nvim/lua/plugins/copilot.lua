return {
  'github/copilot.vim',
  init = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_filetypes = {
      ["TelescopePrompt"] = false,
      ["DressingInput"] = false,
    }
  end,
  config = function()
    vim.cmd([[imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")]])
  end,
}
