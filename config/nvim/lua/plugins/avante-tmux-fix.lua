return {
  {
    "yetone/avante.nvim",
    enabled = vim.g.ai_partner == "avante",
    opts = function(_, opts)
      -- Only apply fix in tmux environment
      if not vim.env.TMUX then
        return opts
      end

      -- Track avante's internal state
      local in_resize = false
      local original_cursor_win = nil
      local avante_filetypes = { "Avante", "AvanteInput", "AvantePromptInput", "AvanteAsk", "AvanteSelectedFiles" }

      -- Check if current window is avante
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

      -- Temporarily move cursor away from avante during resize
      local function temporarily_leave_avante()
        local is_avante, avante_win, avante_ft = is_in_avante_window()
        if is_avante and not in_resize then
          in_resize = true
          original_cursor_win = avante_win

          -- Find a non-avante window to switch to
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

          -- Switch to non-avante window if found
          if target_win then
            vim.api.nvim_set_current_win(target_win)
            return true
          end
        end
        return false
      end

      -- Restore cursor to original avante window
      local function restore_cursor_to_avante()
        if in_resize and original_cursor_win and vim.api.nvim_win_is_valid(original_cursor_win) then
          -- Small delay to ensure resize is complete
          vim.defer_fn(function()
            pcall(vim.api.nvim_set_current_win, original_cursor_win)
            in_resize = false
            original_cursor_win = nil
          end, 50)
        end
      end

      -- Override avante's refresh/resize methods if possible
      local avante_setup_done = false
      local function patch_avante_resize()
        if avante_setup_done then
          return
        end

        -- Try to access avante's sidebar module
        local ok, avante = pcall(require, "avante")
        if ok and avante then
          local sidebar_ok, sidebar = pcall(require, "avante.sidebar")
          if sidebar_ok and sidebar.Sidebar then
            -- Wrap the resize method
            local original_resize = sidebar.Sidebar.resize
            if original_resize then
              sidebar.Sidebar.resize = function(self, ...)
                if in_resize then
                  -- Skip resize during our resize handling
                  return
                end
                return original_resize(self, ...)
              end
              avante_setup_done = true
            end
          end
        end
      end

      -- Create autocmd group
      vim.api.nvim_create_augroup("AvanteTmuxFix", { clear = true })

      -- Main resize handler
      vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = "AvanteTmuxFix",
        callback = function()
          -- Try to patch avante if not done yet
          patch_avante_resize()

          -- Move cursor away from avante before resize processing
          local moved = temporarily_leave_avante()

          if moved then
            -- Let resize happen, then restore cursor
            vim.defer_fn(function()
              restore_cursor_to_avante()
              -- Force a clean redraw
              vim.cmd("redraw!")
            end, 100)
          end
        end,
      })

      -- Alternative approach: prevent avante from responding to certain events
      vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized" }, {
        group = "AvanteTmuxFix",
        pattern = "*",
        callback = function(args)
          local buf = args.buf
          if buf and vim.api.nvim_buf_is_valid(buf) then
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")

            for _, avante_ft in ipairs(avante_filetypes) do
              if ft == avante_ft then
                -- Prevent event propagation for avante buffers during resize
                if in_resize then
                  return true -- This should stop the event
                end
                break
              end
            end
          end
        end,
      })

      -- Prevent duplicate Select Files panels
      local function cleanup_duplicate_avante_windows()
        local seen_filetypes = {}
        local windows_to_close = {}
        
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_buf_get_option(buf, "filetype")
          
          -- Special handling for Select Files panel
          if ft == "AvanteSelectedFiles" then
            if seen_filetypes[ft] then
              -- Found duplicate, mark for closing
              table.insert(windows_to_close, win)
            else
              seen_filetypes[ft] = win
            end
          end
        end
        
        -- Close duplicate windows
        for _, win in ipairs(windows_to_close) do
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end

      -- Handle focus events in tmux
      vim.api.nvim_create_autocmd("FocusGained", {
        group = "AvanteTmuxFix",
        callback = function()
          -- Reset resize state on focus gain
          in_resize = false
          original_cursor_win = nil
          -- Clean up any duplicate windows
          vim.defer_fn(cleanup_duplicate_avante_windows, 100)
        end,
      })
      
      -- Additional cleanup after resize
      vim.api.nvim_create_autocmd("VimResized", {
        group = "AvanteTmuxFix",
        callback = function()
          -- Cleanup duplicates after resize completes
          vim.defer_fn(cleanup_duplicate_avante_windows, 200)
        end,
      })

      -- Disable some avante auto-behaviors during resize
      if opts.behaviour then
        -- Store original values
        local original_auto_set_highlight = opts.behaviour.auto_set_highlight_group
        local original_auto_set_keymaps = opts.behaviour.auto_set_keymaps

        -- Create wrapper that checks resize state
        vim.api.nvim_create_autocmd("BufEnter", {
          group = "AvanteTmuxFix",
          callback = function()
            if in_resize then
              -- Temporarily disable during resize
              if opts.behaviour then
                opts.behaviour.auto_set_highlight_group = false
                opts.behaviour.auto_set_keymaps = false
              end
            else
              -- Restore original values
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

