local INSTANCE_NAME = "far"

local function toggle_grug_far(opts)
  vim.cmd("Neotree close")
  require("grug-far").toggle_instance(vim.tbl_extend("force", {
    instanceName = INSTANCE_NAME,
    staticTitle = "Find and Replace",
  }, opts or {}))
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
          })
        end
      end,
      mode = { "v" },
      desc = "Search and Replace (visual)",
    },
  },
}
