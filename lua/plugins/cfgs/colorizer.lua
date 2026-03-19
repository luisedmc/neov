require("colorizer").setup({
  filetypes = { "*" },
  user_default_options = {
    RGB = true,
    RRGGBB = true,
    names = false,
    RRGGBBAA = true,
    AARRGGBB = false,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = false,
    mode = "background",
    tailwind = true,
    sass = { enable = false, parsers = { "css" } },
    virtualtext = "■",
    suppress_deprecation = true,
  },
})

vim.defer_fn(function()
  require("colorizer").attach_to_buffer(0)
end, 0)
