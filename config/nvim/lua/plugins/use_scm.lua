return function(use)
  use 'mhinz/vim-signify'
  vim.g.signify_vcs_list = { 'git' }
  omap("ic", "<plug>(signify-motion-inner-pending)", "buffer")
  xmap("ic", "<plug>(signify-motion-inner-visual)", "buffer")
  omap("ac", "<plug>(signify-motion-outer-pending)", "buffer")
  xmap("ac", "<plug>(signify-motion-outer-visual)", "buffer")
  nmap(']g', '<plug>(signify-next-hunk)', "buffer")
  nmap('[g', '<plug>(signify-prev-hunk)', "buffer")
  nmap(']G', '9999]g')
  nmap('[G', '9999[g')
  nnoremap('<leader>gt', ':SignifyToggle<CR>')
  nnoremap('<leader>gh', ':SignifyToggleHighlight<CR>')
  nnoremap('<leader>gr', ':SignifyRefresh<CR>')

  use 'tpope/vim-fugitive'
  nmap("<Leader>gb", ":Git blame<CR>", "silent")
  use 'tpope/vim-rhubarb' -- :Gbrowse
end
