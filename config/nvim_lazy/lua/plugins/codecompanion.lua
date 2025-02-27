local mapping_key_prefix = "<leader>a"

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { mapping_key_prefix, group = "AI Code Companion", mode = { "n", "v" } },
      },
    },
  },
  { "CopilotC-Nvim/CopilotChat.nvim", enabled = false },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      { "echasnovski/mini.diff" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
      { "j-hui/fidget.nvim" },
      { "hrsh7th/nvim-cmp" },
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          lb_openai = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "https://lboneapi.longbridge-inc.com",
                api_key = "LBOPENAI_API_KEY",
                chat_url = "/v1/chat/completions",
              },
              schema = {
                model = {
                  default = "gpt-4o", -- define llm model to be used
                },
                temperature = {
                  order = 2,
                  mapping = "parameters",
                  type = "number",
                  optional = true,
                  default = 0.8,
                  desc = "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
                  validate = function(n)
                    return n >= 0 and n <= 2, "Must be between 0 and 2"
                  end,
                },
                max_completion_tokens = {
                  order = 3,
                  mapping = "parameters",
                  type = "integer",
                  optional = true,
                  default = nil,
                  desc = "An upper bound for the number of tokens that can be generated for a completion.",
                  validate = function(n)
                    return n > 0, "Must be greater than 0"
                  end,
                },
                stop = {
                  order = 4,
                  mapping = "parameters",
                  type = "string",
                  optional = true,
                  default = nil,
                  desc = "Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
                  validate = function(s)
                    return s:len() > 0, "Cannot be an empty string"
                  end,
                },
                logit_bias = {
                  order = 5,
                  mapping = "parameters",
                  type = "map",
                  optional = true,
                  default = nil,
                  desc = "Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
                  subtype_key = {
                    type = "integer",
                  },
                  subtype = {
                    type = "integer",
                    validate = function(n)
                      return n >= -100 and n <= 100, "Must be between -100 and 100"
                    end,
                  },
                },
              },
            })
          end,

          localhost_deepseek = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "my_deepseek",
              schema = {
                model = {
                  default = "deepseek-r1:14b",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
        },
        opts = {
          language = "Chinese",
          log_level = "DEBUG",
        },
        display = {
          inline = {
            layout = "vertical", -- vertical|horizontal|buffer
          },
          diff = {
            provider = "mini_diff",
          },
          action_palette = {
            provider = "telescope",
          },
        },
        strategies = {
          inline = {
            adapter = "lb_openai",
            keymaps = {
              accept_change = {
                modes = { n = "ga" },
                description = "Accept the suggested change",
              },
              reject_change = {
                modes = { n = "gr" },
                description = "Reject the suggested change",
              },
            },
          },
          chat = {
            adapter = "lb_openai",
            roles = { llm = "🤖 Robot", user = "Griffin" },
            keymaps = {
              toggle_chat = {
                modes = { n = "q" },
                description = "Toggle Chat",
                callback = function()
                  vim.cmd("CodeCompanionChat Toggle")
                end,
              },
              close = {
                modes = {
                  n = "gq",
                },
                index = 4,
                callback = "keymaps.close",
                description = "Close Chat",
              },
              stop = {
                modes = {
                  n = "<c-c>",
                },
                index = 5,
                callback = "keymaps.stop",
                description = "Stop Request",
              },
            },
            slash_commands = {
              ["file"] = {
                callback = "strategies.chat.slash_commands.file",
                description = "Select a file using Telescope",
                opts = {
                  provider = "telescope",
                  contains_code = true,
                },
              },
              ["buffer"] = {
                callback = "strategies.chat.slash_commands.buffer",
                description = "Insert open buffers",
                opts = {
                  contains_code = true,
                  provider = "telescope",
                },
              },
            },
          },
        },
      })
    end,
    keys = {
      { "<leader>2", ":CodeCompanionChat Toggle<cr>", mode = "n", desc = "CodeCompanionChat Toggle" },
      -- Recommend setup
      {
        mapping_key_prefix .. "c",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Code Companion - Code Actions",
      },
      {
        mapping_key_prefix .. "a",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "Code Companion - Toggle",
        mode = { "n", "v" },
      },
      -- Some common usages with visual mode
      {
        mapping_key_prefix .. "e",
        "<cmd>CodeCompanion /explain<cr>",
        desc = "Code Companion - Explain code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "f",
        "<cmd>CodeCompanion /fix<cr>",
        desc = "Code Companion - Fix code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "l",
        "<cmd>CodeCompanion /lsp<cr>",
        desc = "Code Companion - Explain LSP diagnostic",
        mode = { "n", "v" },
      },
      {
        mapping_key_prefix .. "t",
        "<cmd>CodeCompanion /tests<cr>",
        desc = "Code Companion - Generate unit test",
        mode = "v",
      },
      {
        mapping_key_prefix .. "m",
        "<cmd>CodeCompanion /commit<cr>",
        desc = "Code Companion - Git commit message",
      },
      -- Custom prompts
      {
        mapping_key_prefix .. "M",
        "<cmd>CodeCompanion /staged-commit<cr>",
        desc = "Code Companion - Git commit message (staged)",
      },
      {
        mapping_key_prefix .. "d",
        "<cmd>CodeCompanion /inline-doc<cr>",
        desc = "Code Companion - Inline document code",
        mode = "v",
      },
      { mapping_key_prefix .. "D", "<cmd>CodeCompanion /doc<cr>", desc = "Code Companion - Document code", mode = "v" },
      {
        mapping_key_prefix .. "r",
        "<cmd>CodeCompanion /refactor<cr>",
        desc = "Code Companion - Refactor code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "R",
        "<cmd>CodeCompanion /review<cr>",
        desc = "Code Companion - Review code",
        mode = "v",
      },
      {
        mapping_key_prefix .. "n",
        "<cmd>CodeCompanion /naming<cr>",
        desc = "Code Companion - Better naming",
        mode = "v",
      },
      -- Quick chat
      {
        mapping_key_prefix .. "q",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CodeCompanion " .. input)
          end
        end,
        desc = "Code Companion - Quick chat",
      },
    },
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCmd",
    },
  },
}
