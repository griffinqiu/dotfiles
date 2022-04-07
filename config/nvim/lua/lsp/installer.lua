local lspconfig = require('lspconfig')
local lsp_installer = require('nvim-lsp-installer')
local langs = require('lsp.languages')

local M = {}

M.servers = {
  -- 'bashls',
  -- 'cssls',
  'gopls',
  -- 'html',
  -- 'jsonls',
  'solargraph',
  -- 'sumneko_lua',
  -- 'tailwindcss',
  -- 'tsserver',
  -- 'vuels',
}

local check_installed = function()
  local installed = vim.tbl_map(function(config)
    return config.name
  end, lsp_installer.get_installed_servers())

  for _, server in ipairs(installed) do
    if not vim.tbl_contains(M.servers, server) then
      vim.notify('LSP servers list missing: ' .. server, vim.log.levels.ERROR)
      break
    end
  end
end

M.setup = function(attacher, capabilities)
  local default_opts = {
    single_file_support = true,
    on_attach = attacher,
    capabilities = capabilities,
  }

  -- check_installed()

  lsp_installer.settings({
    ui = {
      icons = {
        server_installed = '',
        server_pending = '',
        server_uninstalled = '',
      },
    },
  })

  -- local tsserver_setting = {
    -- init_options = require("nvim-lsp-ts-utils").init_options,
    -- on_attach = function(client)
      -- local ts_utils = require('nvim-lsp-ts-utils')
      -- ts_utils.setup({
        -- update_imports_on_move = true,
        -- inlay_hints_highlight = 'NvimLspTSUtilsInlineHint',
        -- degbug = false,
      -- })
      -- ts_utils.setup_client(client)
    -- end
  -- }

  lsp_installer.on_server_ready(function(server)
    -- if server.name == "tsserver" then
      -- server:setup(tsserver_setting)
      -- vim.cmd 'do User LspAttachBuffers'
    -- else
      -- local config = vim.tbl_extend('keep', langs[server.name] or {}, default_opts)
      -- server:setup(vim.tbl_extend('keep', config, lspconfig[server.name]))
    -- end
    local config = vim.tbl_extend('keep', langs[server.name] or {}, default_opts)
    server:setup(vim.tbl_extend('keep', config, lspconfig[server.name]))
  end)

  require("lsp_signature").setup()
end

M.install = function()
  for _, server in ipairs(M.servers) do
    lsp_installer.install(server)
  end
end

return M