-- local luasnip = require("luasnip")
-- local options = {
--   history = true,
--   updateevents = "TextChanged,TextChangedI",
-- }
--
-- luasnip.config.set_config(options)
-- require("luasnip.loaders.from_vscode").lazy_load()
-- require("luasnip.loaders.from_vscode").lazy_load { paths = vim.g.luasnippets_path or "" }
--
-- vim.api.nvim_create_autocmd("InsertLeave", {
--   callback = function()
--     if
--         require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
--         and not require("luasnip").session.jump_active
--     then
--       require("luasnip").unlink_current()
--     end
--   end,
-- })
--
local luasnip = require("luasnip")

local options = {
	history = true,
	updateevents = "TextChanged,TextChangedI",
}

luasnip.config.set_config(options)

-- Load snippets
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load { paths = vim.g.luasnippets_path or "" }

-- Handle snippet jumping/expansion
local function jump_next()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	else
		-- If no snippet to expand/jump, just insert a tab
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
	end
end

local function jump_prev()
	if luasnip.jumpable(-1) then
		luasnip.jump(-1)
	end
end

-- Set keybindings
vim.keymap.set({ "i", "s" }, "<Tab>", jump_next, { silent = true })
vim.keymap.set({ "i", "s" }, "<S-Tab>", jump_prev, { silent = true })

-- Clear snippet when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		if
				luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
				and not luasnip.session.jump_active
		then
			luasnip.unlink_current()
		end
	end,
})
