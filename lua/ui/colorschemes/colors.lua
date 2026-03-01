local M = {}

--   name          string   unique identifier
--   background    string   main editor background
--   darker        string   darker variant (e.g. sidebar, terminal)
--   black         string   true black (usually same as background)
--   foreground    string   main text color
--   cursorline    string   cursorline background
--   cursor        string   cursor color
--   comment       string   comment / muted text color
--   orange        string   accent used by the highlight engine
--   color0–color15         standard terminal palette
--
-- Optional per-scheme shade overrides (take precedence over auto-generated):
--   bg1, bg2, bg3, bg4     background shades (lightest → darkest)
--   fg1, fg2, fg3, fg4     foreground shades (dimmest → brightest)

M.schemes = {
  {
    name = "default",
    comment = "#8d8d8d",
    background = "#0c0e0f",
    darker = "#0a0b0c",
    black = "#0c0e0f",
    foreground = "#e9edf2",
    cursorline = "#13161a",
    cursor = "#e9edf2",
    orange = "#e09855",
    color0 = "#13161a",
    color1 = "#ef5a5a",
    color2 = "#a3c76f",
    color3 = "#e8b563",
    color4 = "#83a5ba",
    color5 = "#ab89b2",
    color6 = "#80c4af",
    color7 = "#d1dae4",
    color8 = "#333333",
    color9 = "#ef5a5a",
    color10 = "#a3c76f",
    color11 = "#e8b563",
    color12 = "#83a5ba",
    color13 = "#ab89b2",
    color14 = "#80c4af",
    color15 = "#e9edf2",
  },
  {
    name = "gruber_darker",
    comment = "#95a99f",
    background = "#181818",
    darker = "#101010",
    black = "#181818",
    foreground = "#f4f4ff",
    cursorline = "#282828",
    cursor = "#ffdd33",
    orange = "#cc8c3c",
    bg1 = "#141414",
    bg2 = "#1e1e1e",
    bg3 = "#252838",
    bg4 = "#31364a",
    fg1 = "#fcfcfc",
    fg2 = "#e4e7f5",
    fg3 = "#b8bdd3",
    fg4 = "#6c7086",
    color0 = "#1f1f1f",
    color1 = "#f43841",
    color2 = "#73c936",
    color3 = "#ffdd33",
    color4 = "#96a6c8",
    color5 = "#9e95c7",
    color6 = "#95a99f",
    color7 = "#e4e4ef",
    color8 = "#52494e",
    color9 = "#ff4f58",
    color10 = "#73c936",
    color11 = "#ffdd33",
    color12 = "#afc0e2",
    color13 = "#b0a8d9",
    color14 = "#9fb3a9",
    color15 = "#f4f4ff",
  },
  {
    name = "radium",
    comment = "#515c68",
    background = "#080909",
    darker = "#0c0f12",
    black = "#101419",
    foreground = "#d4d4d5",
    cursorline = "#111419",
    cursor = "#d4d4d5",
    orange = "#fccf67",
    color0 = "#181c24",
    color1 = "#f87070",
    color2 = "#79dcaa",
    color3 = "#ffe59e",
    color4 = "#7ab0df",
    color5 = "#c397d8",
    color6 = "#70c0ba",
    color7 = "#d4d4d5",
    color8 = "#1c2228",
    color9 = "#fb7373",
    color10 = "#36c692",
    color11 = "#fccf67",
    color12 = "#5fb0fc",
    color13 = "#b77ee0",
    color14 = "#54c3d6",
    color15 = "#ffffff",
  },
}

M.order = { "default", "gruber_darker", "radium" }

---@param name string
---@return table|nil
function M.get(name)
  for _, scheme in ipairs(M.schemes) do
    if scheme.name == name then
      return scheme
    end
  end
  return nil
end

return M
