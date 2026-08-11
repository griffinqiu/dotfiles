local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local lazy_parent = vim.fn.fnamemodify(lazypath, ":h")
  local lazy_tmp = lazypath .. ".tmp." .. tostring(uv.os_getpid()) .. "." .. tostring(uv.hrtime())
  vim.fn.mkdir(lazy_parent, "p")
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazy_tmp })
  local clone_error = vim.v.shell_error ~= 0
  if not clone_error then
    local renamed, rename_error = uv.fs_rename(lazy_tmp, lazypath)
    if not renamed then
      if uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
        vim.fn.delete(lazy_tmp, "rf")
      else
        out = out .. "\nFailed to activate lazy.nvim: " .. tostring(rename_error)
        clone_error = true
      end
    end
  end
  if clone_error then
    vim.fn.delete(lazy_tmp, "rf")
    if #vim.api.nvim_list_uis() == 0 then
      io.stderr:write("Failed to clone lazy.nvim:\n", out, "\n")
      os.exit(1)
    end
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  lockfile = vim.env.DOTFILES_NVIM_SYNC_LOCKFILE or (vim.fn.stdpath("config") .. "/lazy-lock.json"),
  rocks = {
    enabled = false,
  },
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    -- version = false, -- always use the latest git commit
    version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
