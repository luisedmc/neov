require('plugs.strap')
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugs.plugins" },
	},

	ui = {
		size = { width = 0.8, height = 0.8 },
		backdrop = 100,
		icons = {
			cmd = " ",
			config = "",
			event = "",
			ft = "",
			init = " ",
			import = " ",
			keys = " ",
			lazy = "󰂠 ",
			loaded = "",
			not_loaded = "",
			plugin = " ",
			runtime = " ",
			source = " ",
			start = "",
			task = "✔ ",
			list = { "●", "➜", "★", "‒" },
		},
		throttle = 20,
	},

	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"tohtml",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				-- "netrw",
				-- "netrwPlugin",
				-- "netrwSettings",
				-- "netrwFileHandlers",
				"matchit",
				"tar",
				"tarPlugin",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"tutor",
				"rplugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
			},
		},
	},

	install = { colorscheme = { "monochrome" } },
})
