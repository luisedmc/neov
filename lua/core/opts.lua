vim.loader.enable()

local opt = vim.opt
local g   = vim.g

g.loaded_python3_provider = 0

opt.autoindent = true
opt.background = "dark"
opt.backup = false
opt.writebackup = false
opt.breakindent = true
opt.cursorline = true
opt.clipboard = "unnamedplus"
vim.opt.encoding = "utf-8"
opt.expandtab = false
opt.fillchars = {
	eob = " ",
	diff = " ",
	msgsep = " ",
}
opt.fileencoding = "utf-8"
opt.hlsearch = false
opt.history = 100
opt.ignorecase = true
opt.laststatus = 3
opt.list = false
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.nuw = 1
opt.tabstop = 2
opt.timeoutlen = 500
opt.title = true
opt.titlestring = "%f"
opt.sdf = "NONE"
opt.shiftwidth = 2
opt.showtabline = 2
opt.showmode = false
opt.smartcase = true
opt.swf = false
opt.so = 6
opt.shortmess:append("sI")
opt.showmatch = false
opt.smartcase = true
opt.smartindent = true
opt.smarttab = true
opt.splitbelow = true
opt.synmaxcol = 240
opt.ph = 7
opt.ut = 300
opt.ruler = false
opt.wrap = true
opt.whichwrap:append("<>[]hl")
