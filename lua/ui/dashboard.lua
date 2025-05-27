local M = {}

local logo = {
	"⠤⠤⠤⠤⠤⠤⢤⣄⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠒⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠤⠶⠶⠶⠦⠤⠤⠤⠤⠤⢤⣤⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⢀⠄⢂⣠⣭⣭⣕⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠀⠀⠀⠤⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠉⠉⠉⠉",
	"⠀⠀⢀⠜⣳⣾⡿⠛⣿⣿⣿⣦⡠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣤⣤⣤⣤⣤⣤⣤⣤⣤⣍⣀⣦⠦⠄⣀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠠⣄⣽⣿⠋⠀⡰⢿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⡿⠛⠛⡿⠿⣿⣿⣿⣿⣿⣿⣷⣶⣿⣁⣂⣤⡄⠀⠀⠀⠀⠀⠀",
	"⢳⣶⣼⣿⠃⠀⢀⠧⠤⢜⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠟⠁⠀⠀⠀⡇⠀⣀⡈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠁⠐⠀⣀⠀⠀",
	"⠀⠙⠻⣿⠀⠀⠀⠀⠀⠀⢹⣿⣿⡝⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡿⠋⠀⠀⠀⠀⠠⠃⠁⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣿⡿⠋⠀⠀",
	"⠀⠀⠀⠙⡄⠀⠀⠀⠀⠀⢸⣿⣿⡃⢼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⡏⠉⠉⠻⣿⡿⠋⠀⠀⠀⠀",
	"⠀⠀⠀⠀⢰⠀⠀⠰⡒⠊⠻⠿⠋⠐⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠀⠀⠀⠀⣿⠇⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠸⣇⡀⠀⠑⢄⠀⠀⠀⡠⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢖⠠⠤⠤⠔⠙⠻⠿⠋⠱⡑⢄⠀⢠⠟⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠈⠉⠒⠒⠻⠶⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠀⠀⠀⠀⠀⠀⠀⠡⢀⡵⠃⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠦⣀⠀⠀⠀⠀⠀⢀⣤⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠉⠙⠛⠓⠒⠲⠿⢍⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
}

local buttons = {
	{ "  Find File", "󱁐 ff", "Telescope find_files" },
	{
		"  Configuration",
		"󱁐 c",
		[[lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") })]],
	},
	{ "󰒲  Lazy", "󱁐 pS", "Lazy show" },
	{ "  Quit", "󱁐 q", "q" },
}

-- Store button line numbers for navigation
local button_lines = {}
local current_button = 1

-- Adds spacing between the left and right parts of a button line
local function format_button_line(label, keybind, width)
	local total_len = fn.strwidth(label .. keybind)
	local padding = width - total_len - 1
	return label .. string.rep(" ", padding) .. keybind .. " "
end

-- Pads the line horizontally to center it
local function center_line(line, total_width)
	local pad = math.floor((total_width - fn.strwidth(line)) / 2)
	return string.rep(" ", pad) .. line
end

-- Navigate to specific button
local function goto_button(buf, button_index)
	if button_index < 1 or button_index > #buttons then
		return
	end

	current_button = button_index
	local line_num = button_lines[button_index]
	if line_num then
		-- Get the line content to find cursor position
		local line_content = api.nvim_buf_get_lines(buf, line_num - 1, line_num, false)[1] or ""
		local button_text = buttons[button_index][1]

		-- Find the position of the last word in the button text
		local last_word = button_text:match(".*%s+(.-)%s*$") or button_text:match("^%s*(.-)%s*$")
		if last_word then
			local start_pos = line_content:find(last_word, 1, true)
			if start_pos then
				-- Position cursor at the end of the last word
				local cursor_col = start_pos + #last_word - 1
				api.nvim_win_set_cursor(0, { line_num, cursor_col })
			else
				api.nvim_win_set_cursor(0, { line_num, 0 })
			end
		else
			api.nvim_win_set_cursor(0, { line_num, 0 })
		end
	end
end

-- Navigate to next button
local function next_button(buf)
	local next_idx = current_button + 1
	if next_idx > #buttons then
		next_idx = 1
	end
	goto_button(buf, next_idx)
end

-- Navigate to previous button
local function prev_button(buf)
	local prev_idx = current_button - 1
	if prev_idx < 1 then
		prev_idx = #buttons
	end
	goto_button(buf, prev_idx)
end

-- Execute current button command
local function execute_current_button()
	local cmd = buttons[current_button][3]
	vim.cmd(cmd)
end

-- Generate dashboard content
local function generate_content(win_width, win_height)
	local content = {}
	local logo_width = fn.strwidth(logo[1])
	button_lines = {}

	-- Calculate total content height (logo + buttons + spacing)
	local total_content_height = #logo + 5 + (#buttons * 2) -- logo + 1 space + buttons with spacing

	-- Calculate vertical centering
	local vertical_offset = math.max(0, math.floor((win_height - total_content_height) / 2))

	-- Add top padding for vertical centering
	for _ = 1, vertical_offset do
		table.insert(content, "")
	end

	-- Add logo
	for _, line in ipairs(logo) do
		table.insert(content, center_line(line, win_width))
	end

	-- Add spacing after logo
	for _ = 1, 5 do
		table.insert(content, "")
	end

	-- Add buttons and track their line numbers
	for i, btn in ipairs(buttons) do
		table.insert(content, center_line(format_button_line(btn[1], btn[2], logo_width), win_width))
		button_lines[i] = #content
		table.insert(content, "")
	end

	return content
end

-- Update dashboard content
local function update_dashboard(buf, win)
	if not api.nvim_buf_is_valid(buf) or not api.nvim_win_is_valid(win) then
		return
	end

	local win_width = api.nvim_win_get_width(win)
	local win_height = api.nvim_win_get_height(win)

	-- Temporarily make buffer modifiable
	vim.bo[buf].modifiable = true

	-- Generate new content
	local content = generate_content(win_width, win_height)

	-- Update buffer content
	api.nvim_buf_set_lines(buf, 0, -1, false, content)

	-- Make buffer non-modifiable again
	vim.bo[buf].modifiable = false

	-- Restore cursor to current button
	goto_button(buf, current_button)
end

function M.setup()
	if #vim.fn.argv() > 0 then
		return
	end

	local buf = api.nvim_create_buf(false, true)
	local win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, buf)

	-- Set buffer options
	vim.opt_local.modifiable = true
	vim.opt_local.buflisted = false
	vim.opt_local.swapfile = false
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.cursorline = false -- Disable cursorline highlight
	vim.opt_local.signcolumn = "no"
	vim.opt_local.foldcolumn = "0"
	vim.opt_local.list = false
	vim.opt_local.wrap = false
	vim.opt_local.colorcolumn = ""
	vim.opt_local.statuscolumn = ""

	-- Initial content generation
	local win_width = api.nvim_win_get_width(win)
	local win_height = api.nvim_win_get_height(win)
	local content = generate_content(win_width, win_height)

	api.nvim_buf_set_lines(buf, 0, -1, false, content)
	vim.opt_local.modifiable = false

	-- Set cursor to first button
	goto_button(buf, 1)

	-- Set up navigation keybinds
	local keymaps = {
		-- Navigation
		{
			"j",
			function()
				next_button(buf)
			end,
		},
		{
			"<Down>",
			function()
				next_button(buf)
			end,
		},
		{
			"k",
			function()
				prev_button(buf)
			end,
		},
		{
			"<Up>",
			function()
				prev_button(buf)
			end,
		},
		{
			"<Tab>",
			function()
				next_button(buf)
			end,
		},
		{
			"<S-Tab>",
			function()
				prev_button(buf)
			end,
		},

		-- Execute current button
		{ "<CR>",    execute_current_button },
		{ "<Space>", execute_current_button },

		-- Direct button access (original shortcuts still work)
		{
			"ff",
			function()
				vim.cmd("Telescope find_files")
			end,
		},
		{
			"c",
			function()
				require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
			end,
		},

		{
			"pS",
			function()
				vim.cmd("Lazy show")
			end,
		},
		{
			"q",
			function()
				vim.cmd("q")
			end,
		},

		-- Disable other movements to keep cursor on buttons
		{ "h",       function() end },
		{ "l",       function() end },
		{ "<Left>",  function() end },
		{ "<Right>", function() end },
		{
			"gg",
			function()
				goto_button(buf, 1)
			end,
		},
		{
			"G",
			function()
				goto_button(buf, #buttons)
			end,
		},
	}

	for _, keymap in ipairs(keymaps) do
		vim.keymap.set("n", keymap[1], keymap[2], { buffer = buf, silent = true })
	end

	-- Set up autocommands
	local group = api.nvim_create_augroup("Dashboard", { clear = true })

	-- Handle window resize with debouncing
	api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
		group = group,
		callback = function()
			if api.nvim_get_current_buf() == buf then
				vim.defer_fn(function()
					update_dashboard(buf, win)
				end, 10)
			end
		end,
	})
end

return M
