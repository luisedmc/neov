require("ui.stl.components.mode")
require("ui.stl.components.branch")
require("ui.stl.components.diagnostics")
require("ui.stl.components.saved")
require("ui.stl.components.file")
require("ui.stl.components.lsp")
local diff = require('ui.stl.components.diff')

require("ui.stl.utils")
require("ui.stl.colors")

function status_line()
  local mode = get_mode_component()
  local branch = get_branch_component()
  local file = get_file_component()
  local errors = get_errors_component()
  local warnings = get_warnings_component()
  local infos = get_infos_component()
  local saved = get_saved_component()
  local lsp = get_lsp_client()
  local diff_status = diff.get_diff_component('minimal')  -- Add this line

  return table.concat({
    get_component("StatusMode", mode),
    get_component("StatusBranch", branch),
    get_component("StatusDiff", diff_status),  -- Add this line
    get_component("StatusFile", file),
    get_component_separator(),
    get_component("StatusSaved", saved),
    get_component("LSP", lsp),
    get_component("StatusErrors", errors),
    get_component("StatusWarnings", warnings),
    get_component("StatusInfos", infos),
  })
end

vim.o.laststatus = 3

vim.cmd([[
  augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.status_line()
    au WinLeave,BufLeave * setlocal statusline=%!v:lua.status_line()
    au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.status_line()
  augroup END
]])