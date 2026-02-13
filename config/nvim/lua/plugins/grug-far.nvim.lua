local INSTANCE_NAME = "far"

local function get_file_filter()
  local ext = vim.fn.expand("%:e")
  if ext == "" then
    return nil
  end
  return "*." .. ext
end

local function toggle_grug_far(opts)
  vim.cmd("Neotree close")
  local prefills = {}
  if not opts or not opts.prefills or not opts.prefills.filesFilter then
    prefills.filesFilter = get_file_filter()
  end

  local merged_opts = vim.tbl_deep_extend("force", {
    instanceName = INSTANCE_NAME,
    staticTitle = "Find and Replace",
    prefills = prefills,
  }, opts or {})

  require("grug-far").toggle_instance(merged_opts)
end

return {
  "MagicDuck/grug-far.nvim",
  opts = {
    windowCreationCommand = "topleft vsplit",
    openTargetWindow = {
      preferredLocation = "right",
    },
  },
  keys = {
    {
      "<leader>sr",
      function()
        toggle_grug_far()
      end,
      mode = { "n" },
      desc = "Search and Replace",
    },
    {
      "<leader>sr",
      function()
        vim.cmd("Neotree close")
        local grug_far = require("grug-far")
        if grug_far.is_instance_open(INSTANCE_NAME) then
          grug_far.toggle_instance({ instanceName = INSTANCE_NAME })
        else
          grug_far.with_visual_selection({
            instanceName = INSTANCE_NAME,
            staticTitle = "Find and Replace",
            prefills = {
              filesFilter = get_file_filter(),
            },
          })
        end
      end,
      mode = { "v" },
      desc = "Search and Replace (visual)",
    },
  },
}
