return {
  "mattn/emmet-vim",
  init = function()
    -- let g:user_emmet_mode='i'
    vim.api.nvim_command('autocmd FileType html,css,less,sass,eruby,erb,javascript,jsx,vue EmmetInstall')
    vim.g.user_emmet_mode='i'
    vim.g.user_emmet_leader_key='<c-e>'
    vim.g.user_emmet_expandabbr_key='<c-e><c-e>'
    vim.g.user_emmet_expandword_key = '<C-e>v'
    vim.g.user_emmet_update_tag = '<C-e>u'
    vim.g.user_emmet_next_key='<C-e>n'
    vim.g.user_emmet_prev_key='<C-e>p'
    vim.g.user_emmet_settings = {
      html = {
        quote_char = "'",
      },
      javascript = {
        extends = 'jsx',
      }
    }
  end,
}
