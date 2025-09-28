return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    enabled = vim.g.ai_partner == "avante",
    keys = {
      { "<leader>an", ":AvanteChatNew<CR>", mode = "n" },
      { "<leader>ac", ":AvanteClear<CR>", mode = "n" },
    },
    config = function(_, opts)
      require("avante").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "AvanteInput",
        callback = function()
          vim.keymap.set("i", "<M-CR>", "<CR>", { buffer = true, desc = "Insert newline in Avante input" })
        end,
      })
    end,
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "claude",
      auto_suggestions_provider = "claude",
      cursor_applying_provider = "aihubmix",
      selector = {
        provider = "telescope",
        provider_opts = {},
      },
      web_search_engine = {
        provider = "tavily",
      },
      dual_boost = {
        enabled = true,
        first_provider = "claude",
        second_provider = "openai",
        prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000,
      },
      providers = {
        aihubmix = {
          model = "aihubmix-Llama-3-3-70B-Instruct",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = true,
        support_paste_from_clipboard = true,
        minimize_diff = true,
        enable_token_counting = true,
        enable_cursor_planning_mode = true,
        enable_cursor_applying_mode = true,
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
          normal = "<CR>",
          insert = "<CR>",
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
          close_from_input = nil,
        },
        ask = nil,
        toggle = {
          default = "<leader>aa",
          debug = "<leader>ad",
          hint = "<leader>ah",
          repomap = "<leader>aR",
        },
      },
      hints = { enabled = true },
      windows = {
        position = "right",
        wrap = true,
        width = 50,
        sidebar_header = {
          enabled = true,
          align = "left",
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
          start_insert = false,
        },
        ask = {
          floating = false,
          start_insert = false,
          border = "rounded",

          focus_on_apply = "ours",
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
        enabled = false,
        host_mount = os.getenv("HOME"),
        provider = "ollama",
        llm_model = "llama3:8b",
        embed_model = "nomic-embed-text",
        endpoint = "http://localhost:11434",
      },
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
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-mini/mini.pick",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "ibhagwan/fzf-lua",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
