vim.loader.enable()
local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ' '

g.netrw_winsize = 25
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 0
g.netrw_bufsettings = 'number relativenumber'
g.netrw_list_hide = '^\\.\\(\\.\\|git\\)$'

opt.mouse = 'a'
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.wrap = true
opt.breakindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = false
opt.cursorline = true
opt.scrolloff = 2
opt.number = true
opt.relativenumber = true
opt.hidden = true
opt.termguicolors = true
opt.conceallevel = 2
opt.splitright = true
opt.clipboard = 'unnamedplus'
opt.showtabline = 2
opt.ruler = false
opt.autoindent = true
opt.background = 'dark'
vim.o.showmode = false
opt.fillchars:append { eob = " " }
