return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    enabled = vim.g.ai_partner == "avante",
    keys = {
      { "<leader>an", ":AvanteChatNew<CR>", mode = "n" },
      { "<leader>ac", ":AvanteClear<CR>", mode = "n" },
    },
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
          height = 8,
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
