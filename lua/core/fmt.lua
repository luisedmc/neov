api.nvim_create_autocmd("LspAttach", {
	group = api.nvim_create_augroup("lsp", { clear = true }),
	callback = function(args)
		-- 2
		api.nvim_create_autocmd("BufWritePre", {
			-- 3
			buffer = args.buf,
			callback = function()
				-- 4 + 5
				vim.lsp.buf.format({ async = false, id = args.data.client_id })
			end,
		})
	end,
})

api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})
