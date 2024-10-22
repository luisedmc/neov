local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Select All / Copy / Paste / Cut / Undo
map({ "n", "v", "i" }, "<C-a>", "<ESC>ggVG", opts)
map("v", "<C-c>", "y", opts)
map({ "n", "i" }, "<C-v>", "<ESC>pa", opts)
map({ "n", "v" }, "<C-x>", "d", opts)
map({ "n", "v", "i" }, "<C-z>", "<cmd>undo<CR>", opts)

-- Moving Between Buffers | Normal
map("n", "<C-h>", "<C-w>h", opts, { desc = "Move Cursor Left Buffer" })
map("n", "<C-j>", "<C-w>j", opts, { desc = "Move Cursor Down Buffer" })
map("n", "<C-k>", "<C-w>k", opts, { desc = "Move Cursor Up Buffer" })
map("n", "<C-l>", "<C-w>l", opts, { desc = "Move Cursor Right Buffer" })

-- ToggleTerm | Normal
map('n', '<C-`>', ':ToggleTerm<CR>', opts)

-- CommentToggle | Normal, Visual
map({ 'n', 'v' }, '<C-/>', ':CommentToggle<CR>', opts)

-- Telescope | Normal, Visual
map({ "n", "v" }, "<Leader>ff", "<cmd>Telescope find_files<CR>", opts)
map({ "n", "v" }, "<Leader>fr", "<cmd>Telescope oldfiles<CR>", opts)
map({ "n", "v" }, "<Leader>fp", "<cmd>Telescope live_grep<CR>", opts)

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Go to first character in line
vim.keymap.set('', '<leader>h', '^')

-- Close buffer
vim.keymap.set('n', '<leader>w', '<cmd>bdelete<cr>')

-- Open file explorer
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>')

-- Show diagnostic message
vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<cr>')

-- New keymaps for switching buffers with Ctrl + number
for i = 1, 9 do
	vim.keymap.set('n', string.format('<C-%d>', i), function()
		local bufs = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_valid(buf)
					and vim.bo[buf].buflisted
					and vim.api.nvim_buf_get_name(buf) ~= ''
		end, vim.api.nvim_list_bufs())

		if i <= #bufs then
			vim.api.nvim_set_current_buf(bufs[i])
		end
	end, opts)
end
