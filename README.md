<h1 align="center">moon</h1>

![Dashboard](.github/dashboard.png)
![Editor](.github/nvim.png)

### Plugins

| Plugin (21 plugs)                                                                    | Description                                                    | 
| ------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| [lazy](https://github.com/folke/lazy.nvim)                                      | the package manager for newbies                                |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | syntax highlighting, most popular one for neovim               |
| [alpha-nvim](https://github.com/goolord/alpha-nvim)                           | a lua powered greeter like vim-startify / dashboard-nvim       |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)         | more devicons for neovim                                       |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)     | probably the most popular menu. can be used for a lot of stuff |
| [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)                 | terminal integration in neovim                                 |
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)                 | installing LSPs made super easy                                |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)                     | the most popular LSP client for neovim                         |
| [hrsh7th/nvim-cmp](https:://github.com/hrsh7th/nvim-cmp)                              | autocompletion plugin for neovim                               |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)                               | very simple and easy to use snippet engine                     |
| [lukas-reineke/indent-blankline.nvim](https:://github.com/lukas-reineke/indent-blankline.nvim)| shows indent lines in neovim                           |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)                     | quik and easy commenting                                       |

### File Structure
```
.
├── init.lua
├── lazy-lock.json
└── lua
    ├── core
    │   ├── dashboard.lua
    │   ├── init.lua
    │   ├── keys.lua
    │   └── opts.lua
    ├── plugs
    │   ├── configs
    │   │   ├── blankline.lua
    │   │   ├── devicons.lua
    │   │   ├── telescope.lua
    │   │   ├── toggleterm.lua
    │   │   └── treesitter.lua
    │   ├── init.lua
    │   ├── lsp
    │   │   ├── cmp.lua
    │   │   ├── lsp-zero.lua
    │   │   └── mason.lua
    │   ├── plugins.lua
    │   ├── strap.lua
    │   └── ui
    │       └── alpha.lua
    └── ui
        └── statusline
            ├── colors.lua
            ├── components
            │   ├── branch.lua
            │   ├── diagnostics.lua
            │   ├── file.lua
            │   ├── mode.lua
            │   └── saved.lua
            ├── init.lua
            └── utils.lua

10 directories, 26 files
```
