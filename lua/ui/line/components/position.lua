function get_position_component()
	local current = vim.fn.line('.')
	local total = vim.fn.line('$')

	-- Format: "current/total"
	return current .. "|" .. total
end
