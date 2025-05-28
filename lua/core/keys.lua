require("ui.terminal")

local function map(mode, keys, command)
	vim.keymap.set(mode, keys, command, { noremap = true, silent = true })
end

-- select all / copy / paste / cut / undo
map({ "n", "v", "i" }, "<C-a>", "<ESC>ggVG")
map({ "v" }, "<C-c>", "y")
map({ "n", "i" }, "<C-v>", "<ESC>pa")
map({ "n", "v" }, "<C-x>", "d")
map({ "n", "v", "i" }, "<C-z>", "<cmd>undo<cr>")

-- buffer
map("n", "<leader>s", "<cmd>w<cr>")
map("n", "<leader>t", "<cmd>enew<cr>")

-- comments
map("n", "<C-/>", "<plug>(comment_toggle_linewise_current)")
map("v", "<C-/>", "<plug>(comment_toggle_linewise_visual)")

-- esc -> qq
map({ "i", "v" }, "qq", "<esc>")

-- keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- indent/outdent in visual mode with Tab / Shift-Tab
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fp", "<cmd>Telescope live_grep<cr>")

-- toggle terminal
map("n", "<C-`>", ToggleTerminal)
map("t", "<C-`>", [[<C-\><C-n>:lua ToggleTerminal()<CR>]])

-- toggle diagnostics in-line
map("n", "<C-j>", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, noremap = true })

-- window resize
map({ "n", "t" }, "<C-h>", "<C-w>5<")
map({ "n", "t" }, "<C-l>", "<C-w>5>")

-- change buffer with <C-1,9>
for i = 1, 9 do
	vim.keymap.set({ "n", "t" }, string.format("<C-%d>", i), function()
		local bufs = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
		end, vim.api.nvim_list_bufs())

		if i <= #bufs then
			local target_buf = bufs[i]
			local buf_name = vim.api.nvim_buf_get_name(target_buf)

			-- Try to find the window showing this buffer
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == target_buf then
					vim.api.nvim_set_current_win(win)

					-- If it's a terminal, enter insert mode
					if buf_name:match("^term://") then
						vim.defer_fn(function()
							vim.cmd("startinsert")
						end, 30)
					end

					return
				end
			end

			-- Buffer not visible — handle terminal specially
			if buf_name:match("^term://") then
				vim.cmd("stopinsert")
				vim.defer_fn(function()
					_G.toggle_terminal()
					vim.defer_fn(function()
						vim.cmd("startinsert")
					end, 30)
				end, 20)
				return
			end

			-- Fallback for normal buffers
			vim.api.nvim_set_current_buf(target_buf)
		end
	end)
end
