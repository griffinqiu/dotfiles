return function(use)
  use 'skywind3000/vim-quickui'
  use 'xfyuan/vim-mac-dictionary'
  vim.g.vim_mac_dictionary_use_format = 1
  nmap('<leader>ww', ':MacDictPopup<CR>')
  nmap('<leader>wd', ':MacDictWord<CR>')
  nmap('<leader>wq', ':MacDictQuery<CR>')

  use 'editorconfig/editorconfig-vim'
  use 'christoomey/vim-sort-motion'
  use 'AndrewRadev/splitjoin.vim'
  use 'diepm/vim-rest-console'
  vim.b.vrc_header_content_type = 'application/json; charset=utf-8'

  use 'rizzatti/dash.vim'
  nmap('<leader>d', '<Plug>DashSearch')

  use 'vim-scripts/matchit.zip'
  use 'godlygeek/tabular'
  vmap('<leader>tz', ':Tabularize /=')
  use 'liangfeng/vimcdoc'
end
