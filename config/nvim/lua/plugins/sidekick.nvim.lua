-- 内部状态：记录是否为全屏模式
local is_fullscreen = false
local saved_win_config = nil

-- 查找 sidekick CLI 窗口
local function find_sidekick_window()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf].filetype

    -- sidekick CLI 窗口的特征：filetype 或 bufname 包含 sidekick
    if filetype:match("sidekick") or bufname:match("sidekick") then
      return win
    end
  end
  return nil
end

local function toggle_sidekick_fullscreen()
  local win = find_sidekick_window()
  if not win then
    vim.notify("Sidekick CLI not found", vim.log.levels.WARN, { title = "Sidekick" })
    return
  end

  if is_fullscreen then
    if saved_win_config then
      vim.api.nvim_win_close(win, false)

      vim.defer_fn(function()
        vim.cmd("Sidekick cli show")
        is_fullscreen = false
        saved_win_config = nil
        vim.notify("Split mode", vim.log.levels.INFO, { title = "Sidekick CLI" })
      end, 50)
    end
  else
    local buf = vim.api.nvim_win_get_buf(win)
    saved_win_config = vim.api.nvim_win_get_config(win)
    vim.api.nvim_win_close(win, false)

    vim.defer_fn(function()
      local new_win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines - 3,
        style = "minimal",
        border = "none",
      })

      is_fullscreen = true
      vim.notify("Fullscreen mode", vim.log.levels.INFO, { title = "Sidekick CLI" })
    end, 50)
  end
end

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
          --   backend = "tmux",
          --   enabled = true,
          --   create = "terminal",
          -- },
          win = {
            float = {
              row = 0,
              col = 0,
              width = vim.o.columns,
              height = vim.o.lines - 3,
            },
            keys = {
              buffers = { "<m-b>", "buffers", mode = "nt", desc = "open buffer picker" },
              files = { "<m-f>", "files", mode = "nt", desc = "open file picker" },
              prompt = { "<m-p>", "prompt", mode = "t", desc = "insert prompt or context" },
              stopinsert = { "<c-s>", "stopinsert", mode = "t", desc = "enter normal mode" },
              back_to_insert = { "<c-s>", "startinsert", mode = "n", desc = "enter insert mode" },
              hide_n = false,
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
        "<c-j>",
        function()
          local nes = require("sidekick.nes")
          if nes.enabled then
            if not require("sidekick").nes_jump_or_apply() then
              vim.notify("Updating suggestions", vim.log.levels.INFO, { title = "Sidekick NES" })
              vim.cmd("Sidekick nes update")
            end
          else
            -- NES 未开启，执行默认的 <C-j> 行为
            local key = vim.api.nvim_replace_termcodes("<C-j>", true, false, true)
            vim.api.nvim_feedkeys(key, "n", false)
          end
        end,
        desc = "Goto/Apply Next Edit Suggestion or Update (when NES enabled)",
      },
      {
        "<leader>uj",
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
      {
        "<c-w>f",
        toggle_sidekick_fullscreen,
        mode = { "n" },
        desc = "Toggle Sidekick CLI layout (fullscreen/split)",
      },
    },
  },
}
