local colors = require("ui.colorschemes.colors")

local M = {}

-- ── Color Utilities ─────────────────────────────────────────────────

function M.hex_to_rgb(hex)
  local cleaned = type(hex) == "string" and hex:gsub("^#", "") or ""
  if #cleaned ~= 6 or cleaned:find("[^%x]") then
    return nil, nil, nil
  end
  return tonumber(cleaned:sub(1, 2), 16),
    tonumber(cleaned:sub(3, 4), 16),
    tonumber(cleaned:sub(5, 6), 16)
end

function M.rgb_to_hex(r, g, b)
  local function clamp(v)
    return math.max(0, math.min(255, math.floor(v + 0.5)))
  end
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

--- Lighten a hex color by `percent` (0–100).
---@param hex string
---@param percent number
---@param fallback? string  returned when `hex` is invalid
---@return string
function M.lighten(hex, percent, fallback)
  local r, g, b = M.hex_to_rgb(hex)
  if not r then
    return fallback or hex
  end
  local t = math.max(0, math.min(100, percent or 0)) / 100
  return M.rgb_to_hex(r + (255 - r) * t, g + (255 - g) * t, b + (255 - b) * t)
end

--- Dim (darken) a hex color by `percent` (0–100).
---@param hex string
---@param percent number
---@param fallback? string
---@return string
function M.dim(hex, percent, fallback)
  local r, g, b = M.hex_to_rgb(hex)
  if not r then
    return fallback or hex
  end
  local factor = (100 - math.max(0, math.min(100, percent or 0))) / 100
  return M.rgb_to_hex(r * factor, g * factor, b * factor)
end

-- ── Shade Generation ────────────────────────────────────────────────

-- Percentage steps for auto-generated background shades (lighter from bg).
local bg_steps = { 4, 8, 14, 22 }
-- Percentage steps for auto-generated foreground shades (dimmer from fg).
local fg_steps = { 5, 15, 30, 45 }

--- Resolve a raw scheme table into the full palette consumed by highlights.
---@param scheme table  a raw entry from colors.lua
---@return table palette  { bg0..bg4, fg0..fg4, white, red, green, yellow, blue, purple, aqua, orange, gray }
local function resolve(scheme)
  -- Background shades: bg0 is the base, bg1–bg4 are progressively lighter.
  local bg0 = scheme.background
  local bg1 = scheme.bg1 or M.lighten(bg0, bg_steps[1])
  local bg2 = scheme.bg2 or M.lighten(bg0, bg_steps[2])
  local bg3 = scheme.bg3 or M.lighten(bg0, bg_steps[3])
  local bg4 = scheme.bg4 or M.lighten(bg0, bg_steps[4])

  -- Foreground shades: fg0 is the brightest, fg1–fg4 are progressively dimmer.
  local fg0 = scheme.foreground
  local fg1 = scheme.fg1 or M.dim(fg0, fg_steps[1])
  local fg2 = scheme.fg2 or M.dim(fg0, fg_steps[2])
  local fg3 = scheme.fg3 or M.dim(fg0, fg_steps[3])
  local fg4 = scheme.fg4 or M.dim(fg0, fg_steps[4])

  return {
    name = scheme.name,

    bg0 = bg0,
    bg1 = bg1,
    bg2 = bg2,
    bg3 = bg3,
    bg4 = bg4,

    fg0 = fg0,
    fg1 = fg1,
    fg2 = fg2,
    fg3 = fg3,
    fg4 = fg4,

    white = scheme.color15 or fg0,

    red = scheme.color1,
    green = scheme.color2,
    yellow = scheme.color3,
    blue = scheme.color4,
    purple = scheme.color5,
    aqua = scheme.color6,
    orange = scheme.orange,
    gray = scheme.comment,
  }
end

-- ── State ───────────────────────────────────────────────────────────

local current_scheme = nil   -- raw scheme from colors.lua
local current_palette = nil  -- resolved palette

--- Set the active scheme by name. Does NOT apply highlights.
---@param name string
---@return boolean ok
---@return string|nil err
function M.set(name)
  local scheme = colors.get(name)
  if not scheme then
    return false, ("Unknown scheme '%s'"):format(tostring(name))
  end
  current_scheme = scheme
  current_palette = resolve(scheme)
  return true, nil
end

--- Return the resolved palette for the current scheme.
---@return table
function M.get()
  if not current_palette then
    -- Fall back to first scheme in order.
    local fallback = colors.order[1]
    M.set(fallback)
  end
  return current_palette
end

--- Return the raw scheme table (useful for terminal colors).
---@return table
function M.raw()
  if not current_scheme then
    M.get() -- ensure initialised
  end
  return current_scheme
end

return M
