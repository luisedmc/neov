local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Select all / Copy / Paste / Cut / Undo
map ({ 'n', 'v', 'i' }, '<C-a>', '<ESC>ggVG', opts)
map ({ 'v' }, '<C-c>', 'y', opts)
map ({ 'n', 'i' }, '<C-v>', '<ESC>pa', opts)
map ({ 'n', 'v' }, '<C-x>', 'd', opts)
map ({ 'n', 'v', 'i' }, '<C-z>', '<cmd>undo<CR>', opts)

-- Moving between buffers
map ({ 'n' }, '<C-h>', '<C-w>h', opts)
map ({ 'n' }, '<C-j>', '<C-w>j', opts)
map ({ 'n' }, '<C-k>', '<C-w>k', opts)
map ({ 'n' }, '<C-l>', '<C-w>l', opts)

-- ToggleTerm
map ({ 'n' }, '<C-`>', ':ToggleTerm<CR>', opts)

-- CommentToggle
map ({ 'n', 'v' }, '<C-/>', ':CommentToggle<CR>', opts)

-- Telescope
map ({ 'n', 'v' }, '<Leader>ff', '<cmd>Telescope find_files<CR>', opts)
map ({ 'n', 'v' }, '<Leader>fr', '<cmd>Telescope oldfiles<CR>', opts)
map ({ 'n', 'v' }, '<Leader>fp', '<cmd>Telescope live_grep<CR>', opts)

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Close buffer
vim.keymap.set('n', '<leader>w', '<cmd>bdelete<cr>')

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
