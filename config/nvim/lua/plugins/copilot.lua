return {
  {
    "folke/sidekick.nvim",
    opts = function()
      -- Accept inline suggestions or next edits
      LazyVim.cmp.actions.ai_nes = function()
        local Nes = require("sidekick.nes")
        if Nes.have() and (Nes.jump() or Nes.apply()) then
          return true
        end
      end
    end,
    keys = {
      -- nes is also useful in normal mode
      { "<c-j>", LazyVim.cmp.map({ "ai_nes" }, "<c-j>"), mode = { "n" }, expr = true },
    },
  },
}
