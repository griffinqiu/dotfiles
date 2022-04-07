local packer = require 'packer'
local use = packer.use

packer.startup({
  function()
    use 'wbthomason/packer.nvim'
    use 'b0o/mapx.nvim'

    require("plugins.use_appearance")(use)
    require("plugins.use_core")(use)
    require("plugins.use_ide")(use)
    require("plugins.use_lsp")(use)
    require("plugins.use_misc")(use)
    require("plugins.use_programming")(use)
    require("plugins.use_scm")(use)
  end,
  config = {
    max_jobs = 16,
  },
})

-- require 'plugins.configs.cmp'
-- require 'plugins.configs.telescope'
