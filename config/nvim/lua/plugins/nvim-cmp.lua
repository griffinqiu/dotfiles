local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function create_tab_mapping(direction)
  return function(fallback)
    local cmp = require("cmp")
    if cmp.visible() then
      if direction == "next" then
        cmp.select_next_item()
      else
        cmp.select_prev_item()
      end
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end
end

local function create_ctrl_mapping(direction)
  return function(fallback)
    local cmp = require("cmp")
    if cmp.visible() then
      if direction == "next" then
        cmp.select_next_item()
      else
        cmp.select_prev_item()
      end
    else
      fallback()
    end
  end
end

return {
  {
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    opts = function(_, opts)
      local cmp = require("cmp")

      opts.completion = opts.completion or {}
      opts.completion.autocomplete = false

      opts.mapping = {
        ["<Tab>"] = cmp.mapping(create_tab_mapping("next"), { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(create_tab_mapping("prev"), { "i", "s" }),
        ["<C-n>"] = cmp.mapping(create_ctrl_mapping("next"), { "i", "s" }),
        ["<C-p>"] = cmp.mapping(create_ctrl_mapping("prev"), { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
      }

      return opts
    end,
  },
}
