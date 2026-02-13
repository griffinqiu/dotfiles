return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["/"] = false,
        },
      },
      filesystem = {
        window = {
          -- 修复 filter 输入框中按回车无反应的问题
          -- 添加 <CR> 映射,让其行为与 <S-CR> 一致(关闭并保持过滤)
          fuzzy_finder_mappings = {
            ["<CR>"] = "close_keep_filter",
          },
        },
      },
    },
  },
}
