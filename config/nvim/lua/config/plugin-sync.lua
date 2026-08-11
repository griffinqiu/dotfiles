local mode = arg[1]

if mode ~= "install" and mode ~= "update" then
  error("plugin-sync requires install or update mode")
end

local lazy_ok, lazy = pcall(require, "lazy")
if not lazy_ok then
  error("Lazy.nvim is unavailable: " .. tostring(lazy))
end

local function collect_task_errors()
  local config = require("lazy.core.config")
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

local function run(label, action)
  local ok, result = pcall(action)
  if not ok then
    error(label .. " failed: " .. tostring(result))
  end

  local failures = collect_task_errors()
  if #failures > 0 then
    error(label .. " reported plugin task errors:\n" .. table.concat(failures, "\n"))
  end
end

if mode == "install" then
  run("Lazy restore", function()
    lazy.restore({ wait = true, show = false })
  end)
else
  run("Lazy sync", function()
    lazy.sync({ wait = true, show = false })
  end)
end
