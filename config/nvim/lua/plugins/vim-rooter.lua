return {
  "airblade/vim-rooter",
  config = function()
    vim.g.rooter_patterns = {'.git'}
    vim.g.rooter_manual_only = 1
    -- automatically close the tab/vim when nvim-tree is the last window in the tab
    vim.cmd([[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]])
  end,
}
