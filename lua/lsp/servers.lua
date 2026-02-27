local function executable(bin)
	return vim.fn.executable(bin) == 1
end

return {
	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=detailed",
			"--header-insertion=iwyu",
		},
	},
	eslint = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		},
	},
	gopls = {
		settings = {
			gopls = {
				completeUnimported = true,
				gofumpt = true,
				staticcheck = true,
				usePlaceholders = true,
				analyses = {
					nilness = true,
					shadow = true,
					unusedparams = true,
					unreachable = true,
				},
			},
		},
	},
	intelephense = {
		filetypes = { "php", "phtml" },
	},
	-- laravel_ls = {
	-- 	filetypes = { "blade" },
	-- },
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					checkThirdParty = false,
					library = {
						vim.env.VIMRUNTIME,
						vim.fn.stdpath("config"),
					},
				},
				telemetry = {
					enable = false,
				},
			},
		},
	},
	nixd = {
		enabled = function()
			return executable("nixd")
		end,
	},
	nil_ls = {
		enabled = function()
			return not executable("nixd") and executable("nil")
		end,
	},
	pyright = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
				},
				checkOnSave = {
					command = "clippy",
				},
				procMacro = {
					enable = true,
				},
			},
		},
	},
	ts_ls = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"javascript.jsx",
			"typescript",
			"typescriptreact",
			"typescript.tsx",
		},
	},
}
