return {
  {
    "coder/claudecode.nvim",
    branch = "main",
    event = "VeryLazy",
    enabled = vim.g.ai_partner == "claudecode",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      require("claudecode").setup({
        port_range = { min = 60000, max = 65535 },
        auto_start = true,
        log_level = "info", -- "trace", "debug", "info", "warn", "error"
        terminal_cmd = "claude",

        -- Selection Tracking
        track_selection = true,
        visual_demotion_delay_ms = 50,

        -- Terminal Configuration
        terminal = {
          split_side = "right", -- "left" or "right"
          split_width_percentage = 0.40,
          provider = {
            setup = function(config) end,

            open = function(cmd, env, config)
              -- Check if there's already a pane to the right (same logic as simple_toggle)
              local pane_count = vim.fn.system("tmux list-panes | wc -l"):gsub("%s+", "")
              if tonumber(pane_count) <= 1 then
                local tmux_cmd = string.format(
                  "tmux split-window -h -p %d -c '%s' '%s'",
                  math.floor(config.split_width_percentage * 100),
                  vim.fn.getcwd(),
                  cmd
                )
                vim.fn.system(tmux_cmd)
              end
            end,

            close = function()
              -- Close the rightmost tmux pane
              vim.fn.system("tmux kill-pane -t '{right-of}'")
            end,

            simple_toggle = function(cmd, env, config)
              -- Check if there's already a pane to the right
              local pane_count = vim.fn.system("tmux list-panes | wc -l"):gsub("%s+", "")
              if tonumber(pane_count) > 1 then
                vim.fn.system("tmux kill-pane -t '{right-of}'")
              else
                local tmux_cmd = string.format(
                  "tmux split-window -h -p %d -c '%s' '%s'",
                  math.floor(config.split_width_percentage * 100),
                  vim.fn.getcwd(),
                  cmd
                )
                vim.fn.system(tmux_cmd)
              end
            end,

            focus_toggle = function()
              -- Focus the rightmost pane or return to the left one
              vim.fn.system("tmux select-pane -t '{right-of}' || tmux select-pane -t '{left-of}'")
            end,

            get_active_bufnr = function()
              return nil -- tmux doesn't use vim buffers
            end,

            is_available = function()
              -- Check if tmux is running
              return vim.fn.system("tmux list-sessions 2>/dev/null"):find("^") ~= nil
            end,
          },
          auto_close = true,
          snacks_win_opts = {},

          -- Provider-specific options
          provider_opts = {
            external_terminal_cmd = nil,
          },
        },
      })

      local function disable_diff()
        package.loaded["claudecode.diff"] = {
          setup = function() end,
          open_diff = function() end,
          open_diff_blocking = function() end,
          accept_current_diff = function() end,
          deny_current_diff = function() end,
        }
      end
      disable_diff()
    end,
    keys = {
      { "<leader>aa", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        function()
          vim.cmd("normal! V")
          vim.cmd("ClaudeCodeSend")
        end,
        mode = "n",
        desc = "Send current line",
      },
      { "<leader>af", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      {
        "<leader>af",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
      },
    },
  },
}
