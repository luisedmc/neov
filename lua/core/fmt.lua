vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    -- 2
    vim.api.nvim_create_autocmd("BufWritePre", {
      -- 3
      buffer = args.buf,
      callback = function()
        -- 4 + 5
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
	end,
})

-- formatting on save
-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
-- 	callback = function()
-- 		for _, client in ipairs(vim.lsp.get_active_clients()) do
-- 			if client.attached_buffers[vim.api.nvim_get_current_buf()] then
-- 				vim.lsp.buf.format()
-- 				return
-- 			else
-- 				return
-- 			end
-- 		end
-- 	end
-- })
--
-- vim.api.nvim_create_autocmd({ "UIEnter" }, {
-- 	callback = function()
-- 		local should_skip = false
-- 		if vim.fn.argc() > 0 or vim.fn.line2byte "$" ~= -1 or not vim.o.modifiable then
-- 			should_skip = true
-- 		else
-- 			for _, arg in pairs(vim.v.argv) do
-- 				if arg == "-b" or arg == "-c" or vim.startswith(arg, "+") or arg == "-S" then
-- 					should_skip = true
-- 					break
-- 				end
-- 			end
-- 		end
-- 	end
-- })

