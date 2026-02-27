local M = {}


M.setup = function()
  vim.cmd [[
  :set statuscolumn=%s%C%5l\ 
  ]]
end

return M
