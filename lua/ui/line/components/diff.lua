local M = {}

local function format_count(count, symbol)
	return count and (symbol .. count) or ""
end

local function get_git_status()
	if not vim.b.gitsigns_status_dict then
		return nil
	end
	return vim.b.gitsigns_status_dict
end

function M.get_diff_component(style)
	local git_status = get_git_status()
	if not git_status then
		return ""
	end

	local added = format_count(git_status.added, "+")
	local changed = format_count(git_status.changed, "~")
	local removed = format_count(git_status.removed, "-")

	if style == 'blocks' then
		return added .. changed .. removed
	elseif style == 'fancy' then
		return added .. " " .. changed .. " " .. removed
	elseif style == 'minimal' then
		return added .. changed .. removed
	else
		return "F"
	end
end

return M
