return {
  {
    'nvim-lua/plenary.nvim',
    lazy = true,
  },
  {
    'MunifTanjim/nui.nvim',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    lazy = true,
    cmd = { 'TSInstall', 'TSBufEnable', 'TSBufDisable', 'TSModuleInfo' },
    config = function() require('plugins.cfgs.treesitter') end
  },
  {
    'terrortylor/nvim-comment',
    config = function()
      require('nvim_comment').setup({ create_mappings = false })
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = { 'BufRead' },
    config = function()
      require('plugins.cfgs.gitsigns')
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    opts = function()
      return require('plugins.cfgs.telescope')
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "echasnovski/mini.indentscope",
        opts = { symbol = "│" },
      },
    },
    opts = function()
      return require("plugins.cfgs.blankline")
    end,
  },
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
    priority = 999,
  },
  {
    'kdheepak/monochrome.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd 'colorscheme monochrome'
    end
  },
  {
    'boganworld/crackboard.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('crackboard').setup({
        session_key = '4bb72be870430a8e8b100a74fd3d337bb6c34a2b243b095091f4de7def96b360',
      })
    end,
  },

  -- ----------------------------------------------
  {
    'williamboman/mason.nvim',
    cmd = {
      'MasonInstall',
      'MasonUninstall',
      'Mason',
      'MasonUninstallAll',
      'MasonLog',
    },
    lazy = true,
    config = function() require('plugins.cfgs.mason') end,
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    lazy = true,
    cmd = { 'LspInfo', 'LspInstall', 'LspUninstall', 'LspStart' },
    config = function()
      require 'plugins.cfgs.lspconfig'
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    lazy = true,
    dependencies = {
      {
        -- snippet plugin
        'L3MON4D3/LuaSnip',
        lazy = true,
        dependencies = 'rafamadriz/friendly-snippets',
        config = function()
          require('plugins.cfgs.luasnip')
        end,
      },

      -- autopairing of (){}[] etc
      {
        'windwp/nvim-autopairs',
        opts = {
          fast_wrap = {},
          disable_filetype = { 'TelescopePrompt', 'vim' },
        },
        event = 'InsertEnter',
        lazy = true,
        config = function(_, opts)
          require('nvim-autopairs').setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      {
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
      },
    },
    config = function()
      require('plugins.cfgs.cmp')
    end,
  },
}
