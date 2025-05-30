local terminal_win = nil
local terminal_buf = nil
local terminal_width = nil

function ToggleTerminal()
	-- Check if terminal window exists and is valid
	if terminal_win and api.nvim_win_is_valid(terminal_win) then
		-- Save current width before closing
		terminal_width = api.nvim_win_get_width(terminal_win)
		-- Close the window but keep the buffer
		api.nvim_win_close(terminal_win, true)
		terminal_win = nil
	else
		-- Check if we have an existing terminal buffer
		if terminal_buf and api.nvim_buf_is_valid(terminal_buf) then
			-- Reuse existing terminal buffer
			cmd("vsplit")
			cmd("wincmd L") -- right side
			terminal_win = api.nvim_get_current_win()
			api.nvim_win_set_buf(terminal_win, terminal_buf)
			-- Restore saved width if we have one
			if terminal_width then
				api.nvim_win_set_width(terminal_win, terminal_width)
			end
			cmd("startinsert")
		else
			-- Create new terminal
			cmd("vsplit")
			cmd("wincmd L") -- right side
			terminal_win = api.nvim_get_current_win()
			cmd("terminal")
			terminal_buf = api.nvim_get_current_buf()
			-- Set initial width if we have a saved one
			if terminal_width then
				api.nvim_win_set_width(terminal_win, terminal_width)
			end
			cmd("startinsert")
		end
	end
end
