local cmp = require("cmp")
-- functionlocal luasnip = require("luasnip")
local WIDE_HEIGHT = 40
local types = require('cmp.types')
local kind_icons = {
  Text = " ",
  Method = "󰆧 ",
  Function = "󰊕 ",
  Constructor = " ",
  Field = "󰇽 ",
  Variable = "󰂡 ",
  Class = "󰠱 ",
  Interface = " ",
  Module = " ",
  Property = "󰜢 ",
  Unit = " ",
  Value = "󰎠 ",
  Enum = " ",
  Keyword = "󰌋 ",
  Snippet = " ",
  Color = "󰏘 ",
  File = "󰈙 ",
  Reference = " ",
  Folder = "󰉋 ",
  EnumMember = " ",
  Constant = "󰏿 ",
  Struct = " ",
  Event = " ",
  Operator = "󰆕 ",
  TypeParameter = "󰅲 ",
}





cmp.setup({
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },


  window = {
    completion = {
      max_width = 30,
      border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenu,CursorLine:CmpPmenuSel,PmenuSbar:CmpPmenuSbar,PmenuThumb:CmpPmenuThumb,Search:None',
      winblend = vim.o.pumblend,
      scrolloff = 0,
      col_offset = 0,
      side_padding = 1,
      scrollbar = false,
    },
    documentation = {
      max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
      max_width = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
      border = "none",
      -- border = { '▛', '▀', '▜', '▐', '▟', '▄', '▙', '▌' },
      winhighlight = 'Normal:CmpDocs,FloatBorder:CmpDocs',
      winblend = vim.o.pumblend,
      col_offset = 0,
      scrollbar = false,
    },
  },



  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
  }),



  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer",  keyword_length = 2 },
  }),



  formatting = {
    fields = { "abbr", "kind" },
    format = function(entry, vim_item)
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      local highlights_info = require("colorful-menu").cmp_highlights(entry)


      if highlights_info ~= nil then
        vim_item.abbr_hl_group = highlights_info.highlights
        vim_item.abbr = highlights_info.text
      end


      return vim_item
    end,
  },



  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },



  completion = {
    autocomplete = {
      types.cmp.TriggerEvent.TextChanged,
    },
    completeopt = 'menu,menuone,noselect',
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
    keyword_length = 1,
  },



  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 100,
    filtering_context_budget = 3,
    async_budget = 5,
    max_view_entries = 200,
  },





  preselect = types.cmp.PreselectMode.Item,
  matching = {
    disallow_fuzzy_matching = false,
    disallow_fullfuzzy_matching = false,
    disallow_partial_fuzzy_matching = true,
    disallow_partial_matching = false,
    disallow_prefix_unmatching = false,
    disallow_symbol_nonprefix_matching = true,
  },



  experimental = {
    ghost_text = false,
  },


  view = {
    entries = {
      name = 'custom',
      selection_order = 'top_down',
      follow_cursor = true,
    },
    docs = {
      auto_open = true,
    },
  },


  confirmation = {
    default_behavior = types.cmp.ConfirmBehavior.Insert,
    get_commit_characters = function(commit_characters)
      return commit_characters
    end,
  },
})
