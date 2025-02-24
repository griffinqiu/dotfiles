return {
  'dyng/ctrlsf.vim',
  init = function()
    vim.g.ctrlsf_auto_close = 0
    vim.g.ctrlsf_open_left = 0
    vim.g.ctrlsf_position = 'right'
    vim.g.ctrlsf_winsize = '30%'
    vim.g.ctrlsf_ignore_dir = { 'node_modules', 'build', 'tmp', 'proto' }
    vim.g.ctrlsf_position = 'right'
    vim.g.ctrlsf_mapping = {
      next = "<c-n>",
      prev = "<c-p>",
    }
  end,

  keys = {
    { "\\", "<Plug>CtrlSFPrompt", mode="n", desc = "CtrlSF Prompt" },
    { "<leader>3", ":CtrlSFToggle<CR>", mode="n", desc = "CtrlSF Toggle" },
    { "<c-g><c-g>", "<Plug>CtrlSFCwordExec", mode="n", desc = "CtrlSF Current Word Exec" },
    { "<c-g><c-g>", "<Plug>CtrlSFVwordExec", mode="v", desc = "CtrlSF Selected Exec" },
    { "<c-g>g", "<Plug>CtrlSFPrompt", mode="n", desc = "CtrlSF Prompt" },
    { "<c-g>g", "<Plug>CtrlSFVwordPath", mode="v", desc = "CtrlSF Selected and waiting" },
    { "<c-g>v", ":CtrlSFToggle<CR>", mode="n", desc = "CtrlSF Toggle" },
    { "<c-g>l", "<Plug>CtrlSFQuickfixPrompt", mode="n", desc = "CtrlSF QuickfixPrompt" },
  },
}
