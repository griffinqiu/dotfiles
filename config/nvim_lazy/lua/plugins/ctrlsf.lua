return {
  "dyng/ctrlsf.vim",
  init = function()
    vim.g.ctrlsf_auto_close = 0
    vim.g.ctrlsf_open_left = 0
    vim.g.ctrlsf_position = "right"
    vim.g.ctrlsf_winsize = "30%"
    vim.g.ctrlsf_ignore_dir = { "node_modules", "build", "tmp", "proto" }
    vim.g.ctrlsf_position = "right"
    vim.g.ctrlsf_mapping = {
      next = "<c-n>",
      prev = "<c-p>",
    }
  end,
  keys = {
    { "\\", "<Plug>CtrlSFPrompt", mode = "n", desc = "CtrlSF Prompt" },
    { "\\", "<Plug>CtrlSFVwordPath", mode = "v", desc = "CtrlSF Selected and waiting" },
    { "<leader>sf", ":CtrlSFToggle<CR>", mode = "n", desc = "CtrlSF Toggle" },
    { "<leader>sF", "<Plug>CtrlSFCwordExec", mode = "n", desc = "CtrlSF Current Word Exec" },
    { "<leader>sF", "<Plug>CtrlSFVwordExec", mode = "v", desc = "CtrlSF Selected Exec" },
  },
}
