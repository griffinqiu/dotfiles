return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.position = "float"
      opts.window.mappings = opts.window.mappings or {}
      opts.window.mappings["/"] = false

      -- Add filesystem configuration
      opts.filesystem = opts.filesystem or {}
      opts.filesystem.commands = opts.filesystem.commands or {}
      opts.filesystem.commands.avante_add_files = function(state)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        local relative_path = require("avante.utils").relative_path(filepath)

        local sidebar = require("avante").get()

        local open = sidebar:is_open()
        -- ensure avante sidebar is open
        if not open then
          require("avante.api").ask()
          sidebar = require("avante").get()
        end

        sidebar.file_selector:add_selected_file(relative_path)

        -- remove neo tree buffer
        if not open then
          sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
        end
      end

      opts.filesystem.window = opts.filesystem.window or {}
      opts.filesystem.window.mappings = opts.filesystem.window.mappings or {}
      opts.filesystem.window.mappings["oa"] = "avante_add_files"

      return opts
    end,
  },
}
