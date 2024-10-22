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

		return " " .. branch
	end

	return " no branch"
end
