local mode = arg[1]

if mode ~= "install" and mode ~= "update" then
  error("plugin-sync requires install or update mode")
end

local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  error("Lazy.nvim is unavailable: " .. tostring(lazy))
end

local config = require("lazy.core.config")

local function collect_spec_errors()
  local failures = {}

  for _, notification in ipairs((config.spec and config.spec.notifs) or {}) do
    if (tonumber(notification.level) or vim.log.levels.ERROR) >= vim.log.levels.ERROR then
      local message = vim.trim(tostring(notification.msg or "unknown plugin specification error"))
      if notification.file and notification.file ~= "" then
        message = tostring(notification.file) .. ": " .. message
      end
      table.insert(failures, "spec: " .. message)
    end
  end

  return failures
end

local function collect_task_errors()
  local failures = {}
  local seen = {}

  local function inspect(plugins)
    for key, plugin in pairs(plugins or {}) do
      if type(plugin) == "table" and plugin._ and not seen[plugin] then
        seen[plugin] = true
        local name = plugin.name or tostring(key)
        for _, task in ipairs(plugin._.tasks or {}) do
          if task:has_errors() then
            local output = vim.trim(task:output(vim.log.levels.ERROR) or "")
            local message = name .. ":" .. task.name
            if output ~= "" then
              message = message .. ": " .. output
            end
            table.insert(failures, message)
          end
        end
      end
    end
  end

  inspect(config.plugins)
  inspect(config.to_clean)

  table.sort(failures)
  return failures
end

local function collect_failures()
  local failures = collect_spec_errors()
  vim.list_extend(failures, collect_task_errors())
  table.sort(failures)
  return failures
end

local function run(label, action)
  local ok, result = pcall(action)
  if not ok then
    error(label .. " failed: " .. tostring(result))
  end

  local failures = collect_failures()
  if #failures > 0 then
    error(label .. " reported plugin errors:\n" .. table.concat(failures, "\n"))
  end
end

if mode == "install" then
  local canonical_lockfile = vim.env.DOTFILES_NVIM_CANONICAL_LOCKFILE
  if canonical_lockfile and canonical_lockfile ~= "" then
    config.options.lockfile = canonical_lockfile
    local lock = require("lazy.manage.lock")
    lock._loaded = false
    lock.lock = {}
  end
  run("Lazy restore", function()
    lazy.restore({ wait = true, show = false })
  end)
else
  run("Lazy sync", function()
    lazy.sync({ wait = true, show = false })
  end)
end
