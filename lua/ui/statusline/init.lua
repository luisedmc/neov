require("ui.statusline.components.mode")
require("ui.statusline.components.branch")
require("ui.statusline.components.diagnostics")
require("ui.statusline.components.saved")
require("ui.statusline.components.file")

require("ui.statusline.utils")
require("ui.statusline.colors")

function status_line()
  local mode = get_mode_component()
  local branch = get_branch_component()
  local file = get_file_component()
  local errors = get_errors_component()
  local warnings = get_warnings_component()
  local infos = get_infos_component()
  local saved = get_saved_component()

  return table.concat({
    get_component("StatusMode", mode),
    get_component("StatusBranch", branch),
    get_component("StatusFile", file),
    get_component_separator(),
    get_component("StatusSaved", saved),
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