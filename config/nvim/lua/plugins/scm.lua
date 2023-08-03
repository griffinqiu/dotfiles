return {
  {
    'mhinz/vim-signify',
    config = function()
      vim.g.signify_vcs_list = { 'git' }
    end,
    keys = {
      { "ic", "<plug>(signify-motion-inner-pending)", mode="o" },
      { "ic", "<plug>(signify-motion-inner-visual)", mode="x" },
      { "ac", "<plug>(signify-motion-outer-pending)", mode="o" },
      { "ac", "<plug>(signify-motion-outer-visual)", mode="x" },
      { "]g", "<plug>(signify-next-hunk)", mode="n" },
      { "[g", "<plug>(signify-prev-hunk)", mode="n" },
      { "]G", "9999]g", mode="n" },
      { "[G", "9999[g", mode="n" },
      { "<leader>gt", ":SignifyToggle<CR>", mode="n" },
      { "<leader>gh", ":SignifyToggleHighlight<CR>", mode="n" },
      { "<leader>gr", ":SignifyRefresh<CR>", mode="n" },
    },
  },

  {
    'tpope/vim-fugitive',
    keys = {
      { "<leader> gb", ":Git blame<br>" }
    },
  },
  { 'tpope/vim-rhubarb' }, -- :Gbrowse
}
