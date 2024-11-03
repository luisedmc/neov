return {
	{
		'goolord/alpha-nvim',
		event = "VimEnter",
		lazy = true,
		config = function()
			require("plugs.configs.alpha")
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
	-- {
	-- 	"nvim-neo-tree/neo-tree.nvim",
	-- 	cmd = "Neotree",
	-- 	keys = { { mode = { "n", "v" }, "<C-e>", "<cmd>Neotree toggle<cr>", desc = "NeoTree" } },
	-- 	commit = "8afbb06081ce1e4beb5b18945d14a608b10babeb",
	-- 	deactivate = function()
	-- 		vim.cmd([[Neotree close]])
	-- 	end,
	-- 	init = function()
	-- 		vim.g.neo_tree_remove_legacy_commands = 1
	-- 		if vim.fn.argc(-1) == 1 then
	-- 			local stat = vim.loop.fs_stat(vim.fn.argv(0))
	-- 			if stat and stat.type == "directory" then
	-- 				require("neo-tree")
	-- 			end
	-- 		end
	-- 	end,
	-- 	opts = function()
	-- 		return require("plugs.configs.neotree")
	-- 	end,
	-- },
	{ 'prichrd/netrw.nvim', opts = {} },
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
		cmd = "ToggleTerm",
		config = function()
			require("plugs.configs.toggleterm")
		end,
	},
	{
		"terrortylor/nvim-comment",
		config = function()
			require('nvim_comment').setup({ create_mappings = false })
		end
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = { "BufRead" },
		config = function()
			require("plugs.configs.gitsigns")
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
	{
		'boganworld/crackboard.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('crackboard').setup({
				session_key = '',
			})
		end,
	},

	--------------------------------------------------------------

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
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		lazy = true,
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				dependencies = "rafamadriz/friendly-snippets",
				config = function()
					require("plugs.lsp.luasnip")
				end,
			},
			{
				"windwp/nvim-autopairs",
				opts = {
					fast_wrap = {},
					disable_filetype = { "TelescopePrompt", "vim" },
				},
				event = "InsertEnter",
				lazy = true,
				config = function(_, opts)
					require("nvim-autopairs").setup(opts)

					local cmp_autopairs = require "nvim-autopairs.completion.cmp"
					require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
				end,
			},
			{
				"saadparwaiz1/cmp_luasnip",
				"hrsh7th/cmp-nvim-lua",
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
			},
		},
		config = function()
			require("plugs.lsp.cmp")
		end,
	},
}
