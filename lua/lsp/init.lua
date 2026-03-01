local M = {}
local server_boot_state = {
	ordered = {},
	configured = {},
	enabled = {},
	skipped = {},
	missing = {},
}

local function sorted_keys(tbl)
	local keys = {}
	for key, _ in pairs(tbl or {}) do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function format_cmd(cmd)
	if type(cmd) == "table" then
		return table.concat(cmd, " ")
	end
	if type(cmd) == "string" then
		return cmd
	end
	return "<unknown>"
end

local function resolve_cmd_executable(cmd)
	if type(cmd) == "table" and type(cmd[1]) == "string" and cmd[1] ~= "" then
		return cmd[1]
	end

	if type(cmd) == "string" then
		return cmd:match("^%s*([^%s]+)")
	end

	return nil
end

local function evaluate_enabled_predicate(server, enabled_predicate, server_config)
	if enabled_predicate == nil then
		return true
	end

	if type(enabled_predicate) == "function" then
		local ok, result = pcall(enabled_predicate, server, server_config)
		if not ok then
			return false, "enabled() error: " .. tostring(result)
		end
		if result == false then
			return false, "disabled by enabled()"
		end
		return true
	end

	if enabled_predicate == false then
		return false, "disabled by enabled=false"
	end

	return true
end

local function build_server_status_lines()
	local lines = {
		"Server definitions: " .. table.concat(server_boot_state.ordered, ", "),
	}

	local configured = sorted_keys(server_boot_state.configured)
	local enabled = sorted_keys(server_boot_state.enabled)
	local skipped = sorted_keys(server_boot_state.skipped)
	local missing = sorted_keys(server_boot_state.missing)

	lines[#lines + 1] = "Configured: " .. (#configured > 0 and table.concat(configured, ", ") or "<none>")
	lines[#lines + 1] = "Enabled: " .. (#enabled > 0 and table.concat(enabled, ", ") or "<none>")

	if #skipped > 0 then
		lines[#lines + 1] = "Skipped:"
		for _, server in ipairs(skipped) do
			local item = server_boot_state.skipped[server] or {}
			local suffix = item.executable and (" (" .. item.executable .. ")") or ""
			lines[#lines + 1] = string.format("- %s: %s%s", server, item.reason or "skipped", suffix)
		end
	end

	if #missing > 0 then
		lines[#lines + 1] = "Missing executables:"
		for _, server in ipairs(missing) do
			local item = server_boot_state.missing[server] or {}
			lines[#lines + 1] = string.format("- %s -> %s", server, item.executable or "<unknown>")
		end
	end

	return lines
end

local function notify_missing_servers()
	local missing = sorted_keys(server_boot_state.missing)
	if #missing == 0 then
		return
	end

	local lines = { "Skipped LSP servers with missing executables:" }
	for _, server in ipairs(missing) do
		local item = server_boot_state.missing[server] or {}
		lines[#lines + 1] =
			string.format("- %s: %s (cmd: %s)", server, item.executable or "<unknown>", format_cmd(item.cmd))
	end

	vim.schedule(function()
		local message = table.concat(lines, "\n")
		if #vim.api.nvim_list_uis() == 0 then
			print(message)
			return
		end

		vim.notify(message, vim.log.levels.WARN, { title = "LSP setup" })
	end)
end

local function get_position_encoding(bufnr, method)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
	if #clients == 0 then
		clients = vim.lsp.get_clients({ bufnr = bufnr })
	end

	local client = clients[1]
	if client and type(client.offset_encoding) == "string" and client.offset_encoding ~= "" then
		return client.offset_encoding
	end
	if client and type(client.position_encoding) == "string" and client.position_encoding ~= "" then
		return client.position_encoding
	end

	return "utf-16"
end

local function rename()
	local api = vim.api
	local current_word = vim.fn.expand("<cword>")
	local buf = api.nvim_create_buf(false, true)

	local opts = {
		height = 1,
		style = "minimal",
		border = {
			{ " ", "MySearchBackground" },
			{ " ", "MyFloatBorder" },
			{ " ", "MyFloatBorder" },
			{ " ", "MySearchBackground" },
			{ " ", "MySearchBackground" },
			{ " ", "MySearchBackground" },
			{ " ", "MySearchBackground" },
			{ " ", "MySearchBackground" },
		},
		row = 1,
		col = 1,
		relative = "cursor",
		width = #current_word + 15,
		title = { { "rename ", "MyCmdLineTitle" } },
		title_pos = "left",
	}

	local win = api.nvim_open_win(buf, true, opts)
	vim.wo[win].winhl = "Normal:CursorLine,FloatBorder:CursorLine"
	api.nvim_set_current_win(win)
	api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. current_word })
	vim.bo[buf].buftype = "prompt"
	vim.fn.prompt_setprompt(buf, "")
	vim.api.nvim_input("A")

	vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>q!<CR>", { buffer = buf })

	vim.fn.prompt_setcallback(buf, function(text)
		local new_name = vim.trim(text)
		api.nvim_buf_delete(buf, { force = true })

		if #new_name > 0 and new_name ~= current_word then
			local params = vim.lsp.util.make_position_params(
				0,
				get_position_encoding(0, "textDocument/rename")
			)
			params.newName = new_name
			vim.lsp.buf_request(0, "textDocument/rename", params)
		end
	end)
end

local function configure_diagnostics()
	vim.diagnostic.config({
		virtual_text = {
			spacing = 2,
			format = function(diagnostic)
				local source = diagnostic.source or "LSP"
				local code = diagnostic.code and (" [" .. diagnostic.code .. "]") or ""
				return string.format("%s: %s%s", source, diagnostic.message, code)
			end,
		},
		underline = true,
		update_in_insert = true,
		severity_sort = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.INFO] = "",
			},
		},
	})
end

local function on_lsp_attach(event)
	local client = event.data and event.data.client_id and vim.lsp.get_client_by_id(event.data.client_id) or nil
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	map("<leader>gd", vim.lsp.buf.definition, "Defs")
	map("K", vim.lsp.buf.hover, "Hover")
	map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
	map("<leader>rn", rename, "Rename")
	map("gr", vim.lsp.buf.references, "Goto References")
	map("gd", vim.lsp.buf.definition, "Goto Definition")
	map("<leader>bf", function()
		require("conform").format({
			async = true,
			lsp_format = "fallback",
		})
	end, "Format Buffer")
	map("gi", vim.lsp.buf.implementation, "Goto Implementation")
	map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
	map("gD", vim.lsp.buf.declaration, "Goto Declaration")
	map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
	map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
	map("<leader>dl", vim.diagnostic.open_float, "Line Diagnostics")
	map("<leader>dq", vim.diagnostic.setqflist, "Diagnostics Quickfix")
	map("<leader>ds", vim.lsp.buf.document_symbol, "Document Symbols")
	map("<leader>ws", function()
		vim.ui.input({ prompt = "Workspace symbols: " }, function(query)
			if query and query ~= "" then
				vim.lsp.buf.workspace_symbol(query)
			end
		end)
	end, "Workspace Symbols")

	local doc_highlight_method = vim.lsp.protocol.Methods and vim.lsp.protocol.Methods.textDocument_documentHighlight
		or "textDocument/documentHighlight"

	if client and client:supports_method(doc_highlight_method) then
		local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight-" .. event.buf, { clear = true })

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = event.buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = event.buf,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("lsp-detach-" .. event.buf, { clear = true }),
			buffer = event.buf,
			callback = function(detach_event)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = highlight_augroup, buffer = detach_event.buf })
			end,
		})
	end

	local inlay_hint_method = vim.lsp.protocol.Methods and vim.lsp.protocol.Methods.textDocument_inlayHint
		or "textDocument/inlayHint"
	if client and vim.lsp.inlay_hint and client:supports_method(inlay_hint_method) then
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = event.buf })
	end
end

function M.setup()
	configure_diagnostics()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = on_lsp_attach,
	})

	vim.api.nvim_create_user_command("LspServerStatus", function()
		local lines = build_server_status_lines()
		local message = table.concat(lines, "\n")
		if #vim.api.nvim_list_uis() == 0 then
			print(message)
			return
		end

		vim.notify(message, vim.log.levels.INFO, { title = "LSP Server Status" })
	end, { desc = "Show LSP server status", force = true })
end

function M.setup_servers(servers)
	local server_names = {}
	for server, _ in pairs(servers or {}) do
		table.insert(server_names, server)
	end
	table.sort(server_names)

	server_boot_state = {
		ordered = server_names,
		configured = {},
		enabled = {},
		skipped = {},
		missing = {},
	}

	-- local has_blink, blink = pcall(require, "blink.cmp")
	local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")

	for _, server in ipairs(server_names) do
		local raw_config = servers[server] or {}
		local server_config = vim.tbl_deep_extend("force", {}, raw_config)
		local enabled_predicate = server_config.enabled
		server_config.enabled = nil

		local should_enable, skip_reason = evaluate_enabled_predicate(server, enabled_predicate, server_config)
		if should_enable then
			local capabilities = server_config.capabilities or {}

			-- if has_blink then
			--   capabilities = blink.get_lsp_capabilities(capabilities)
			-- end

			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			server_config.capabilities = capabilities

			local ok_config, config_err = pcall(vim.lsp.config, server, server_config)
			if ok_config then
				server_boot_state.configured[server] = true

				local merged_config = vim.lsp.config[server] or server_config
				local cmd = merged_config.cmd or server_config.cmd
				local executable = resolve_cmd_executable(cmd)

				if executable and vim.fn.executable(executable) ~= 1 then
					server_boot_state.missing[server] = {
						executable = executable,
						cmd = cmd,
					}
					server_boot_state.skipped[server] = {
						reason = "missing executable",
						executable = executable,
						cmd = cmd,
					}
				else
					local ok_enable, enable_err = pcall(vim.lsp.enable, server)
					if ok_enable then
						server_boot_state.enabled[server] = {
							executable = executable,
							cmd = cmd,
						}
					else
						server_boot_state.skipped[server] = {
							reason = "enable error: " .. tostring(enable_err),
							executable = executable,
							cmd = cmd,
						}
					end
				end
			else
				server_boot_state.skipped[server] = { reason = "config error: " .. tostring(config_err) }
			end
		else
			server_boot_state.skipped[server] = { reason = skip_reason }
		end
	end

	notify_missing_servers()
end

return M
