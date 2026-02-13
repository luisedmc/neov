-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ "nvim-tree/nvim-web-devicons", opts = {} },
		{
			"tiesen243/vercel.nvim",
			priority = 1000,
			config = function()
				require("vercel").setup({
					theme = "dark",
					transparent = true,
					italics = {
						comments = true,
						keywords = false,
						functions = false,
						strings = true,
						variables = false,
					},
				})
				vim.cmd.colorscheme("vercel")
			end,
		},
		{
			"numToStr/Comment.nvim",
			event = { "BufReadPost", "BufNewFile" },
			config = function()
				require("Comment").setup()
			end,
		},
		{
			"nvim-telescope/telescope.nvim",
			cmd = "Telescope",
			opts = function()
				return require("plugins.cfgs.telescope")
			end,
		},
		{
			"lewis6991/gitsigns.nvim",
			lazy = true,
			event = { "BufRead" },
			config = function()
				require("plugins.cfgs.gitsigns")
			end,
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
				return require("plugins.cfgs.blankline")
			end,
		},
		{
			"NvChad/nvim-colorizer.lua",
			event = "BufRead",
			config = function()
				require("plugins.cfgs.colorizer")
			end,
			lazy = true,
		},
		-- {
		-- 	"xiyaowong/transparent.nvim",
		-- 	lazy = false,
		-- 	priority = 999,
		-- },
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			opts = function()
				return require("plugins.cfgs.conform")
			end,
		},

		--

		{
			"saghen/blink.cmp",
			event = { "InsertEnter", "BufReadPost" },
			-- dependencies = { "rafamadriz/friendly-snippets" },
			dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
			build = "nix run .#build-plugin",
			opts = {
				keymap = { preset = "default" },
				snippets = { preset = "luasnip" },
				appearance = {
					nerd_font_variant = "mono",
				},

				completion = {
					accept = { auto_brackets = { enabled = true } },
					list = { selection = { preselect = true, auto_insert = true } },
					menu = {
						border = "rounded",
						draw = {
							gap = 2,
						},
					},
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 200,
						window = {
							border = "rounded",
						},
					},
					ghost_text = { enabled = true },
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						buffer = {
							-- TODO: transform completions lowercase -> uppercase and not uppercase -> lowercase
							transform_items = function(a, items)
								local keyword = a.get_keyword()
								local correct, case
								if keyword:match("^%l") then
									correct = "^%u%l+$"
									case = string.lower
								elseif keyword:match("^%u") then
									correct = "^%l+$"
									case = string.upper
								else
									return items
								end

								-- avoid duplicates from the corrections
								local seen = {}
								local out = {}
								for _, item in ipairs(items) do
									local raw = item.insertText
									if raw and raw:match(correct) then
										local text = case(raw:sub(1, 1)) .. raw:sub(2)
										item.insertText = text
										item.label = text
									end
									if not seen[item.insertText] then
										seen[item.insertText] = true
										table.insert(out, item)
									end
								end
								return out
							end,
						},
					},
				},
				fuzzy = {
					implementation = "prefer_rust_with_warning",
					prebuilt_binaries = { download = false },
				},

				signature = { enabled = true },
			},
			opts_extend = { "sources.default" },
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = { "saghen/blink.cmp" },
			event = { "BufReadPost", "BufNewFile", "BufWritePre" },
			opts = {
				servers = {
					lua_ls = {},
					clangd = {},
					gopls = {},
					pyright = {},
				},
			},
			config = function(_, opts)
				vim.diagnostic.config({
					virtual_text = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = "",
							[vim.diagnostic.severity.WARN] = "",
							[vim.diagnostic.severity.INFO] = "",
							[vim.diagnostic.severity.HINT] = "󰌶",
						},
					},
					float = {
						suffix = "",
						header = { "  Diagnostics", "String" },
						prefix = function(_, _, _)
							return "  ", "String"
						end,
					},
				})
				local lspconfig = require("lspconfig")
				for server, config in pairs(opts.servers) do
					config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
					lspconfig[server].setup(config)
				end
			end,
		},
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
	},
	install = { colorscheme = { "vercel" } },
	checker = { enabled = false },
})
