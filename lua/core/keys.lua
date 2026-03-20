local function map(mode, keys, command)
	vim.keymap.set(mode, keys, command, { noremap = true, silent = true })
end

local function toggle_terminal()
	if type(_G.toggle_float_terminal) ~= "function" then
		pcall(require, "ui.terminal.terminal")
	end

	if type(_G.toggle_float_terminal) == "function" then
		_G.toggle_float_terminal()
	end
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

-- lsp
map({ "n", "v" }, "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>")

-- indent/outdent in visual mode with Tab / Shift-Tab
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

-- telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fp", "<cmd>Telescope live_grep<cr>")
map("n", "/", function()
	require("ui.search.search").show_floating_search()
end)

-- documentation
map("n", "gK", function() require("ui.docs.docs").open_doc() end)
map("n", "<leader>fd", function() vim.schedule(function() require("ui.docs.docs").search_docs() end) end)
map("n", "<leader>fs", function() require("ui.docs.docs").show_symbol_signature() end)

-- toggle terminal
map("n", "<C-j>", toggle_terminal)
map("t", "<C-j>", function()
	vim.cmd("stopinsert")
	toggle_terminal()
end)

-- toggle diagnostics in-line
map("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

-- window resize
map({ "n", "t" }, "<C-[>", "<C-w>5<")
map({ "n", "t" }, "<C-]>", "<C-w>5>")

map({ "n", "v" }, "<leader>wv", "<C-w>v")
map({ "n", "v" }, "<leader>wh", "<C-w>s")
map({ "n", "v" }, "<leader>we", "<C-w>=")
map({ "n", "v" }, "<leader>wq", "<cmd>close<cr>")


map("t", "<esc>", [[<C-\><C-n>]])

-- move line
map("n", "<A-j>", "<cmd>m +1<cr>==")
map("n", "<A-k>", "<cmd>m -2<cr>==")
map("i", "<A-j>", "<esc><cmd>m +1<cr>==gi")
map("i", "<A-k>", "<esc><cmd>m -2<cr>==gi")

-- move block (visual)
map("v", "<A-j>", ":m '>+1<CR>gv=gv")
map("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- change buffer with <C-1,9>
for i = 1, 9 do
	map({ "n", "t" }, string.format("<C-%d>", i), function()
		local bufs = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
		end, vim.api.nvim_list_bufs())

		if i <= #bufs then
			local target_buf = bufs[i]
			local buf_name = vim.api.nvim_buf_get_name(target_buf)

			for _, win in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(win) == target_buf then
					vim.api.nvim_set_current_win(win)

					if buf_name:match("^term://") then
						vim.defer_fn(function()
							vim.cmd("startinsert")
						end, 30)
					end

					return
				end
			end

			if buf_name:match("^term://") then
				vim.cmd("stopinsert")
				vim.defer_fn(function()
					toggle_terminal()
					vim.defer_fn(function()
						vim.cmd("startinsert")
					end, 30)
				end, 20)
				return
			end

			vim.api.nvim_set_current_buf(target_buf)
		end
	end)
end
