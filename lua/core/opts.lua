vim.loader.enable()
local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ' '
g.loaded_python3_provider = 0

opt.autoindent = true
opt.background = 'dark'
opt.backup = false
opt.writebackup = false
opt.breakindent = true
opt.cursorline = true
opt.clipboard = 'unnamedplus'
opt.expandtab = false
opt.fileencoding = 'utf-8'
opt.fillchars:append ('eob: ')
opt.hlsearch = false
opt.hid = true
opt.ignorecase = true
opt.laststatus = 0
opt.lazyredraw = true
opt.list = false
opt.mouse = 'a'
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.nuw = 1
opt.tabstop = 2
opt.timeoutlen = 500
opt.shiftwidth = 2
opt.showtabline = 2
opt.showmode = false
opt.smartcase = true
opt.swf = false
opt.sdf = 'NONE'
opt.so = 6
opt.shortmess:append 'sI'
opt.smarttab = true
opt.splitbelow = true
opt.ph = 7
opt.ut = 300
opt.ruler = false
opt.wrap = true
