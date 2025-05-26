api = vim.api
cmd = vim.cmd
fn = vim.fn
g = vim.g
opt = vim.opt

local modules = {
	"core",
	"plugins",
	"ui",
}

for _, mod in ipairs(modules) do
	local ok, err = pcall(require, mod)
	if not ok then
		error("Error calling " .. mod .. err)
	end
end
