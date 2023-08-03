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
    { "<C-G>g", "<Plug>CtrlSFPrompt", mode="n" },
    { "<C-G><C-G>", "<Plug>CtrlSFCwordExec", mode="n" },
    { "<C-G>g", "<Plug>CtrlSFVwordPath", mode="v" },
    { "<C-G><C-G>", "<Plug>CtrlSFVwordExec", mode="v" },
    { "<C-G>p", "<Plug>CtrlSFPwordPath", mode="n" },
    { "<C-G><C-P>", "<Plug>CtrlSFPwordExec", mode="n" },
    { "<C-G><C-O>", ":CtrlSFOpen<CR>", mode="n" },
    { "<C-G>l", "<Plug>CtrlSFQuickfixPrompt", mode="n" },
    { "<C-G>l", "<Plug>CtrlSFQuilkfixVwordPath", mode="v" },
    { "<C-G>L", "<Plug>CtrSFQuickfixVwordPath", mode="v" },
    { "<C-G><C-L>", "<Plug>CtrlSFQuickfixVwordExec", mode="v" },
    { "<leader>3", ":CtrlSFToggle<CR>", mode="n" },
    { "\\", ":CtrlSF<SPACE>", mode="n" },
  },
}
