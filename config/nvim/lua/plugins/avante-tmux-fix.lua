return {
  {
    "yetone/avante.nvim",
    enabled = vim.g.ai_partner == "avante",
    opts = function(_, opts)
      if not vim.env.TMUX then
        return opts
      end

      local in_resize = false
      local original_cursor_win = nil
      local avante_filetypes = { "Avante", "AvanteInput", "AvanteAsk", "AvanteSelectedFiles" }

      local function is_in_avante_window()
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, "filetype")

        for _, avante_ft in ipairs(avante_filetypes) do
          if ft == avante_ft then
            return true, win, ft
          end
        end
        return false
      end

      local function temporarily_leave_avante()
        local is_avante, avante_win, avante_ft = is_in_avante_window()
        if is_avante and not in_resize then
          in_resize = true
          original_cursor_win = avante_win

          local target_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")

            local is_avante_ft = false
            for _, aft in ipairs(avante_filetypes) do
              if ft == aft then
                is_avante_ft = true
                break
              end
            end

            if not is_avante_ft and vim.api.nvim_win_is_valid(win) then
              target_win = win
              break
            end
          end

          if target_win then
            vim.api.nvim_set_current_win(target_win)
            return true
          end
        end
        return false
      end

      local function restore_cursor_to_avante()
        if in_resize and original_cursor_win and vim.api.nvim_win_is_valid(original_cursor_win) then
          vim.defer_fn(function()
            pcall(vim.api.nvim_set_current_win, original_cursor_win)
            in_resize = false
            original_cursor_win = nil
          end, 50)
        end
      end

      local avante_setup_done = false
      local function patch_avante_resize()
        if avante_setup_done then
          return
        end

        local ok, avante = pcall(require, "avante")
        if ok and avante then
          local sidebar_ok, sidebar = pcall(require, "avante.sidebar")
          if sidebar_ok and sidebar.Sidebar then
            local original_resize = sidebar.Sidebar.resize
            if original_resize then
              sidebar.Sidebar.resize = function(self, ...)
                if in_resize then
                  return
                end
                return original_resize(self, ...)
              end
              avante_setup_done = true
            end
          end
        end
      end

      vim.api.nvim_create_augroup("AvanteTmuxFix", { clear = true })

      vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = "AvanteTmuxFix",
        callback = function()
          patch_avante_resize()

          local moved = temporarily_leave_avante()

          if moved then
            vim.defer_fn(function()
              restore_cursor_to_avante()
              vim.cmd("redraw!")
            end, 100)
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized" }, {
        group = "AvanteTmuxFix",
        pattern = "*",
        callback = function(args)
          local buf = args.buf
          if buf and vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")

            for _, avante_ft in ipairs(avante_filetypes) do
              if ft == avante_ft then
                if in_resize then
                  return true
                end
                break
              end
            end
          end
        end,
      })

      local function cleanup_duplicate_avante_windows()
        local seen_filetypes = {}
        local windows_to_close = {}

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")

          if ft == "AvanteSelectedFiles" then
            if seen_filetypes[ft] then
              table.insert(windows_to_close, win)
            else
              seen_filetypes[ft] = win
            end
          end
        end

        for _, win in ipairs(windows_to_close) do
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      vim.api.nvim_create_autocmd("FocusGained", {
        group = "AvanteTmuxFix",
        callback = function()
          in_resize = false
          original_cursor_win = nil
          vim.defer_fn(cleanup_duplicate_avante_windows, 100)
        end,
      })

      vim.api.nvim_create_autocmd("VimResized", {
        group = "AvanteTmuxFix",
        callback = function()
          vim.defer_fn(cleanup_duplicate_avante_windows, 200)
        end,
      })

      if opts.behaviour then
        local original_auto_set_highlight = opts.behaviour.auto_set_highlight_group
        local original_auto_set_keymaps = opts.behaviour.auto_set_keymaps

        vim.api.nvim_create_autocmd("BufEnter", {
          group = "AvanteTmuxFix",
          callback = function()
            if in_resize then
              if opts.behaviour then
                opts.behaviour.auto_set_highlight_group = false
                opts.behaviour.auto_set_keymaps = false
              end
            else
              if opts.behaviour then
                opts.behaviour.auto_set_highlight_group = original_auto_set_highlight
                opts.behaviour.auto_set_keymaps = original_auto_set_keymaps
              end
            end
          end,
        })
      end

      return opts
    end,
  },
}
