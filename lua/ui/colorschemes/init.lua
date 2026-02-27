local palette = require("ui.colorschemes.palette")
local colors = require("ui.colorschemes.colors")

local M = {}

local state = {
  setup_done = false,
  current_name = nil,
}

local preset_file = vim.fn.stdpath("data") .. "/themepreset.txt"

local function save_preset(name)
  local file = io.open(preset_file, "w")
  if file then
    file:write(name)
    file:close()
  end
end

local function load_preset()
  local file = io.open(preset_file, "r")
  if not file then
    return nil
  end
  local content = vim.trim(file:read("*a") or "")
  file:close()
  return content ~= "" and content or nil
end

local function refresh_ui()
  package.loaded["ui.colorschemes.highlights"] = nil
  vim.o.background = "dark"
  require("ui.colorschemes.highlights").load()

  local barstyle = vim.g.barstyle
  if barstyle then
    local ok, mod = pcall(require, "ui.statusline." .. barstyle)
    if ok and type(mod.set_highlights) == "function" then
      mod.set_highlights()
    end
  end

  local ok_buf, bufferline = pcall(require, "ui.bufferline.bufferline")
  if ok_buf and type(bufferline.set_highlights) == "function" then
    bufferline.set_highlights()
  end

  vim.cmd("redrawstatus")
  pcall(vim.cmd, "redrawtabline")
end

function M.apply(name, opts)
  opts = opts or {}
  local ok, err = palette.set(name)
  if not ok then
    if not opts.silent then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return false
  end

  state.current_name = name

  if opts.persist ~= false then
    save_preset(name)
  end

  if opts.reload ~= false then
    refresh_ui()
  end

  return true
end

function M.current_name()
  return state.current_name
end

function M.cycle_next()
  local order = colors.order or {}
  if #order == 0 then
    vim.notify("No colorscheme presets configured", vim.log.levels.WARN)
    return
  end

  local idx
  if state.current_name then
    for i, n in ipairs(order) do
      if n == state.current_name then
        idx = i
        break
      end
    end
  end

  local next_name = (idx and order[(idx % #order) + 1]) or order[1]
  M.apply(next_name, { persist = true, reload = true })
end

function M.setup()
  if state.setup_done then
    return
  end
  state.setup_done = true

  local persisted = load_preset()
  if persisted then
    M.apply(persisted, { persist = false, reload = false, silent = true })
  end

  vim.o.background = "dark"
  require("ui.colorschemes.highlights").load()

  _G.CycleThemePreset = function()
    require("ui.colorschemes").cycle_next()
  end
end

M.setup()

return M
