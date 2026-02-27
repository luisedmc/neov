local M = {}
local git_root_cache = {}
local git_branch_cache = {}
local git_cache_au_setup = false

local function invalidate_git_cache()
  git_root_cache = {}
  git_branch_cache = {}
end

local function setup_git_cache_invalidation()
  if git_cache_au_setup then
    return
  end
  git_cache_au_setup = true

  local group = vim.api.nvim_create_augroup("StatuslineGitBranchCache", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged", "FocusGained" }, {
    group = group,
    callback = invalidate_git_cache,
  })
end

local function get_start_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    return vim.fn.fnamemodify(name, ":p:h")
  end

  local uv = vim.uv or vim.loop
  return uv.cwd()
end

local function get_repo_root(bufnr)
  local cached = git_root_cache[bufnr]
  if cached ~= nil then
    return cached ~= false and cached or nil
  end

  local dir = get_start_dir(bufnr)
  local output = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
  local root = (vim.v.shell_error == 0 and output[1]) and output[1] or nil

  git_root_cache[bufnr] = root or false
  return root
end

local function get_branch_for_root(root)
  local cached = git_branch_cache[root]
  if cached ~= nil then
    return cached
  end

  local output = vim.fn.systemlist({ "git", "-C", root, "branch", "--show-current" })
  local branch = (vim.v.shell_error == 0 and output[1]) and output[1] or ""
  if branch == "" then
    branch = "not git"
  end

  git_branch_cache[root] = branch
  return branch
end

function M.get_mode()
  local modes = {
    ['n'] = { '', 'NORMAL', 'StModePurple', 'StModePurpleDim' },
    ['no'] = { '', 'NORMAL', 'StModePurple', 'StModePurpleDim' },
    ['v'] = { '', 'VISUAL', 'StModeRed', 'StModeRedDim' },
    ['V'] = { '', 'VISUAL LINE', 'StModeRed', 'StModeRedDim' },
    ['\22'] = { '', 'VISUAL BLOCK', 'StModeRed', 'StModeRedDim' },
    ['s'] = { '󰩬', 'SELECT', 'StModeRed', 'StModeRedDim' },
    ['S'] = { '󰩬', 'SELECT LINE', 'StModeRed', 'StModeRedDim' },
    ['i'] = { '󰏫', 'INSERT', 'StModeBlue', 'StModeBlueDim' },
    ['ic'] = { '󰏫', 'INSERT', 'StModeBlue', 'StModeBlueDim' },
    ['R'] = { '󰛔', 'REPLACE', 'StModeRed', 'StModeRedDim' },
    ['Rv'] = { '󰛔', 'REPLACE', 'StModeRed', 'StModeRedDim' },
    ['c'] = { '󰘳', 'COMMAND', 'StModeYellow', 'StModeYellowDim' },
    ['cv'] = { '󰘳', 'COMMAND', 'StModeYellow', 'StModeYellowDim' },
    ['ce'] = { '󰘳', 'COMMAND', 'StModeYellow', 'StModeYellowDim' },
    ['r'] = { '󰘳', 'PROMPT', 'StModeYellow', 'StModeYellowDim' },
    ['rm'] = { '󰘳', 'MOAR', 'StModeYellow', 'StModeYellowDim' },
    ['r?'] = { '󰘳', 'CONFIRM', 'StModeYellow', 'StModeYellowDim' },
    ['!'] = { '󰘳', 'SHELL', 'StModeYellow', 'StModeYellowDim' },
    ['t'] = { '', 'TERMINAL', 'StModeYellow', 'StModeYellowDim' },
  }
  local mode = vim.api.nvim_get_mode().mode
  local mode_data = modes[mode] or { '-', 'UNKNOWN', 'StModeGreen', 'StModeGreenDim' }
  return mode_data
end

function M.get_git_branch()
  setup_git_cache_invalidation()

  local root = get_repo_root(vim.api.nvim_get_current_buf())
  if not root then
    return { "", "not git" }
  end

  local branch = get_branch_for_root(root)
  if branch ~= "not git" then
    return { " ", branch }
  end

  return { "", "not git" }
end

function M.get_lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return { '', 'NO LSP', 'StLspOffIcon', 'StLspOffInfo' }
  end

  for _, client in ipairs(clients) do
    if type(client.name) == "string" and client.name ~= "" then
      return { '', client.name, 'StLspOnIcon', 'StLspOnInfo' }
    end
  end

  return { '', 'LSP', 'StLspOnIcon', 'StLspOnInfo' }
end

local function get_file_icon(filename, extension, buftype, filetype)
  if buftype == "terminal" then
    return ""
  end
  if buftype == "help" then
    return "󰋖"
  end
  if buftype == "quickfix" then
    return "󱖫"
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return ""
  end

  local icon = devicons.get_icon(filename, extension, { default = true })
  if (not icon or icon == "") and type(devicons.get_icon_by_filetype) == "function" and filetype ~= "" then
    icon = devicons.get_icon_by_filetype(filetype, { default = true })
  end

  return icon or ""
end

function M.get_file_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype

  local display_name
  if buftype == "help" then
    display_name = "help:" .. vim.fn.fnamemodify(name, ":t:r")
  elseif buftype == "quickfix" then
    display_name = "quickfix"
  elseif buftype == "terminal" then
    display_name = "terminal"
  elseif name == "" then
    display_name = "[No Name]"
  else
    display_name = vim.fn.fnamemodify(name, ":t")
  end

  local filename = vim.fn.fnamemodify(name, ":t")
  local extension = vim.fn.fnamemodify(filename, ":e")
  local icon = get_file_icon(filename, extension, buftype, filetype)

  return {
    icon = icon,
    name = display_name,
    modified = vim.bo[bufnr].modified,
    readonly = vim.bo[bufnr].readonly or not vim.bo[bufnr].modifiable,
  }
end

function M.get_git_diff()
  local dict = vim.b.gitsigns_status_dict
  if type(dict) ~= "table" then
    return { added = 0, changed = 0, removed = 0 }
  end

  return {
    added = tonumber(dict.added) or 0,
    changed = tonumber(dict.changed) or 0,
    removed = tonumber(dict.removed) or 0,
  }
end

function M.get_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local severity = vim.diagnostic.severity

  return {
    error = #vim.diagnostic.get(bufnr, { severity = severity.ERROR }),
    warn = #vim.diagnostic.get(bufnr, { severity = severity.WARN }),
    info = #vim.diagnostic.get(bufnr, { severity = severity.INFO }),
    hint = #vim.diagnostic.get(bufnr, { severity = severity.HINT }),
  }
end

function M.get_line_total()
  local line = vim.fn.line(".")
  local total = math.max(1, vim.fn.line("$"))
  return string.format("%d/%d", line, total)
end

return M
