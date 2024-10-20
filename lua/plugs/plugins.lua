return {
	{
		'goolord/alpha-nvim',
		event = "VimEnter",
		lazy = true,
		config = function()
			require("plugs.ui.alpha")
		end
	},
	{
		"nvim-lua/plenary.nvim",
	},
	{
		"MunifTanjim/nui.nvim",
	},
	{
		"nvim-tree/nvim-web-devicons",
		event = "BufRead",
		opts = function()
			require("nvim-web-devicons").set_default_icon("󰈚")
			return require("plugs.configs.devicons")
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		run = ":TSUpdate",
		lazy = true,
		cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
		config = function() require('plugs.ts.treesitter') end
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"echasnovski/mini.indentscope",
				opts = { symbol = "│" },
			},
		},
		opts = function()
			return require("plugs.configs.blankline")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		opts = function()
			return require("plugs.configs.telescope")
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		lazy = true,
		config = function()
			require('plugs.configs.toggleterm')
		end,
	},
	{
		"terrortylor/nvim-comment",
		config = function()
			require('nvim_comment').setup({ create_mappings = false })
		end
	},
	{
		'xiyaowong/transparent.nvim',
		lazy = false,
		priority = 999,
	},
	{
		'kdheepak/monochrome.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd 'colorscheme monochrome'
		end
	},

	--------------------------------------------------------------

	{
		"L3MON4D3/LuaSnip",
		version = "2.*",
		build = "make install_jsregexp"
	},
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			return require('plugs.lsp.mason')
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			return require('plugs.lsp.cmp')
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		version = "4.x",
		priority = 900,
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			return require('plugs.lsp.lsp-zero')
		end,
	}
}
