require('nvim-treesitter.configs').setup {
  highlight = {
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
  ensure_installed = { 'python', 'lua', 'go', 'c', 'javascript','typescript' },
  auto_install = true,
}
