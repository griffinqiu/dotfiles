return {
  "echasnovski/mini.diff",
  config = function()
    -- diff.setup({
      -- -- Disabled by default
      -- source = diff.gen_source.none(),

    -- })
    local diff = require("mini.diff")
    diff.setup({
      -- Options for how hunks are visualized
      view = {
        -- Visualization style. Possible values are 'sign' and 'number'.
        -- Default: 'number' if line numbers are enabled, 'sign' otherwise.
        style = vim.go.number and 'number' or 'sign',

        -- Signs used for hunks with 'sign' view
        signs = { add = '▒', change = '▒', delete = '▒' },

        -- Priority of used visualization extmarks
        priority = 199,
      },

      -- Source for how reference text is computed/updated/etc
      -- Uses content from Git index by default
      source = diff.gen_source.save(),

      -- Delays (in ms) defining asynchronous processes
      delay = {
        -- How much to wait before update following every text change
        text_change = 200,
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Apply hunks inside a visual/operator region
        apply = 'ga',

        -- Reset hunks inside a visual/operator region
        reset = 'gr',

        -- Hunk range textobject to be used inside operator
        -- Works also in Visual mode if mapping differs from apply and reset
        textobject = 'gh',

        -- Go to hunk range in corresponding direction
        goto_first = '[H',
        goto_prev = '[h',
        goto_next = ']h',
        goto_last = ']H',
      },

      -- Various options
      options = {
        -- Diff algorithm. See `:h vim.diff()`.
        algorithm = 'histogram',

        -- Whether to use "indent heuristic". See `:h vim.diff()`.
        indent_heuristic = true,

        -- The amount of second-stage diff to align lines (in Neovim>=0.9)
        linematch = 60,

        -- Whether to wrap around edges during hunk navigation
        wrap_goto = false,
      },
    })
  end,
}
