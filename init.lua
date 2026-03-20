local req = {
	"core.lazy",
	"core.opts",
	"core.keys",
	"core.autocmd",
	"core.lsp",
	"ui.terminal",
	"ui.colorschemes",
	"ui.statusline",
	"ui.bufferline",
	"ui.statuscolumn",
}
for _, i in pairs(req) do
	require(i)
end
