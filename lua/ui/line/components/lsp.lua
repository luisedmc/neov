function get_lsp_client()
	local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
	if #buf_clients == 0 then
		return "no lsp"
	end

	local buf_client_names = {}
	for _, client in pairs(buf_clients) do
		if client.name ~= "null-ls" then
			table.insert(buf_client_names, client.name)
		end
	end

	if #buf_client_names > 0 then
		return table.concat(buf_client_names, ", ")
	else
		return "no lsp"
	end
end
