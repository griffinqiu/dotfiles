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
            local ft = vim.bo[buf].filetype

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

      local function reset_avante_windows()
        local wins = vim.api.nvim_list_wins()
        local ask_win = nil
        local sidebar_win = nil
        local selected_files_win = nil
        local original_win = vim.api.nvim_get_current_win()

        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          local filetype = vim.bo[buf].filetype

          if filetype == "AvanteInput" or buf_name:match("Avante.*Input") then
            ask_win = win
          elseif filetype == "Avante" or buf_name:match("Avante") then
            sidebar_win = win
          elseif filetype == "AvanteSelectedFiles" or buf_name:match("Avante.*SelectedFiles") then
            selected_files_win = win
          end
        end

        local total_height = vim.o.lines - vim.o.cmdheight - 1

        if ask_win then
          vim.api.nvim_win_set_height(ask_win, 10)

          -- Ensure the height sticks by setting it again after a short delay
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(ask_win) then
              vim.api.nvim_win_set_height(ask_win, 10)
            end
          end, 50)
        end

        if sidebar_win then
          local available_height = total_height - 16 -- Reserve space for Ask panel (11) + some padding
          if available_height > 20 then
            vim.api.nvim_win_set_height(sidebar_win, available_height)

            -- Move cursor to bottom without switching windows
            local buf = vim.api.nvim_win_get_buf(sidebar_win)
            local line_count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(sidebar_win, { line_count, 0 })
          end
        end

        if selected_files_win then
          local buf = vim.api.nvim_win_get_buf(selected_files_win)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local file_count = 0

          -- Count non-empty lines as file count
          for _, line in ipairs(lines) do
            if line:match("%S") then -- Line contains non-whitespace characters
              file_count = file_count + 1
            end
          end

          -- Set height based on file count: minimum 2, maximum 10
          local height = math.max(2, math.min(10, file_count))
          vim.api.nvim_win_set_height(selected_files_win, height)
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

      vim.api.nvim_create_user_command("AvanteResetWindows", function()
        vim.g.avante_manual_reset = true
        reset_avante_windows()
      end, {
        desc = "Reset Avante window heights and move cursor to bottom",
      })

      vim.keymap.set("n", "<leader>aw", function()
        vim.cmd("AvanteResetWindows")
      end, { desc = "Reset Avante windows height" })

      vim.api.nvim_create_autocmd("VimResized", {
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
            local ft = vim.bo[buf].filetype

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
          local ft = vim.bo[buf].filetype

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
          -- Only auto-reset if not manually triggered
          if vim.g.avante_manual_reset then
            vim.g.avante_manual_reset = false
            return
          end

          vim.defer_fn(function()
            local wins = vim.api.nvim_list_wins()
            local has_avante = false
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              local filetype = vim.bo[buf].filetype
              if filetype == "Avante" or filetype == "AvanteInput" then
                has_avante = true
                break
              end
            end

            if has_avante then
              reset_avante_windows()
            end
            cleanup_duplicate_avante_windows()
          end, 200)
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
