local M = {}
local api = vim.api

local handlers = {
  c       = { cmd = "man",  sections = { "3", "2", "1" }, ft = "man",  search = "man_pages", search_section = "3" },
  cpp     = { cmd = "man",  sections = { "3", "2", "1" }, ft = "man",  search = "man_pages", search_section = "3" },
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

local doc_buf, doc_win

local function create_doc_float(lines, title, buf_ft)
  M.close_doc_float()

  doc_buf = api.nvim_create_buf(false, true)

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")
  local win_width = math.floor(width * 0.7)
  local win_height = math.floor(height * 0.7)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row - 3,
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

  api.nvim_win_set_option(doc_win, "winhl",
    "FloatBorder:MyFloatBorder,FloatTitle:MyFloatTitle,Normal:MyTerminalBackground")
  api.nvim_win_set_option(doc_win, "winblend", 0)

  api.nvim_buf_set_lines(doc_buf, 0, -1, false, lines)
  api.nvim_buf_set_option(doc_buf, "modifiable", false)
  api.nvim_buf_set_option(doc_buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(doc_buf, "buftype", "nofile")

  if buf_ft then
    api.nvim_buf_set_option(doc_buf, "filetype", buf_ft)
  end

  api.nvim_buf_set_keymap(doc_buf, "n", "q", "<cmd>lua require('ui.docs.docs').close_doc_float()<CR>",
    { noremap = true, silent = true })
  api.nvim_buf_set_keymap(doc_buf, "n", "<Esc>", "<cmd>lua require('ui.docs.docs').close_doc_float()<CR>",
    { noremap = true, silent = true })
end

function M.close_doc_float()
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
      local lines = run_command("man " .. section .. " %s 2>/dev/null", word)
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
          local lines = run_command("man " .. entry.section .. " %s 2>/dev/null", entry.name)
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
