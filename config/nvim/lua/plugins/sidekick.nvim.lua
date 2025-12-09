return {
  {
    "folke/sidekick.nvim",
    enabled = vim.g.ai_partner == "sidekick",
    opts = function()
      return {
        nes = {
          enabled = false,
        },
        cli = {
          -- mux = {
          --   enabled = true,
          -- },
          win = {
            keys = {
              buffers = { "<m-b>", "buffers", mode = "nt", desc = "open buffer picker" },
              files = { "<m-f>", "files", mode = "nt", desc = "open file picker" },
              prompt = { "<m-p>", "prompt", mode = "t", desc = "insert prompt or context" },
            },
          },
          prompts = {
            -- 代码审查相关
            changes = "你能帮我审查一下我的代码变更吗？",
            review = "请审查 {file} 中可能存在的问题或改进建议。",

            -- 诊断和修复
            diagnostics = "请帮我修复 {file} 中的诊断问题：\n{diagnostics}",
            diagnostics_all = "请帮我修复所有诊断问题：\n{diagnostics_all}",
            fix = "请帮我修复{this}。",

            -- 文档和解释
            document = "为{function|line}添加详细的文档注释。",
            explain = "请解释{this}的作用和实现原理。",

            -- 优化和测试
            optimize = "{this}有哪些可以优化的地方？请给出具体建议。",
            tests = "请为{this}编写完整的单元测试。",

            -- 代码重构
            refactor = "请重构{this}，使代码更加清晰和可维护。",
            modernize = "将{this}重写为现代化的代码风格。",

            -- 代码生成
            implement = "请根据以下需求实现功能：{this}",
            complete = "请完成这段代码的实现：{this}",

            -- 代码分析
            complexity = "分析{this}的时间和空间复杂度。",
            security = "检查{this}中是否存在安全漏洞。",
          },
        },
      }
    end,
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            local nes = require("sidekick.nes")
            local message = nes.enabled and "Updating suggestions" or "Enabling NES and updating suggestions"
            vim.notify(message, vim.log.levels.INFO, { title = "Sidekick NES" })
            if not nes.enabled then
              vim.cmd("Sidekick nes enable")
            end
            vim.cmd("Sidekick nes update")
          end
        end,
        desc = "Goto/Apply Next Edit Suggestion or Update",
      },
      {
        "<leader>ue",
        function()
          vim.cmd("Sidekick nes toggle")
          vim.defer_fn(function()
            local nes_enabled = require("sidekick.nes").enabled
            local message = nes_enabled and "Enabled Sidekick NES" or "Disabled Sidekick NES"
            local level = nes_enabled and vim.log.levels.INFO or vim.log.levels.WARN
            vim.notify(message, level, { title = "Sidekick NES" })
          end, 100)
        end,
        mode = { "n" },
        desc = "Toggle Sidekick NES",
      },
    },
  },
}
