local M = {}

local has_devicons, devicons = pcall(require, "nvim-web-devicons")

local function setup_highlights()
	vim.api.nvim_set_hl(0, "BufferActive", { fg = "#E9E9EA", bg = "NONE", bold = true })
	vim.api.nvim_set_hl(0, "BufferInactive", { fg = "#E9E9EA", bg = "NONE" })
	vim.api.nvim_set_hl(0, "BufferModified", { fg = "#E9E9EA", bg = "NONE" })
end

-- Get valid listed buffers with names
local function get_valid_buffers()
	local bufs = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
				vim.api.nvim_buf_is_valid(buf)
				and vim.api.nvim_buf_is_loaded(buf)
				and vim.bo[buf].buflisted
				and vim.api.nvim_buf_get_name(buf) ~= ""
		then
			table.insert(bufs, buf)
		end
	end
	return bufs
end

-- Avoid filename duplicates
local function get_unique_filename(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return "[No Name]"
	end

	local base = vim.fn.fnamemodify(name, ":t")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= bufnr and vim.api.nvim_buf_is_valid(buf) then
			local other = vim.api.nvim_buf_get_name(buf)
			if vim.fn.fnamemodify(other, ":t") == base then
				local parent = vim.fn.fnamemodify(name, ":p:h:t")
				return parent .. "/" .. base
			end
		end
	end
	return base
end

-- Build individual tab
local function create_buffer_tab(bufnr)
	local current = vim.api.nvim_get_current_buf()
	local name = get_unique_filename(bufnr)
	local modified = vim.bo[bufnr].modified
	local hl = (bufnr == current) and "%#BufferActive#" or "%#BufferInactive#"

	-- Icon
	local icon = ""
	if has_devicons and name ~= "[No Name]" then
		local file_icon = devicons.get_icon(name)
		icon = file_icon or ""
	end

	-- Modified or close icon
	local right = modified and "%#BufferModified#●" or "%" .. bufnr .. "@BuflineClose@×%X"

	return "%" .. bufnr .. "@BuflineGoto@" .. hl .. "   " .. icon .. "  " .. name .. "  " .. right .. "   " .. "%X"
end

-- Generate full tabline
M.get_tabline = function()
	local tabs = {}
	for _, buf in ipairs(get_valid_buffers()) do
		table.insert(tabs, create_buffer_tab(buf))
	end
	return table.concat(tabs, "") .. "%#TabLineFill#"
end

-- Navigate buffers
local function switch_buffer(forward)
	local bufs = get_valid_buffers()
	local current = vim.api.nvim_get_current_buf()
	if #bufs <= 1 then
		return
	end

	for i, buf in ipairs(bufs) do
		if buf == current then
			local target = bufs[(i + (forward and 1 or -1) - 1) % #bufs + 1]
			vim.cmd("buffer " .. target)
			break
		end
	end
end

-- Close buffer
M.close_buffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local bufs = get_valid_buffers()
	local is_terminal = vim.bo[bufnr].buftype == "terminal"

	-- Confirm before force-killing a terminal buffer
	if is_terminal then
		local confirm = vim.fn.confirm("Kill terminal buffer?", "&Yes\n&No", 2)
		if confirm ~= 1 then
			return -- User chose "No"
		end
	end

	-- Switch if it's the current buffer, more than one buffer exists, and it's not a terminal
	if bufnr == vim.api.nvim_get_current_buf() and #bufs > 1 and not is_terminal then
		vim.schedule(function()
			switch_buffer(false)
		end)
	end

	local cmd = is_terminal and "bdelete!" or "bdelete"
	vim.cmd(cmd .. " " .. bufnr)
end

-- Swap buffer between current and adjacent window
local function swap_buffers()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()

	-- Try to get the next window in the layout
	vim.cmd("wincmd w") -- cycle to next window
	local other_win = vim.api.nvim_get_current_win()
	local other_buf = vim.api.nvim_get_current_buf()

	if current_win == other_win then
		vim.notify("No other window to swap with.", vim.log.levels.WARN)
		return
	end

	-- Swap the buffers
	vim.api.nvim_win_set_buf(current_win, other_buf)
	vim.api.nvim_win_set_buf(other_win, current_buf)

	-- Return to original window
	vim.api.nvim_set_current_win(current_win)
end

-- Setup function
M.setup = function()
	setup_highlights()

	vim.cmd([[
		function! BuflineGoto(bufnr, clicks, button, modifiers)
			execute 'buffer ' . a:bufnr
		endfunction

		function! BuflineClose(bufnr, clicks, button, modifiers)
			lua require('ui.buf').close_buffer(tonumber(a:bufnr))
		endfunction
	]])

	vim.api.nvim_create_user_command("BufferNext", function()
		switch_buffer(true)
	end, {})
	vim.api.nvim_create_user_command("BufferPrev", function()
		switch_buffer(false)
	end, {})
	vim.api.nvim_create_user_command("BufferClose", function()
		M.close_buffer()
	end, {})

	vim.keymap.set("n", "<Tab>", ":BufferNext<CR>", { silent = true })
	vim.keymap.set("n", "<S-Tab>", ":BufferPrev<CR>", { silent = true })
	vim.keymap.set("n", "<leader>bd", ":BufferClose<CR>", { silent = true })
	vim.keymap.set("n", "<leader>sw", swap_buffers, { noremap = true, silent = true }) -- swap window buffers

	vim.o.showtabline = 2
	vim.o.tabline = '%!v:lua.require("ui.buf").get_tabline()'
end

return M
