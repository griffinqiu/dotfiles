return {
  'xfyuan/vim-mac-dictionary',
  config = function()
    vim.g.vim_mac_dictionary_use_format = 1
  end,
  keys = {
    { "<leader>ww", ":MacDictPopup<CR>", mode="n" },
    { "<leader>wd", ":MacDictWord<CR>", mode="n" },
    { "<leader>wq", ":MacDictQuery<CR>", mode="n" },
  },
}
