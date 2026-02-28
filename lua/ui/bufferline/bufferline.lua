local M = {}
local TAB_CELL_WIDTH = 24
local TAB_ICON_WIDTH = 4
local TAB_CLOSE_WIDTH = 5
local TAB_TITLE_WIDTH = TAB_CELL_WIDTH - TAB_ICON_WIDTH - TAB_CLOSE_WIDTH
local pal = require("ui.colorschemes.palette")

function M.set_highlights()
  local p = pal.get()
  local active_bg = p.bg0
  local inactive_bg = pal.lighten(p.bg0, 8) or p.bg2
  local highlights = {
    TabLineTheme = { fg = p.blue, bg = p.bg0 },
    TabLinePlus = { fg = p.green, bg = p.bg0 },
    TabLineSave = { fg = p.bg4, bg = p.bg0 },
    TabLineSaveModified = { fg = p.fg0, bg = p.bg0 },
    TabLineSel = { fg = p.fg0, bg = active_bg },
    TabLineNorm = { fg = p.bg3, bg = inactive_bg },
    TabLineCloseSel = { fg = p.red, bg = active_bg },
    TabLineCloseSelModified = { fg = p.green, bg = active_bg },
    TabLineCloseNorm = { fg = p.bg3, bg = inactive_bg },
    TabLineCloseNormModified = { fg = p.green, bg = inactive_bg },
  }

  for group, colors in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, { fg = colors.fg, bg = colors.bg })
  end
end

local function fit_text_width(text, width)
  text = text or ""
  if width <= 0 then
    return ""
  end

  local text_width = vim.fn.strdisplaywidth(text)
  if text_width == width then
    return text
  end

  if text_width < width then
    local total_padding = width - text_width
    local left_padding = math.floor(total_padding / 2)
    local right_padding = total_padding - left_padding
    return string.rep(" ", left_padding) .. text .. string.rep(" ", right_padding)
  end

  local ellipsis = "..."
  local ellipsis_width = vim.fn.strdisplaywidth(ellipsis)
  if width <= ellipsis_width then
    return string.rep(".", width)
  end

  local target_width = width - ellipsis_width
  local truncated = ""
  local char_index = 0

  while true do
    local char = vim.fn.strcharpart(text, char_index, 1)
    if char == "" then
      break
    end

    local next_width = vim.fn.strdisplaywidth(truncated .. char)
    if next_width > target_width then
      break
    end

    truncated = truncated .. char
    char_index = char_index + 1
  end

  local truncated_width = vim.fn.strdisplaywidth(truncated)
  if truncated_width < target_width then
    truncated = truncated .. string.rep(" ", target_width - truncated_width)
  end

  return truncated .. ellipsis
end

function _G.SavePlease()
  vim.cmd("w")
end

function _G.newTab()
  vim.cmd("tab new")
end

M.title = function(bufnr)
  local file = vim.fn.bufname(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")

  if buftype == "help" then
    return " help:" .. vim.fn.fnamemodify(file, ":t:r")
  elseif buftype == "quickfix" then
    return " quickfix"
  elseif filetype == "netrw" then
    return " Netrw"
  elseif filetype == "TelescopePrompt" then
    return " Telescope"
  elseif filetype == "git" then
    return " Git"
  elseif buftype == "terminal" then
    local _, mtch = string.match(file, "term:(.*):(%a+)")
    return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ":t")
  elseif file == "" or filetype == "" then
    return "[No Name]"
  else
    return vim.fn.pathshorten(vim.fn.fnamemodify(file, ":p:~:t"))
  end
end

M.icon = function(bufnr)
  local buftype = vim.fn.getbufvar(bufnr, "&buftype")
  local filetype = vim.fn.getbufvar(bufnr, "&filetype")
  local filename = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ":t")
  local extension = vim.fn.fnamemodify(filename, ":e")

  if buftype == "terminal" then
    return ""
  elseif buftype == "help" then
    return "󰋖"
  elseif buftype == "quickfix" then
    return "󱖫"
  elseif filetype == "TelescopePrompt" then
    return "󰍉"
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return ""
  end

  local icon = devicons.get_icon(filename, extension, { default = true })
  if (not icon or icon == "") and type(devicons.get_icon_by_filetype) == "function" and filetype ~= "" then
    icon = devicons.get_icon_by_filetype(filetype, { default = true })
  end

  return icon or ""
end

M.modified = function(bufnr)
  return vim.fn.getbufvar(bufnr, "&modified") == 1 and "" or ""
end

M.rightButton2 = function()
  return "%#TabLineTheme#%@v:lua.CycleThemePreset@  %#TabLineFill#"
end

M.rightButton3 = function()
  return "%#TabLinePlus#%@v:lua.newTab@  %#TabLineFill#"
end

M.rightButton4 = function()
  local bufnr = vim.fn.bufnr("%")
  local is_modified = vim.fn.getbufvar(bufnr, "&modified") == 1
  local hl_group = is_modified and "TabLineSaveModified" or "TabLineSave"
  return string.format("%%#%s#%%@v:lua.SavePlease@ 󰆓 %%#TabLineFill#", hl_group)
end

M.closeButton = function(index, is_selected)
  local bufnr = vim.fn.tabpagebuflist(index)[1]
  local is_modified = vim.fn.getbufvar(bufnr, "&modified") == 1
  local hl_group
  if is_selected then
    hl_group = is_modified and "TabLineCloseSelModified" or "TabLineCloseSel"
  else
    hl_group = is_modified and "TabLineCloseNormModified" or "TabLineCloseNorm"
  end

  if is_modified then
    return string.format("%%#%s#%s%%#TabLine#", hl_group, fit_text_width(M.modified(bufnr), TAB_CLOSE_WIDTH))
  end

  return string.format("%%#%s#%%%dX%s%%#TabLine#", hl_group, index, fit_text_width(M.modified(bufnr), TAB_CLOSE_WIDTH))
end

M.cell = function(index)
  local is_selected = vim.fn.tabpagenr() == index
  local buflist = vim.fn.tabpagebuflist(index)
  local winnr = vim.fn.tabpagewinnr(index)
  local bufnr = buflist[winnr]
  local hl_group = is_selected and "TabLineSel" or "TabLineNorm"
  local raw_title = M.title(bufnr):gsub("^%s+", "")
  local icon = fit_text_width(M.icon(bufnr), TAB_ICON_WIDTH)
  local title = fit_text_width(raw_title, TAB_TITLE_WIDTH)

  return string.format(
    "%%#%s#%%%dT%s%s%s%%T",
    hl_group,
    index,
    icon,
    title,
    M.closeButton(index, is_selected)
  )
end

M.bufferline = function()
  local line = ""
  for i = 1, vim.fn.tabpagenr("$"), 1 do
    line = line .. M.cell(i)
  end

  line = line .. "%#TabLineFill#%="
  line = line .. M.rightButton4() .. M.rightButton3() .. M.rightButton2()

  if vim.fn.tabpagenr("$") > 1 then
    line = line .. "%#TabLine#%999X"
  end

  return line
end

local setup = function()
  M.set_highlights()
  vim.opt.tabline = "%!v:lua.require'ui.bufferline.bufferline'.helpers.bufferline()"
end

return {
  helpers = M,
  set_highlights = M.set_highlights,
  setup = setup,
}
