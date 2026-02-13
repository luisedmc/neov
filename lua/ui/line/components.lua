local M = {}

-- utils
function get_component(tag, value)
	if value == "" then
		return ""
	end

	return "%#" .. tag .. "# " .. value .. " "
end

function get_component_separator()
	return "%="
end

-- colors
local function set_hl(name, fg, opts)
	local hl = { fg = fg }
	if opts then
		for k, v in pairs(opts) do
			hl[k] = v
		end
	end
	vim.api.nvim_set_hl(0, name, hl)
end

set_hl("StatusMode", "#000000", { bold = true })
set_hl("StatusBranch", "#ffffff")
set_hl("StatusFile", "#444444")
set_hl("StatusSaved", "#adb5bd")
set_hl("StatusWarnings", "#f0c674")
set_hl("StatusErrors", "#ff9898")
set_hl("StatusInfos", "#89B4FA")
set_hl("BranchComponentStatus", "#444444")

-- branch
function get_branch_component()
	if not vim.b.gitsigns_head or vim.b.gitsigns_git_status then
		return "no branch"
	end

	local git_status = vim.b.gitsigns_status_dict

	local branch = git_status.head

	if branch ~= "" then
		if string.len(branch) > 15 then
			branch = branch:sub(1, 15) .. "..."
		end

		return " " .. branch
	end

	return " no branch"
end

-- diagnostics
function get_warnings_component()
	local warning_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	return warning_count
end

function get_errors_component()
	local error_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	return error_count
end

function get_infos_component()
	local info_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	return info_count
end

-- diff
local function format_count(count, symbol)
	return count and (symbol .. count) or ""
end

local function get_git_status()
	if not vim.b.gitsigns_status_dict then
		return nil
	end
	return vim.b.gitsigns_status_dict
end

function get_diff_component()
	local git_status = get_git_status()
	if not git_status then
		return ""
	end

	local added = format_count(git_status.added, "+")
	local changed = format_count(git_status.changed, "~")
	local removed = format_count(git_status.removed, "-")

	return added .. " " .. changed .. " " .. removed
end

-- file
function get_file_component()
	local file = vim.fn.expand("%:t")

	if file == "" then
		file = "no name"
	end

	if string.match(file, "Lexplore") then
		file = ""
	end

	return file
end

-- lsp
function get_lsp_client()
	local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
	if #buf_clients == 0 then
		return ""
	end

	local buf_client_names = {}
	for _, client in pairs(buf_clients) do
		if client.name ~= "null-ls" then
			table.insert(buf_client_names, client.name)
		end
	end

	if #buf_client_names > 0 then
		return table.concat(buf_client_names, ", ")
	else
		return ""
	end
end

-- mode
api.nvim_set_hl(0, "ModeNormal", { fg = "#78B892", bold = true })   -- green
api.nvim_set_hl(0, "ModeInsert", { fg = "#6791C9", bold = true })   -- blue
api.nvim_set_hl(0, "ModeVisual", { fg = "#F9E2AF", bold = true })   -- yellow
api.nvim_set_hl(0, "ModeReplace", { fg = "#DF5B61", bold = true })  -- red
api.nvim_set_hl(0, "ModeCommand", { fg = "#CBA6F7", bold = true })  -- purple
api.nvim_set_hl(0, "ModeTerminal", { fg = "#94E2D5", bold = true }) -- cyan
api.nvim_set_hl(0, "ModeOther", { fg = "#A6ADC8", bold = true })    -- gray

local function get_mode_group(mode)
	local groups = {
		["n"] = " ",
		["niI"] = "NORMAL i",
		["niR"] = "NORMAL r",
		["niV"] = "NORMAL v",
		["no"] = "N-PENDING",
		["i"] = " ",
		["ic"] = "INSERT (completion)",
		["ix"] = "INSERT completion",
		["t"] = "TERMINAL",
		["nt"] = "NTERMINAL",
		["v"] = " ",
		["V"] = " ",
		["Vs"] = "V-LINE (Ctrl O)",
		[""] = "V-BLOCK",
		["R"] = "REPLACE",
		["Rv"] = "V-REPLACE",
		["s"] = "SELECT",
		["S"] = "S-LINE",
		[""] = "S-BLOCK",
		["c"] = "COMMAND",
		["cv"] = "COMMAND",
		["ce"] = "COMMAND",
		["r"] = "PROMPT",
		["rm"] = "MORE",
	}
	return groups[mode] or "UNKNOWN"
end

function get_mode_component()
	local mode = vim.fn.mode()
	local mode_text = get_mode_group(mode)
	return "%#StatusLineMode#" .. mode_text
end

-- position
function get_position_component()
	local current = vim.fn.line(".")
	local total = vim.fn.line("$")
	return current .. ":" .. total
end

return M
