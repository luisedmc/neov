vim.g.barpos = "bottom"
vim.g.barstyle = "floating"

if require("core.config").bar.show then
  require("ui.statusline." .. vim.g.barstyle).init(vim.g.barpos)
else
  vim.opt.ls = 0
end
