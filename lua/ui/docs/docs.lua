local M = {}
local api = vim.api

local handlers = {
  c       = { cmd = "man",  sections = { "2", "3", "1" }, ft = "man",  search = "man_pages", search_section = "2" },
  cpp     = { cmd = "man",  sections = { "2", "3", "1" }, ft = "man",  search = "man_pages", search_section = "2" },
  sh      = { cmd = "man",  sections = { "1" },           ft = "man",  search = "man_pages", search_section = "1" },
  bash    = { cmd = "man",  sections = { "1" },           ft = "man",  search = "man_pages", search_section = "1" },
  zsh     = { cmd = "man",  sections = { "1" },           ft = "man",  search = "man_pages", search_section = "1" },
  go      = { cmd = "go doc %s",     ft = "go",   search = "go_doc" },
  python  = { cmd = "pydoc %s",      ft = "text", search = "pydoc" },
  lua     = { cmd = "vim_help",      ft = "help", search = "help_tags" },
  rust    = { cmd = "rustup doc --std %s", ft = "text", search = "man_pages", browser = true },
  nix     = { cmd = "man",  sections = { "5", "1" },      ft = "man",  search = "man_pages", search_section = "5" },
  php     = { cmd = "man",  sections = { "3", "1" },      ft = "man",  search = "man_pages", search_section = "3" },
}

local doc_buf, doc_win, doc_augroup

local function create_doc_float(lines, title, buf_ft)
  M.close_doc_float()

  doc_buf = api.nvim_create_buf(false, true)

  local width = vim.o.columns
  local height = vim.o.lines
  local win_width = math.floor(width * 0.7)
  local win_height = math.floor(height * 0.7)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = math.max(0, row - 3),
    col = col,
    style = "minimal",
    title = " " .. (title or "Documentation") .. " ",
    title_pos = "left",
    border = {
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
      { " ", "MyFloatBorder" },
    },
  }

  doc_win = api.nvim_open_win(doc_buf, true, opts)

  api.nvim_set_option_value("winhl",
    "FloatBorder:MyFloatBorder,FloatTitle:MyFloatTitle,Normal:MyTerminalBackground",
    { win = doc_win })
  api.nvim_set_option_value("winblend", 0, { win = doc_win })

  api.nvim_buf_set_lines(doc_buf, 0, -1, false, lines)
  api.nvim_set_option_value("modifiable", false,    { buf = doc_buf })
  api.nvim_set_option_value("bufhidden",  "wipe",   { buf = doc_buf })
  api.nvim_set_option_value("buftype",    "nofile",  { buf = doc_buf })

  if buf_ft then
    api.nvim_set_option_value("filetype", buf_ft, { buf = doc_buf })
  end

  vim.keymap.set("n", "q",     M.close_doc_float, { buffer = doc_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", M.close_doc_float, { buffer = doc_buf, noremap = true, silent = true })

  doc_augroup = api.nvim_create_augroup("DocFloat", { clear = true })
  api.nvim_create_autocmd("WinLeave", {
    group    = doc_augroup,
    once     = true,
    callback = function()
      if doc_win and api.nvim_win_is_valid(doc_win) then
        M.close_doc_float()
      end
    end,
  })
end

function M.close_doc_float()
  if doc_augroup then
    pcall(api.nvim_clear_autocmds, { group = doc_augroup })
    doc_augroup = nil
  end
  if doc_win and api.nvim_win_is_valid(doc_win) then
    pcall(api.nvim_win_close, doc_win, true)
  end
  if doc_buf and api.nvim_buf_is_valid(doc_buf) then
    pcall(api.nvim_buf_delete, doc_buf, { force = true })
  end
  doc_win = nil
  doc_buf = nil
end

local function run_command(cmd, word)
  local full_cmd = string.format(cmd, vim.fn.shellescape(word))
  local output = vim.fn.systemlist(full_cmd)

  if vim.v.shell_error ~= 0 then
    return nil
  end

  while #output > 0 and output[#output] == "" do
    table.remove(output)
  end

  if #output == 0 then
    return nil
  end

  return output
end

local function run_man_command(section, word)
  local cmd = "man " .. vim.fn.shellescape(tostring(section)) .. " %s 2>/dev/null"
  if vim.fn.executable("col") == 1 then
    cmd = cmd .. " | col -bx"
  end
  return run_command(cmd, word)
end

local function is_c_like(filetype)
  return filetype == "c" or filetype == "cpp"
end

local function get_symbol_from_context()
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2] + 1
  local before_cursor = line:sub(1, col)
  local from_call = before_cursor:match("([%a_][%w_]*)%s*%([^(){}%[%]]*$")
  if from_call and from_call ~= "" then
    return from_call
  end

  local word = vim.fn.expand("<cword>")
  if type(word) == "string" and word ~= "" then
    return word
  end
  return nil
end

local function normalize_markup(markup)
  if type(markup) == "string" then
    return markup
  end

  if type(markup) == "table" then
    if type(markup.value) == "string" then
      return markup.value
    end

    if vim.tbl_islist(markup) then
      local out = {}
      for _, item in ipairs(markup) do
        if type(item) == "string" then
          out[#out + 1] = item
        elseif type(item) == "table" and type(item.value) == "string" then
          out[#out + 1] = item.value
        end
      end

      if #out > 0 then
        return table.concat(out, "\n")
      end
    end
  end

  return nil
end

local function get_parameter_label(signature, active_parameter)
  if type(signature) ~= "table" or type(signature.parameters) ~= "table" then
    return nil
  end

  local parameter = signature.parameters[(active_parameter or 0) + 1]
  if type(parameter) ~= "table" then
    return nil
  end

  local label = parameter.label
  if type(label) == "string" then
    local trimmed = vim.trim(label)
    return trimmed ~= "" and trimmed or nil
  end

  if type(label) == "table" and type(signature.label) == "string" then
    local start_idx = tonumber(label[1] or label.start) or 0
    local end_idx = tonumber(label[2] or label["end"]) or start_idx
    if end_idx > start_idx then
      local extracted = signature.label:sub(start_idx + 1, end_idx)
      local trimmed = vim.trim(extracted)
      return trimmed ~= "" and trimmed or nil
    end
  end

  return nil
end

local function sorted_response_ids(responses)
  local ids = {}
  for client_id, _ in pairs(responses or {}) do
    ids[#ids + 1] = tonumber(client_id) or client_id
  end
  table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
  return ids
end

local function get_lsp_signature(bufnr)
  local params = vim.lsp.util.make_position_params(0)
  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/signatureHelp", params, 800)
  if type(responses) ~= "table" then
    return nil
  end

  for _, client_id in ipairs(sorted_response_ids(responses)) do
    local response = responses[client_id] or responses[tostring(client_id)]
    local result = response and response.result
    local signatures = result and result.signatures
    if type(signatures) == "table" and #signatures > 0 then
      local active_signature = (tonumber(result.activeSignature) or 0) + 1
      if active_signature < 1 or active_signature > #signatures then
        active_signature = 1
      end

      local signature = signatures[active_signature]
      local label = signature and signature.label
      if type(label) == "string" and label ~= "" then
        local active_parameter = tonumber(signature.activeParameter)
        if active_parameter == nil then
          active_parameter = tonumber(result.activeParameter) or 0
        end
        if active_parameter < 0 then
          active_parameter = 0
        end

        local client = vim.lsp.get_client_by_id(tonumber(client_id))
        local documentation = normalize_markup(signature.documentation)
        if not documentation and type(signature.parameters) == "table" then
          local parameter = signature.parameters[active_parameter + 1]
          if type(parameter) == "table" then
            documentation = normalize_markup(parameter.documentation)
          end
        end

        return {
          label = label,
          active_parameter = active_parameter,
          active_parameter_label = get_parameter_label(signature, active_parameter),
          documentation = documentation,
          client_name = client and client.name or "lsp",
        }
      end
    end
  end

  return nil
end

local function normalize_location(item)
  if type(item) ~= "table" then
    return nil
  end

  if item.uri and item.range and item.range.start then
    return {
      uri = item.uri,
      range = item.range,
    }
  end

  if item.targetUri then
    return {
      uri = item.targetUri,
      range = item.targetSelectionRange or item.targetRange,
    }
  end

  if vim.tbl_islist(item) then
    for _, nested in ipairs(item) do
      local normalized = normalize_location(nested)
      if normalized then
        return normalized
      end
    end
  end

  return nil
end

local function request_first_location(bufnr, method)
  local params = vim.lsp.util.make_position_params(0)
  local responses = vim.lsp.buf_request_sync(bufnr, method, params, 1000)
  if type(responses) ~= "table" then
    return nil
  end

  for _, client_id in ipairs(sorted_response_ids(responses)) do
    local response = responses[client_id] or responses[tostring(client_id)]
    local normalized = normalize_location(response and response.result)
    if normalized and normalized.uri then
      local client = vim.lsp.get_client_by_id(tonumber(client_id))
      return {
        uri = normalized.uri,
        range = normalized.range,
        client_name = client and client.name or "lsp",
      }
    end
  end

  return nil
end

local function get_lsp_origin(bufnr)
  local declaration = request_first_location(bufnr, "textDocument/declaration")
  local location = declaration or request_first_location(bufnr, "textDocument/definition")
  if not location or not location.uri then
    return nil
  end

  local ok, path = pcall(vim.uri_to_fname, location.uri)
  if not ok or type(path) ~= "string" or path == "" then
    return nil
  end

  local line = location.range and location.range.start and (location.range.start.line + 1) or nil
  return {
    path = path,
    line = line,
    client_name = location.client_name,
  }
end

local function classify_origin(path, filetype)
  if type(path) ~= "string" or path == "" then
    return nil
  end

  local short_path = vim.fn.fnamemodify(path, ":~")
  local lower_path = path:lower()
  local system_prefixes = {
    "/usr/include/",
    "/opt/homebrew/include/",
    "/library/developer/commandlinetools/",
    "/applications/xcode.app/contents/developer/",
  }

  local kind = "External file"
  if lower_path:find(".sdk/usr/include/", 1, true) then
    kind = "System header"
  else
    for _, prefix in ipairs(system_prefixes) do
      if lower_path:find(prefix, 1, true) then
        kind = "System header"
        break
      end
    end
  end

  local uv = vim.uv or vim.loop
  local cwd = uv and uv.cwd and uv.cwd() or nil
  if kind ~= "System header" and type(cwd) == "string" and cwd ~= "" and path:sub(1, #cwd) == cwd then
    kind = "Project file"
  end

  local info = {
    short_path = short_path,
    kind = kind,
  }

  if is_c_like(filetype) and path:match("%.h$") then
    info.header = "<" .. vim.fn.fnamemodify(path, ":t") .. ">"
  end

  return info
end

local function is_man_heading(line)
  local trimmed = vim.trim(line or "")
  if trimmed == "" then
    return false
  end
  return trimmed:match("^[A-Z][A-Z0-9 %-%._()]+$") ~= nil
end

local function trim_blank_edges(lines)
  local out = {}
  for _, line in ipairs(lines or {}) do
    out[#out + 1] = line
  end

  while #out > 0 and vim.trim(out[1]) == "" do
    table.remove(out, 1)
  end

  while #out > 0 and vim.trim(out[#out]) == "" do
    table.remove(out)
  end

  return out
end

local function extract_man_section(lines, section_name)
  if type(lines) ~= "table" or #lines == 0 then
    return {}
  end

  local start_idx = nil
  for idx, line in ipairs(lines) do
    if vim.trim(line) == section_name then
      start_idx = idx + 1
      break
    end
  end

  if not start_idx then
    return {}
  end

  local section = {}
  for idx = start_idx, #lines do
    local line = lines[idx]
    if idx > start_idx and is_man_heading(line) then
      break
    end
    section[#section + 1] = line
  end

  return trim_blank_edges(section)
end

local function extract_man_includes(synopsis_lines)
  local includes = {}
  local seen = {}

  for _, line in ipairs(synopsis_lines or {}) do
    local include = vim.trim(line):match("^#include%s+([<\"][^>\"]+[>\"])")
    if include and not seen[include] then
      seen[include] = true
      includes[#includes + 1] = include
    end
  end

  return includes
end

local function extract_man_library(lines)
  local library_section = extract_man_section(lines, "LIBRARY")
  for _, line in ipairs(library_section) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      return trimmed
    end
  end
  return nil
end

local function extract_man_prototypes(synopsis_lines, symbol)
  local prototypes = {}
  local seen = {}
  local escaped_symbol = (symbol or ""):gsub("([^%w])", "%%%1")
  local symbol_pattern = escaped_symbol .. "%s*%("

  local i = 1
  while i <= #synopsis_lines do
    local line = vim.trim(synopsis_lines[i] or "")
    if line ~= "" and line:find(symbol_pattern) then
      local parts = {}

      local prev_idx = i - 1
      while prev_idx >= 1 and vim.trim(synopsis_lines[prev_idx] or "") == "" do
        prev_idx = prev_idx - 1
      end

      if prev_idx >= 1 then
        local prev = vim.trim(synopsis_lines[prev_idx] or "")
        if prev ~= "" and not prev:match("^#include%s+") and not is_man_heading(prev) then
          parts[#parts + 1] = prev
        end
      end

      local j = i
      while j <= #synopsis_lines do
        local piece = vim.trim(synopsis_lines[j] or "")
        if piece ~= "" then
          parts[#parts + 1] = piece
        end
        if piece:find("%);$") or (j > i and piece:find("%)$")) then
          break
        end
        if #parts >= 8 then
          break
        end
        j = j + 1
      end

      local prototype = table.concat(parts, " "):gsub("%s+", " ")
      if prototype ~= "" and not seen[prototype] then
        seen[prototype] = true
        prototypes[#prototypes + 1] = prototype
      end

      i = math.max(j + 1, i + 1)
    else
      i = i + 1
    end
  end

  return prototypes
end

local function get_man_signature_fallback(word, sections)
  for _, section in ipairs(sections or {}) do
    local lines = run_man_command(section, word)
    if lines then
      local synopsis = extract_man_section(lines, "SYNOPSIS")
      local signatures = extract_man_prototypes(synopsis, word)
      local includes = extract_man_includes(synopsis)
      local library = extract_man_library(lines)

      if #signatures > 0 or #includes > 0 or library then
        return {
          section = section,
          signatures = signatures,
          includes = includes,
          library = library,
        }
      end
    end
  end

  return nil
end

local function append_origin_info(lines, origin, filetype)
  if type(origin) ~= "table" then
    return
  end

  local classified = classify_origin(origin.path, filetype)
  if not classified then
    return
  end

  if classified.header then
    lines[#lines + 1] = "Header: " .. classified.header
  end

  local origin_line = "Origin: " .. classified.short_path
  if origin.line then
    origin_line = origin_line .. ":" .. tostring(origin.line)
  end
  lines[#lines + 1] = origin_line
  lines[#lines + 1] = "Origin kind: " .. classified.kind
end

local function append_documentation_preview(lines, documentation)
  local text = normalize_markup(documentation)
  if type(text) ~= "string" or text == "" then
    return
  end

  local preview = {}
  for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      preview[#preview + 1] = trimmed
    end
    if #preview >= 6 then
      break
    end
  end

  if #preview == 0 then
    return
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = "Documentation:"
  for _, line in ipairs(preview) do
    lines[#lines + 1] = line
  end
end

local function get_go_word()
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2] + 1
  local s = col
  while s > 1 and line:sub(s - 1, s - 1):match("[%w_.]") do
    s = s - 1
  end
  local e = col
  while e < #line and line:sub(e + 1, e + 1):match("[%w_.]") do
    e = e + 1
  end
  return line:sub(s, e)
end

function M.open_doc()
  local ft = vim.bo.filetype
  local handler = handlers[ft]

  if not handler then
    vim.lsp.buf.hover()
    return
  end

  if handler.cmd == "vim_help" then
    local word = vim.fn.expand("<cword>")
    if word == "" then return end
    vim.cmd("help " .. word)
    return
  end

  if handler.browser then
    local word = vim.fn.expand("<cword>")
    if word == "" then return end
    os.execute(string.format(handler.cmd, vim.fn.shellescape(word)))
    return
  end

  local word
  if ft == "go" then
    word = get_go_word()
  else
    word = vim.fn.expand("<cword>")
  end
  if word == "" then return end

  if handler.cmd == "man" then
    for _, section in ipairs(handler.sections) do
      local lines = run_man_command(section, word)
      if lines then
        create_doc_float(lines, "man " .. section .. " " .. word, "man")
        return
      end
    end
    vim.notify("No man page found for: " .. word, vim.log.levels.WARN)
    vim.lsp.buf.hover()
    return
  end

  local lines = run_command(handler.cmd, word)
  if lines then
    create_doc_float(lines, ft:upper() .. ": " .. word, handler.ft)
  else
    vim.notify("No documentation found for: " .. word, vim.log.levels.INFO)
    vim.lsp.buf.hover()
  end
end

function M.show_symbol_signature()
  local bufnr = api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local symbol = get_symbol_from_context()

  if not symbol then
    vim.notify("No symbol under cursor", vim.log.levels.WARN)
    return
  end

  local lsp_signature = get_lsp_signature(bufnr)
  if lsp_signature then
    local origin = get_lsp_origin(bufnr)
    local lines = {
      "Symbol: " .. symbol,
      "Signature: " .. lsp_signature.label,
    }

    if lsp_signature.active_parameter_label then
      lines[#lines + 1] = "Active parameter: " .. lsp_signature.active_parameter_label
    elseif type(lsp_signature.active_parameter) == "number" then
      lines[#lines + 1] = "Active parameter index: " .. tostring(lsp_signature.active_parameter + 1)
    end

    append_origin_info(lines, origin, filetype)
    lines[#lines + 1] = "Source: " .. (lsp_signature.client_name or "lsp")
    append_documentation_preview(lines, lsp_signature.documentation)
    create_doc_float(lines, "Signature: " .. symbol, "text")
    return
  end

  if is_c_like(filetype) then
    local fallback = get_man_signature_fallback(symbol, { "2", "3", "1" })
    if fallback then
      local lines = { "Symbol: " .. symbol }
      if type(fallback.signatures) == "table" and fallback.signatures[1] then
        lines[#lines + 1] = "Signature: " .. fallback.signatures[1]
      end
      if type(fallback.includes) == "table" and #fallback.includes > 0 then
        lines[#lines + 1] = "Headers: " .. table.concat(fallback.includes, ", ")
      end
      if fallback.library then
        lines[#lines + 1] = "Library: " .. fallback.library
      end
      lines[#lines + 1] = "Source: man " .. tostring(fallback.section) .. " " .. symbol
      create_doc_float(lines, "Signature: " .. symbol, "text")
      return
    end
  end

  vim.notify("No signature found for: " .. symbol, vim.log.levels.INFO)
  vim.lsp.buf.hover()
end

local function scan_man_pages(sections)
  local paths = vim.fn.systemlist("manpath 2>/dev/null")
  if vim.v.shell_error ~= 0 or #paths == 0 then
    return {}
  end

  local man_dirs = vim.split(paths[1], ":")
  local seen = {}
  local results = {}

  for _, dir in ipairs(man_dirs) do
    for _, sec in ipairs(sections) do
      local man_sec_dir = dir .. "/man" .. sec
      local ok, entries = pcall(vim.fn.readdir, man_sec_dir)
      if ok then
        for _, entry in ipairs(entries) do
          local name = entry:gsub("%.gz$", ""):gsub("%." .. sec .. "[^.]*$", "")
          local display = name .. "(" .. sec .. ")"
          if not seen[display] then
            seen[display] = true
            table.insert(results, { display = display, name = name, section = sec })
          end
        end
      end
    end
  end

  table.sort(results, function(a, b) return a.display < b.display end)
  return results
end

function M.search_docs()
  local ft = vim.bo.filetype
  local handler = handlers[ft]

  if not handler then
    M.telescope_man_pages({ "1", "2", "3", "5", "7", "8" })
    return
  end

  local mode = handler.search

  if mode == "man_pages" then
    M.telescope_man_pages({ handler.search_section or "1" })
  elseif mode == "help_tags" then
    local ok, telescope = pcall(require, "telescope.builtin")
    if ok then telescope.help_tags() end
  elseif mode == "go_doc" then
    M.telescope_go_doc()
  elseif mode == "pydoc" then
    M.telescope_pydoc()
  else
    M.telescope_man_pages({ "1", "2", "3", "5", "7", "8" })
  end
end

function M.telescope_man_pages(sections)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local pages = scan_man_pages(sections)
  if #pages == 0 then
    vim.notify("No man pages found for sections: " .. table.concat(sections, ", "), vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Man Pages (" .. table.concat(sections, ", ") .. ")",
    finder = finders.new_table({
      results = pages,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local entry = selection.value
          local lines = run_man_command(entry.section, entry.name)
          if lines then
            create_doc_float(lines, "man " .. entry.section .. " " .. entry.name, "man")
          else
            vim.notify("Failed to open: " .. entry.display, vim.log.levels.WARN)
          end
        end
      end)
      return true
    end,
  }):find()
end

function M.telescope_go_doc()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local packages = vim.fn.systemlist("go list std 2>/dev/null")
  if vim.v.shell_error ~= 0 or #packages == 0 then
    vim.notify("Failed to list Go packages", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Go Documentation",
    finder = finders.new_table({ results = packages }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local lines = run_command("go doc %s", selection[1])
          if lines then
            create_doc_float(lines, "Go: " .. selection[1], "go")
          else
            vim.notify("No docs for: " .. selection[1], vim.log.levels.WARN)
          end
        end
      end)
      return true
    end,
  }):find()
end

function M.telescope_pydoc()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local modules = vim.fn.systemlist(
    "python3 -c \"import sys; print('\\n'.join(sorted(sys.stdlib_module_names)))\" 2>/dev/null"
  )
  if vim.v.shell_error ~= 0 then
    modules = {}
  end

  local installed = vim.fn.systemlist(
    "python3 -c \"import pkgutil; print('\\n'.join(m.name for m in pkgutil.iter_modules()))\" 2>/dev/null"
  )
  if vim.v.shell_error == 0 then
    for _, mod in ipairs(installed) do
      table.insert(modules, mod)
    end
  end

  if #modules == 0 then
    vim.notify("Failed to list Python modules", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Python Documentation",
    finder = finders.new_table({ results = modules }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local lines = run_command("pydoc %s", selection[1])
          if lines then
            create_doc_float(lines, "Python: " .. selection[1], "text")
          else
            vim.notify("No docs for: " .. selection[1], vim.log.levels.WARN)
          end
        end
      end)
      return true
    end,
  }):find()
end

return M
