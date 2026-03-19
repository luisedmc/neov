return {
	{ "nvim-tree/nvim-web-devicons", opts = {} },
	{
		"numToStr/Comment.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "TSInstall", "TSUninstall", "TSUpdate", "TSInfo" },
		build = ":TSUpdate",
		init = function()
			vim.treesitter.language.register("tsx", "typescriptreact")
			vim.treesitter.language.register("javascript", "javascriptreact")
			vim.treesitter.language.register("php", "phtml")
		end,
		opts = function()
			return require("plugins.cfgs.treesitter")
		end,
		config = function(_, opts)
			local treesitter = require("nvim-treesitter")
			local has_ui = #vim.api.nvim_list_uis() > 0

			-- Parser/query manager setup for the current nvim-treesitter API.
			treesitter.setup()
			if has_ui and opts.ensure_installed and #opts.ensure_installed > 0 then
				local installed = {}
				for _, lang in ipairs(treesitter.get_installed()) do
					installed[lang] = true
				end
				local missing = vim.tbl_filter(function(lang)
					return not installed[lang]
				end, opts.ensure_installed)
				if #missing > 0 then
					local ok, task = pcall(treesitter.install, missing, { summary = false })
					if ok and task and opts.sync_install then
						pcall(task.wait, task)
					end
				end
			end

			local available = {}
			for _, lang in ipairs(treesitter.get_available()) do
				available[lang] = true
			end

			local installing = {}
			local function start_treesitter(bufnr)
				if vim.bo[bufnr].buftype ~= "" then
					return
				end

				local ft = vim.bo[bufnr].filetype
				if ft == "" then
					return
				end

				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then
					return
				end

				local parser_ok = vim.treesitter.language.add(lang)
				if parser_ok then
					pcall(vim.treesitter.start, bufnr, lang)
					if opts.highlight.additional_vim_regex_highlighting then
						vim.bo[bufnr].syntax = "on"
					end
					return
				end

				if not opts.auto_install or not has_ui or not available[lang] or installing[lang] then
					return
				end

				installing[lang] = true
				local ok, task = pcall(treesitter.install, lang, { summary = false })
				if not ok or not task then
					installing[lang] = nil
					return
				end

				if opts.sync_install then
					pcall(task.wait, task)
				end

				task:await(function()
					installing[lang] = nil
					vim.schedule(function()
						if not vim.api.nvim_buf_is_valid(bufnr) then
							return
						end
						local retry_ok = vim.treesitter.language.add(lang)
						if retry_ok then
							pcall(vim.treesitter.start, bufnr, lang)
							if opts.highlight.additional_vim_regex_highlighting then
								vim.bo[bufnr].syntax = "on"
							end
						end
					end)
				end)
			end

			if opts.highlight and opts.highlight.enable then
				local group = vim.api.nvim_create_augroup("core-treesitter-highlight", { clear = true })
				vim.api.nvim_create_autocmd("FileType", {
					group = group,
					callback = function(args)
						start_treesitter(args.buf)
					end,
				})

				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(bufnr) then
						start_treesitter(bufnr)
					end
				end
			end

			vim.api.nvim_create_user_command("TSInfo", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local ft = vim.bo[bufnr].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				local parser_ok = lang and vim.treesitter.language.add(lang) or false
				local highlighter_ok = vim.treesitter.highlighter.active[bufnr] ~= nil
				local installed = treesitter.get_installed()
				table.sort(installed)

				vim.notify(
					table.concat({
						"buffer: " .. bufnr,
						"filetype: " .. (ft ~= "" and ft or "<none>"),
						"language: " .. (lang or "<none>"),
						"parser loaded: " .. tostring(parser_ok),
						"highlighter active: " .. tostring(highlighter_ok),
						"installed parsers: " .. table.concat(installed, ", "),
					}, "\n"),
					vim.log.levels.INFO,
					{ title = "Treesitter Info" }
				)
			end, { desc = "Show Treesitter state for current buffer", force = true })
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = function()
			return require("plugins.cfgs.telescope")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
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
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("plugins.cfgs.conform")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "BufReadPost" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"xzbdmw/colorful-menu.nvim",
		},
		config = function()
			require("plugins.cfgs.cmp")
		end,
	},
	{
		"saghen/blink.cmp",
		enabled = false, -- Flip to `true` to switch back to Blink.
		event = { "InsertEnter", "BufReadPost" },
		dependencies = {
			{ "L3MON4D3/LuaSnip", version = "v2.*" },
		},
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
						transform_items = function(ctx, items)
							local keyword = ctx.get_keyword()
							local correct
							local case

							if keyword:match("^%l") then
								correct = "^%u%l+$"
								case = string.lower
							elseif keyword:match("^%u") then
								correct = "^%l+$"
								case = string.upper
							else
								return items
							end

							local seen = {}
							local out = {}
							for _, item in ipairs(items) do
								local raw = item.insertText
								if raw and raw:match(correct) then
									local text = case(raw:sub(1, 1)) .. raw:sub(2)
									item.insertText = text
									item.label = text
								end

								if item.insertText and not seen[item.insertText] then
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
				implementation = "lua",
				prebuilt_binaries = { download = false },
			},
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},
	{
		"neovim/nvim-lspconfig",
		-- dependencies = { "saghen/blink.cmp" }, -- Blink path
		dependencies = { "hrsh7th/cmp-nvim-lsp" }, -- nvim-cmp path
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			servers = require("lsp.servers"),
		},
		config = function(_, opts)
			require("lsp").setup_servers(opts.servers)
		end,
	},
	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",
		keys = {
			{
				"<C-f>",
				function()
					require("multicursor-nvim").matchAddCursor(1)
				end,
				mode = { "n", "x" },
				desc = "Multicursor: Add next match",
			},
		},
			config = function()
				local mc = require("multicursor-nvim")
				mc.setup()

				mc.addKeymapLayer(function(layerSet)
					local function exit_multicursor()
						if not mc.cursorsEnabled() then
							mc.enableCursors()
						else
							mc.clearCursors()
						end
					end

					layerSet("n", "<esc>", exit_multicursor)
					layerSet("n", "<C-c>", exit_multicursor)
				end)
			end,
		},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
}
