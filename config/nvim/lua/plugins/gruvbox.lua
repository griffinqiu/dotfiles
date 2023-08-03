return {
  'morhetz/gruvbox',
  init = function()
    vim.g.gruvbox_invert_selection=0
    vim.g.gruvbox_contrast_dark='soft'
    vim.g.gruvbox_contrast_light='soft'
    vim.cmd[[colorscheme gruvbox]]
  end
}
