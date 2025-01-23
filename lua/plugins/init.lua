require('plugins.strap')
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins.plgs" },
  },
  {
    ui = {
      size = { width = 0.8, height = 0.8 },
      border = "solid",
      icons = {
        cmd = " ",
        config = "",
        event = "",
        ft = "",
        init = " ",
        import = " ",
        keys = " ",
        lazy = "󰂠 ",
        loaded = "",
        not_loaded = "",
        plugin = " ",
        runtime = " ",
        source = " ",
        start = "",
        task = "✔ ",
        list = { "●", "➜", "★", "‒" },
      },
      throttle = 20,
    },

    defaults = { lazy = true },

    performance = {
      cache = {
        enabled = true,
        path = vim.fn.stdpath("cache") .. "/lazy/cache",
        ttl = 3600 * 24 * 5,
        disable_events = { "VimEnter", "BufReadPre", "UIEnter" },
      },
      reset_packpath = true,
      rtp = {
        disabled_plugins = {
          "2html_plugin",
          "getscript",
          "getscriptPlugin",
          "gzip",
          "netrw",
          "netrwPlugin",
          "netrwSettings",
          "netrwFileHandlers",
          "logipat",
          "matchit",
          "matchparen",
          "tar",
          "tarPlugin",
          "rrhelper",
          "spellfile_plugin",
          "vimball",
          "vimballPlugin",
          "zip",
          "zipPlugin",
          "logipat",
          "matchit",
          "tutor",
          "rplugin",
          "syntax",
          "synmenu",
          "optwin",
          "compiler",
          "bugreport",
          "ftplugin",
          "archlinux",
          "fzf",
          "tutor_mode_plugin",
          "sleuth",
          "vimgrep"
        },
      },
    },

    install = { colorscheme = { "monochrome" } },
  },
})
