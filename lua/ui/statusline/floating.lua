local M = {}
local utils = require("ui.statusline.utils")
local pal = require("ui.colorschemes.palette")
local refresh_au_setup = false

local function esc(text)
  return tostring(text):gsub("%%", "%%%%")
end

local function str_truncate(text, max_width)
  local value = tostring(text or "")
  if max_width <= 0 then
    return ""
  end

  if vim.fn.strdisplaywidth(value) <= max_width then
    return value
  end

  local ellipsis = "..."
  local ellipsis_width = vim.fn.strdisplaywidth(ellipsis)
  if max_width <= ellipsis_width then
    return string.rep(".", max_width)
  end

  local target_width = max_width - ellipsis_width
  local out = ""
  local index = 0

  while true do
    local char = vim.fn.strcharpart(value, index, 1)
    if char == "" then
      break
    end
    if vim.fn.strdisplaywidth(out .. char) > target_width then
      break
    end
    out = out .. char
    index = index + 1
  end

  return out .. ellipsis
end

local function chip(hl, text)
  if not text or text == "" then
    return nil
  end
  return string.format("%%#%s# %s ", hl, esc(text))
end

local function icon_info_block(icon_hl, info_hl, icon, info)
  local info_chip = chip(info_hl, info)
  if not info_chip then
    return nil
  end

  local icon_text = tostring(icon or "")
  if vim.trim(icon_text) == "" then
    return info_chip
  end

  local icon_chip = chip(icon_hl, icon_text)
  if not icon_chip then
    return info_chip
  end

  return icon_chip .. info_chip
end

local function gap()
  return "%#StGap# "
end

local function add_block(blocks, block)
  if block and block ~= "" then
    blocks[#blocks + 1] = block
  end
end

local function join_blocks(blocks)
  if #blocks == 0 then
    return ""
  end

  local out = {}
  for i, block in ipairs(blocks) do
    out[#out + 1] = block
    if i < #blocks then
      out[#out + 1] = gap()
    end
  end
  return table.concat(out)
end

local function get_window_width()
  local ok, width = pcall(vim.api.nvim_win_get_width, 0)
  if ok then
    return width
  end
  return vim.o.columns
end

local function get_no_git_label(width)
  if width >= 130 then
    return "notgit"
  end
  if width >= 95 then
    return "notgit"
  end
  return "ng"
end

local function redraw_statusline()
  vim.cmd("redrawstatus")
end

local function setup_refresh_autocmds()
  if refresh_au_setup then
    return
  end
  refresh_au_setup = true

  local group = vim.api.nvim_create_augroup("StatuslineLiveRefresh", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = { "GitSignsUpdate", "GitSignsChanged" },
    callback = function(args)
      local bufnr = args and args.data and args.data.buffer
      if bufnr and bufnr ~= vim.api.nvim_get_current_buf() then
        return
      end
      redraw_statusline()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = group,
    callback = redraw_statusline,
  })
end

local function diff_totals_block(diff, _)
  local added = tonumber(diff and diff.added) or 0
  local changed = tonumber(diff and diff.changed) or 0
  local removed = tonumber(diff and diff.removed) or 0

  local out = { "%#StDiffTotalsBase# " }
  local tokens = {
    { "StDiffTotalsAdd", string.format("+%d", added) },
    { "StDiffTotalsChange", string.format("~%d", changed) },
    { "StDiffTotalsRemove", string.format("-%d", removed) },
  }

  for idx, token in ipairs(tokens) do
    out[#out + 1] = string.format("%%#%s#%s", token[1], esc(token[2]))
    if idx < #tokens then
      out[#out + 1] = "%#StDiffTotalsBase# "
    end
  end

  out[#out + 1] = "%#StDiffTotalsBase# "
  return table.concat(out)
end

function M.set_highlights()
  local p = pal.get()
  local lighten = pal.lighten
  local colors = {
    bg = p.bg0,
    text = p.fg1,
    bright = p.white,
    muted = p.bg2,
    muted_soft = p.bg3,
    blue = p.blue,
    purple = p.purple,
    red = p.red,
    yellow = p.yellow,
    green = p.green,
    aqua = p.aqua,
    orange = p.orange,
    gray = p.gray,
  }
  local diff_totals_bg = colors.bg

  local highlights = {
    StBase = { bg = colors.bg, fg = colors.text },
    StGap = { bg = colors.bg, fg = colors.bg },

    StFileIcon = { bg = colors.muted, fg = colors.bright },
    StFileInfo = { bg = lighten(colors.muted, 12, colors.muted_soft), fg = colors.bright },
    StFileRoIcon = { bg = colors.orange, fg = colors.bg },
    StFileRoInfo = { bg = lighten(colors.orange, 12, colors.orange), fg = colors.bg },

    StGitIcon = { bg = colors.blue, fg = colors.bg },
    StGitInfo = { bg = lighten(colors.blue, 12, colors.blue), fg = colors.bg },
    StGitOffIcon = { bg = colors.gray, fg = colors.bg },
    StGitOffInfo = { bg = lighten(colors.gray, 12, colors.gray), fg = colors.bg },
    StDiffAddIcon = { bg = colors.green, fg = colors.bg },
    StDiffAddInfo = { bg = lighten(colors.green, 12, colors.green), fg = colors.bg },
    StDiffChangeIcon = { bg = colors.yellow, fg = colors.bg },
    StDiffChangeInfo = { bg = lighten(colors.yellow, 12, colors.yellow), fg = colors.bg },
    StDiffRemoveIcon = { bg = colors.red, fg = colors.bg },
    StDiffRemoveInfo = { bg = lighten(colors.red, 12, colors.red), fg = colors.bg },
    StDiffTotalsBase = { bg = diff_totals_bg, fg = colors.text },
    StDiffTotalsAdd = { bg = diff_totals_bg, fg = colors.green },
    StDiffTotalsChange = { bg = diff_totals_bg, fg = colors.yellow },
    StDiffTotalsRemove = { bg = diff_totals_bg, fg = colors.red },

    StLspOnIcon = { bg = colors.green, fg = colors.bg },
    StLspOnInfo = { bg = lighten(colors.green, 12, colors.green), fg = colors.bg },
    StLspOffIcon = { bg = colors.red, fg = colors.bg },
    StLspOffInfo = { bg = lighten(colors.red, 12, colors.red), fg = colors.bg },
    StPosIcon = { bg = colors.aqua, fg = colors.bg },
    StPosInfo = { bg = lighten(colors.aqua, 12, colors.aqua), fg = colors.bg },
  }

  local mode_palette = {
    Blue = colors.blue,
    Purple = colors.purple,
    Red = colors.red,
    Yellow = colors.yellow,
    Green = colors.green,
  }

  for suffix, color in pairs(mode_palette) do
    highlights["StMode" .. suffix] = { bg = color, fg = colors.bg }
    highlights["StMode" .. suffix .. "Dim"] = { bg = lighten(color, 12, color), fg = colors.bg }
  end

  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end

function StatusLine()
  local width = get_window_width()
  local mode_data = utils.get_mode()
  local left = {}
  local right = {}

  add_block(left, icon_info_block(mode_data[3], mode_data[4], mode_data[1], mode_data[2]))

  local file_data = utils.get_file_info()
  local file_width = width >= 150 and 34 or width >= 120 and 24 or width >= 95 and 16 or 12

  local branch_data = utils.get_git_branch()
  local git_icon = (branch_data[1] or ""):gsub("%s+$", "")
  local in_git = branch_data[2] ~= "not git"
  if in_git then
    local branch_width = width >= 140 and 22 or 14
    add_block(left, icon_info_block("StGitIcon", "StGitInfo", git_icon, str_truncate(branch_data[2], branch_width)))
  else
    add_block(left, icon_info_block("StGitOffIcon", "StGitOffInfo", git_icon, get_no_git_label(width)))
  end

  add_block(left, diff_totals_block(utils.get_git_diff(), width))

  local lsp_data = utils.get_lsp_status()
  if width >= 90 then
    local lsp_width = width >= 140 and 20 or width >= 110 and 14 or 10
    add_block(right, icon_info_block(lsp_data[3], lsp_data[4], lsp_data[1], str_truncate(lsp_data[2], lsp_width)))
  end

  add_block(right, icon_info_block("StFileIcon", "StFileInfo", file_data.icon, str_truncate(file_data.name, file_width)))

  add_block(right, icon_info_block("StPosIcon", "StPosInfo", "", utils.get_line_total()))

  local left_side = join_blocks(left)
  local right_side = join_blocks(right)
  return table.concat({
    left_side,
    "%#StBase#%=",
    right_side,
    "%#StBase# ",
  })
end

M.set_highlights()

function M.init(x)
  setup_refresh_autocmds()

  local pos = x or "bottom"
  if pos == "top" then
    vim.opt.ls = 0
    vim.opt.winbar = '%!v:lua.StatusLine()'
  elseif pos == "bottom" then
    vim.opt.ls = 3
    vim.opt.statusline = '%!v:lua.StatusLine()'
  else
    error("chose 'top' or 'bottom'", 2)
  end

  vim.schedule(redraw_statusline)
end

return M
