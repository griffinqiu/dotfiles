return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    enabled = vim.g.ai_partner == "avante",
    keys = {
      { "<leader>an", ":AvanteChatNew<CR>", mode = "n" },
      -- { "<leader>ac", ":AvanteClear<CR>", mode = "n" },
    },
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "claude", -- The provider used in Aider mode or in the planning phase of Cursor Planning Mode
      -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
      -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
      -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
      auto_suggestions_provider = "claude",
      cursor_applying_provider = nil, -- The provider used in the applying phase of Cursor Planning Mode, defaults to nil, when nil uses Config.provider as the provider for the applying phase
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        temperature = 0,
        max_tokens = 20480,
      },
      vendors = {
        ["aihubmix/deepseek"] = {
          __inherited_from = "openai",
          api_key_name = "AIHUBMIX_API_KEY",
          endpoint = "https://aihubmix.com/v1",
          model = "DeepSeek-R1",
        },

        ["aihubmix/Llama"] = {
          __inherited_from = "openai",
          endpoint = "https://aihubmix.com/v1",
          model = "aihubmix-Llama-3-3-70B-Instruct",
          api_key_name = "AIHUBMIX_API_KEY",
          timeout = 30000,
          max_tokens = 20480,
          max_completion_tokens = 327680,
        },
        ["aihubmix/openai"] = {
          __inherited_from = "openai",
          endpoint = "https://aihubmix.com/v1",
          model = "gpt-4o",
          api_key_name = "AIHUBMIX_API_KEY",
          timeout = 30000,
          max_tokens = 16384,
        },
        ["aihubmix/claude"] = {
          __inherited_from = "claude",
          endpoint = "https://aihubmix.com",
          model = "claude-3-7-sonnet-20250219",
          api_key_name = "AIHUBMIX_API_KEY",
          timeout = 30000,
          max_tokens = 20480,
        },
        ["ollama/deepseek-r1"] = {
          __inherited_from = "openai",
          endpoint = "http://localhost:11434/v1",
          model = "deepseek-r1:32b",
          disable_tools = true,
          timeout = 30000,
          temperature = 0,
          max_completion_tokens = 40000,
        },
      },
      selector = {
        provider = "telescope",
        provider_opts = {},
      },
      web_search_engine = {
        provider = "tavily", -- tavily, serpapi, searchapi, google or kagi
        providers = {
          searxng = {
            api_url_name = "SEARXNG_API_URL",
            extra_request_body = {
              format = "json",
            },
            format_response_body = function(body)
              if body.results == nil then
                return "", nil
              end

              local jsn = vim.iter(body.results):map(function(result)
                return {
                  title = result.title,
                  url = result.url,
                  snippet = result.content,
                }
              end)

              return vim.json.encode(jsn), nil
            end,
          },
        },
      },
      ---Specify the special dual_boost mode
      ---1. enabled: Whether to enable dual_boost mode. Default to false.
      ---2. first_provider: The first provider to generate response. Default to "openai".
      ---3. second_provider: The second provider to generate response. Default to "claude".
      ---4. prompt: The prompt to generate response based on the two reference outputs.
      ---5. timeout: Timeout in milliseconds. Default to 60000.
      ---How it works:
      --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
      ---Note: This is an experimental feature and may not work as expected.
      dual_boost = {
        enabled = false,
        first_provider = "openai",
        second_provider = "claude",
        prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000, -- Timeout in milliseconds
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
        minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
        enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
        enable_claude_text_editor_tool_mode = false, -- Whether to enable Claude Text Editor Tool Mode.
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
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
          prefix = "> ",
          height = 8, -- Height of the input window in vertical layout
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
        ---@type AvanteConflictHighlights
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = "copen",
        --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --- Disable by setting to -1.
        override_timeoutlen = 500,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
      rag_service = {
        enabled = false, -- Enables the RAG service
        host_mount = "~/RAG-Data", -- Host mount path for the rag service
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
      disabled_tools = {
        "list_files",
        "search_files",
        "read_file",
        "create_file",
        "rename_file",
        "delete_file",
        "create_dir",
        "rename_dir",
        "delete_dir",
        "bash",
      },
      -- custom_tools = {
      --   {
      --     name = "run_go_tests", -- Unique name for the tool
      --     description = "Run Go unit tests and return results", -- Description shown to AI
      --     command = "go test -v ./...", -- Shell command to execute
      --     param = { -- Input parameters (optional)
      --       type = "table",
      --       fields = {
      --         {
      --           name = "target",
      --           description = "Package or directory to test (e.g. './pkg/...' or './internal/pkg')",
      --           type = "string",
      --           optional = true,
      --         },
      --       },
      --     },
      --     returns = { -- Expected return values
      --       {
      --         name = "result",
      --         description = "Result of the fetch",
      --         type = "string",
      --       },
      --       {
      --         name = "error",
      --         description = "Error message if the fetch was not successful",
      --         type = "string",
      --         optional = true,
      --       },
      --     },
      --     func = function(params, on_log, on_complete) -- Custom function to execute
      --       local target = params.target or "./..."
      --       return vim.fn.system(string.format("go test -v %s", target))
      --     end,
      --   },
      -- },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
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
