local config = {
  bar = {
    pos = vim.g.barpos or "bottom",
    style = vim.g.barstyle or "floating",
    show = vim.g.barshow ~= false,
  },
}

vim.g.barpos = config.bar.pos
vim.g.barstyle = config.bar.style

if config.bar.show then
  require("ui.statusline." .. config.bar.style).init(config.bar.pos)
else
  vim.opt.ls = 0
end
