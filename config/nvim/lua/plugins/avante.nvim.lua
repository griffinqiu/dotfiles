return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    enabled = vim.g.ai_partner == "avante",
    keys = {
      { "<leader>an", ":AvanteChatNew<CR>", mode = "n" },
      { "<leader>ac", ":AvanteClear<CR>", mode = "n" },
      {
        "<leader>ar",
        function()
          -- 重置avante窗口高度的函数
          local function reset_avante_windows()
            -- 获取所有窗口
            local wins = vim.api.nvim_list_wins()
            local ask_win = nil
            local sidebar_win = nil

            -- 查找avante相关窗口
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              local filetype = vim.bo[buf].filetype

              -- 检查是否是ask窗口 (通常是输入窗口)
              if filetype == "AvanteInput" or buf_name:match("Avante.*Input") then
                ask_win = win
              -- 检查是否是sidebar窗口 (回复窗口)
              elseif filetype == "Avante" or buf_name:match("Avante") then
                sidebar_win = win
              end
            end

            -- 获取编辑器总高度
            local total_height = vim.o.lines - vim.o.cmdheight - 1 -- 减去命令行和状态栏

            -- 设置ask窗口高度为固定值 (12行)
            if ask_win then
              vim.api.nvim_win_set_height(ask_win, 12)
              print("Ask window height reset to 12 lines")
            end

            -- 设置sidebar窗口高度为尽可能大
            if sidebar_win then
              -- 计算可用高度 (总高度减去ask窗口高度和一些边距)
              local available_height = total_height - 10 -- 为ask窗口和边距预留空间
              if available_height > 20 then -- 确保有最小高度
                vim.api.nvim_win_set_height(sidebar_win, available_height)

                -- 移动光标到回复窗口底部
                vim.api.nvim_set_current_win(sidebar_win)
                local buf = vim.api.nvim_win_get_buf(sidebar_win)
                local line_count = vim.api.nvim_buf_line_count(buf)
                vim.api.nvim_win_set_cursor(sidebar_win, { line_count, 0 })

                print("Sidebar window height reset and cursor moved to bottom")
              end
            end

            if not ask_win and not sidebar_win then
              print("No Avante windows found")
            end
          end

          reset_avante_windows()
        end,
        mode = "n",
        desc = "Reset Avante windows height",
      },
    },
    config = function(_, opts)
      -- 创建用户命令
      vim.api.nvim_create_user_command("AvanteResetWindows", function()
        -- 重置avante窗口高度的函数
        local wins = vim.api.nvim_list_wins()
        local ask_win = nil
        local sidebar_win = nil

        -- 查找avante相关窗口
        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          local filetype = vim.bo[buf].filetype

          -- 检查是否是ask窗口 (通常是输入窗口)
          if filetype == "AvanteInput" or buf_name:match("Avante.*Input") then
            ask_win = win
          -- 检查是否是sidebar窗口 (回复窗口)
          elseif filetype == "Avante" or buf_name:match("Avante") then
            sidebar_win = win
          end
        end

        -- 获取编辑器总高度
        local total_height = vim.o.lines - vim.o.cmdheight - 1 -- 减去命令行和状态栏

        -- 设置ask窗口高度为固定值 (12行)
        if ask_win then
          vim.api.nvim_win_set_height(ask_win, 12)
          print("Ask window height reset to 12 lines")
        end

        -- 设置sidebar窗口高度为尽可能大
        if sidebar_win then
          -- 计算可用高度 (总高度减去ask窗口高度和一些边距)
          local available_height = total_height - 10 -- 为ask窗口和边距预留空间
          if available_height > 20 then -- 确保有最小高度
            vim.api.nvim_win_set_height(sidebar_win, available_height)

            -- 移动光标到回复窗口底部
            vim.api.nvim_set_current_win(sidebar_win)
            local buf = vim.api.nvim_win_get_buf(sidebar_win)
            local line_count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(sidebar_win, { line_count, 0 })

            print("Sidebar window height reset and cursor moved to bottom")
          end
        end

        if not ask_win and not sidebar_win then
          print("No Avante windows found")
        end
      end, {
        desc = "Reset Avante window heights and move cursor to bottom",
      })

      -- 可选：自动在窗口大小改变时重置avante窗口（如tmux调整大小）
      vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("AvanteWindowResize", { clear = true }),
        callback = function()
          -- 延迟执行，确保窗口大小调整完成
          vim.defer_fn(function()
            -- 检查是否有avante窗口打开
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
              vim.cmd("AvanteResetWindows")
            end
          end, 100) -- 延迟100ms
        end,
      })

      -- 设置avante插件
      require("avante").setup(opts)
    end,
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "claude",
      auto_suggestions_provider = "openai",
      cursor_applying_provider = "openai",
      selector = {
        provider = "telescope",
        provider_opts = {},
      },
      web_search_engine = {
        provider = "tavily", -- tavily, serpapi, searchapi, google or kagi
      },
      dual_boost = {
        enabled = true,
        first_provider = "claude",
        second_provider = "openai",
        prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000, -- Timeout in milliseconds
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        minimize_diff = true,
        enable_token_counting = true,
        enable_cursor_planning_mode = false,
        enable_claude_text_editor_tool_mode = false,
      },
      prompt_logger = {
        enabled = false,
        log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
        fortune_cookie_on_success = false,
        next_prompt = {
          normal = "<C-n>",
          insert = "<C-n>",
        },
        prev_prompt = {
          normal = "<C-p>",
          insert = "<C-p>",
        },
      },
      mappings = {
        diff = {
          ours = "co",
          all_theirs = "ca",
          theirs = "ct",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        stop = "<c-c>",
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<C-s>",
          insert = "<C-s>",
        },
        cancel = {
          normal = { "<C-c>", "q" },
          insert = { "<C-c>" },
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          retry_user_request = "r",
          edit_user_request = "e",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
          remove_file = "d",
          add_file = "@",
          close = { "q" },
          close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
        },
        ask = nil,
        toggle = {
          default = "<leader>aa",
          debug = "<leader>ad",
          hint = "<leader>ah",
          -- suggestion = "<leader>as",
          repomap = "<leader>aR",
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = "right", -- the position of the sidebar
        wrap = true, -- similar to vim.o.wrap
        width = 50, -- default % based on available width
        sidebar_header = {
          enabled = true, -- true, false to enable/disable the header
          align = "left", -- left, center, right for title
          rounded = false,
        },
        input = {
          provider = "snacks",
          height = 12,
          provider_opts = {
            title = "Avante Input",
            icon = " ",
          },
        },

        edit = {
          border = "rounded",
          start_insert = false, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = false, -- Start insert mode when opening the ask window
          border = "rounded",
          ---@type "ours" | "theirs"
          focus_on_apply = "ours", -- which diff to focus after applying
        },
      },
      highlights = {
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      diff = {
        autojump = true,
        list_opener = "copen",
        override_timeoutlen = 500,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
      rag_service = {
        enabled = false, -- Enables the RAG service
        host_mount = os.getenv("HOME"), -- Host mount path for the rag service
        provider = "ollama", -- The provider to use for RAG service (e.g. openai or ollama)
        llm_model = "llama3:8b", -- The LLM model to use for RAG service
        embed_model = "nomic-embed-text", -- The embedding model to use for RAG service
        endpoint = "http://localhost:11434", -- The API endpoint for RAG service
      },
      -- other config
      -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
      disabled_tools = {},
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
