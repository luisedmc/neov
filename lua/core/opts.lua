vim.loader.enable()

g.mapleader = " "
g.maplocalleader = " "
g.loaded_python3_provider = 0

opt.autoindent = true
opt.background = "dark"
opt.backup = false
opt.writebackup = false
opt.breakindent = true
opt.cursorline = true
opt.clipboard = "unnamedplus"
opt.expandtab = false
opt.fillchars = {
	eob = " ",
	diff = " ",
	msgsep = " ",
}
opt.fileencoding = "utf-8"
opt.hlsearch = false
opt.hid = true
opt.ignorecase = true
opt.laststatus = 3
opt.lazyredraw = true
opt.list = false
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.nuw = 1
opt.tabstop = 2
opt.timeoutlen = 500
opt.title = true
opt.titlestring = "%f"
opt.shiftwidth = 2
opt.showtabline = 2
opt.showmode = false
opt.smartcase = true
opt.swf = false
opt.sdf = "NONE"
opt.so = 6
opt.shortmess:append("sI")
opt.showmatch = false
opt.smartcase = true
opt.smartindent = true
opt.smarttab = true
opt.splitbelow = true
opt.ph = 7
opt.ut = 300
opt.ruler = false
opt.wrap = true
opt.whichwrap:append("<>[]hl")

-- disable inbuilt vim plugins
local built_ins = {
	"2html_plugin",
	"getscript",
	"getscriptPlugin",
	"gzip",
	"logipat",
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"matchit",
	"tar",
	"tarPlugin",
	"rrhelper",
	"spellfile_plugin",
	"vimball",
	"vimballPlugin",
	"zip",
	"zipPlugin",
}

for _, plugin in pairs(built_ins) do
	g["loaded_" .. plugin] = 1
end
