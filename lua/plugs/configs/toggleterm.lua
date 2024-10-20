require "toggleterm".setup {
  size = 13,
  shading_factor = '-27',
  open_mapping = [[<c-`>]],
  shade_filetypes = { "toggleterm" },
  shade_terminals = true,
  start_in_insert = true,
  persist_size = true,
  direction = 'horizontal',
  float_opts = {
    winblend = 3,
  },
  winbar = {
    enabled = false,
  },
  close_on_exit = true,
}
-- {
-- 	"akinsho/toggleterm.nvim",
-- 	cmd = { "ToggleTerm", "TermExec" },
-- 	keys = {
-- 		{
-- 			mode = { "n", "t", "v" },
-- 			[[<C-`>]],
-- 			"<cmd>ToggleTerm size=10 direction=horizontal<cr>",
-- 			{ desc = "Toggle Terminal" },
-- 		},
-- 	},
-- 	version = "*",
-- 	opts = {
-- 		shading_factor = 0.2,
-- 		highlights = { NormalFloat = { link = "NormalFloat" } },
-- 		float_opts = { border = "none" },
-- 	},
-- },
