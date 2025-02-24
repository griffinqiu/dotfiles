return {
  {
    'mhinz/vim-signify',
    init = function()
      vim.g.signify_vcs_list = { 'git' }
    end,
    lazy = false,
    keys = {
      { "ic", "<plug>(signify-motion-inner-pending)", mode="o" },
      { "ic", "<plug>(signify-motion-inner-visual)", mode="x" },
      { "ac", "<plug>(signify-motion-outer-pending)", mode="o" },
      { "ac", "<plug>(signify-motion-outer-visual)", mode="x" },
      { "]g", "<plug>(signify-next-hunk)", mode="n" },
      { "[g", "<plug>(signify-prev-hunk)", mode="n" },
      { "]G", "9999]g", mode="n" },
      { "[G", "9999[g", mode="n" },
      { "<leader>gt", "<cmd>SignifyToggle<CR>", mode="n" },
      { "<leader>gh", "<cmd>SignifyToggleHighlight<CR>", mode="n" },
      { "<leader>gr", "<cmd>SignifyRefresh<CR>", mode="n" },
    },
  },

  {
    'tpope/vim-fugitive',
    keys = {
      { "<leader>gb", '<cmd>Git blame<cr>', mode="n" }
    },
  },
  { 'tpope/vim-rhubarb' }, -- :Gbrowse
}
