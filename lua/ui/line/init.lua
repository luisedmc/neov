require("ui.line.components.mode")
require("ui.line.components.branch")
require("ui.line.components.diagnostics")
require("ui.line.components.file")
require("ui.line.components.lsp")
require("ui.line.components.position")
local diff = require("ui.line.components.diff")

require("ui.line.utils")
require("ui.line.colors")

function status_line()
	local mode        = get_mode_component()
	local branch      = get_branch_component()
	local file        = get_file_component()
	local errors      = get_errors_component()
	local warnings    = get_warnings_component()
	local infos       = get_infos_component()
	local lsp         = get_lsp_client()
	local diff_status = diff.get_diff_component('minimal')
	local position    = get_position_component()

	return table.concat({
		get_component("StatusMode", mode),
		get_component("StatusBranch", branch),
		get_component("StatusDiff", diff_status),
		get_component("StatusFile", file),
		get_component_separator(),
		get_component("LSP", lsp),
		get_component("StatusErrors", errors),
		get_component("StatusWarnings", warnings),
		get_component("StatusInfos", infos),
		get_component("Position", position),
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
