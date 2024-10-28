local M = {}

-- Define colors
local colors = {
	bg = '#000000',
	fg = '#ffffff',
	gray1 = '#d0d0d0',
	gray2 = '#a0a0a0',
	gray3 = '#707070',
	gray4 = '#404040',
	gray5 = '#202020',
}

-- Define highlight groups
local groups = {
	-- Editor
	Normal = { fg = colors.fg, bg = colors.bg },
	LineNr = { fg = colors.gray3 },
	CursorLine = { bg = colors.gray5 },
	CursorLineNr = { fg = colors.gray1 },
	SignColumn = { bg = colors.bg },
	VertSplit = { fg = colors.gray4, bg = colors.bg },
	StatusLine = { fg = colors.gray1, bg = colors.gray5 },
	StatusLineNC = { fg = colors.gray3, bg = colors.gray5 },

	-- Syntax
	Comment = { fg = colors.gray3 },
	Constant = { fg = colors.gray1 },
	String = { fg = colors.gray2 },
	Identifier = { fg = colors.gray1 },
	Function = { fg = colors.fg },
	Statement = { fg = colors.fg },
	PreProc = { fg = colors.gray1 },
	Type = { fg = colors.fg },
	Special = { fg = colors.gray1 },

	-- Search and Selection
	Search = { fg = colors.bg, bg = colors.gray2 },
	IncSearch = { fg = colors.bg, bg = colors.gray1 },
	Visual = { bg = colors.gray4 },

	-- Pmenu (completion menu)
	Pmenu = { fg = colors.gray1, bg = colors.gray5 },
	PmenuSel = { fg = colors.fg, bg = colors.gray4 },
	PmenuSbar = { bg = colors.gray4 },
	PmenuThumb = { bg = colors.gray3 },
}

function M.setup()
	-- Clear existing highlighting
	vim.cmd('highlight clear')
	if vim.fn.exists('syntax_on') then
		vim.cmd('syntax reset')
	end

	-- Set background and colorscheme name
	vim.o.background = 'dark'
	vim.g.colors_name = 'mc'

	-- Set highlight groups
	for group, settings in pairs(groups) do
		vim.api.nvim_set_hl(0, group, settings)
	end
end

return M
