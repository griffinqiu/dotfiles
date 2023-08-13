return {
  "mhinz/vim-startify",
  init = function()
    local g = vim.g

    g.startify_bookmarks = {
      vim.env.MYVIMRC,
      "~/.zshrc",
      "~/.todo.txt"
    }
    g.startify_relative_path = 1
    g.startify_change_to_vcs_root = 1
    g.startify_use_env = 1
    g.startify_session_persistence = 1
    g.startify_padding_left = 10
    g.startify_files_number = 5
    g.startify_custom_indices = { "a", "s", "d", "f", "j", "k", "l", "g", "h", "m", "v" }

    g.startify_lists = {
      {
        type = "files",
        header = { string.rep(" ", g.startify_padding_left) .. "ﲊ " },
      },
      {
        type = "sessions",
        header = { string.rep(" ", g.startify_padding_left) .. "  " },
      },
      {
        type = "bookmarks",
        header = { string.rep(" ", g.startify_padding_left) .. " " },
        indices = { "A", "S", "D" },
      },
    }

    g.custom_header = {
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀███╗   ██╗██╗   ██╗██╗███╗   ███╗ ⠀",
      "⠀⠀████╗  ██║██║   ██║██║████╗ ████║ ⠀",
      "⠀⠀██╔██╗ ██║██║   ██║██║██╔████╔██║  ",
      "⠀⠀██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
      "⠀⠀██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
      "⠀⠀╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀            ",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀           ",
    }
    g.startify_custom_header = "startify#center(g:custom_header)"
  end,
}
