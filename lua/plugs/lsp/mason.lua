local border = {
	{ "╭", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╮", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "╯", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╰", "FloatBorder" },
	{ "│", "FloatBorder" },
}
local handlers = {
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

mason_lspconfig.setup({
	ensure_installed = { "ts_ls", "lua_ls", "gopls", "clangd", "pyright" },
	handlers = {
		function(server_name)
			-- TS server will be handled by typescript-tools.nvim
			if server_name == "ts_ls" then
				return
			end

			require("lspconfig")[server_name].setup({
				handlers = handlers,
			})
		end,
	},
})

mason_tool_installer.setup({
	ensure_installed = { "stylua", "rust-analyzer", "pylint" },
})
