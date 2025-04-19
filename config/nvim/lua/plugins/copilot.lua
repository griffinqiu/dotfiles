return {
  {
    "zbirenbaum/copilot.lua",
    event = "VeryLazy",
    enabled = true,
    opts = function(_, opts)
      opts.suggestion = opts.suggestion or {}
      opts.suggestion.keymap = {
        accept = "<c-j>",
        next = "<m-n>",
        prev = "<m-p>",
      }
    end,
  },
}
