local Theme = {}

Theme.config = {
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = false,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
}

local function get_palette()
  local palette = require("ui.colorschemes.palette")
  local p = vim.tbl_deep_extend("force", {}, palette.get())

  for key, hex in pairs(Theme.config.palette_overrides) do
    p[key] = hex
  end

  return p
end

local function set_terminal_colors()
  if not Theme.config.terminal_colors then
    return
  end

  local raw = require("ui.colorschemes.palette").raw()
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = raw["color" .. i]
  end
end

local function get_groups()
  local colors = get_palette()
  local config = Theme.config
  local palette = require("ui.colorschemes.palette")
  local sel_bg = palette.dim(colors.blue, 60)

  set_terminal_colors()

  local function sign_color(color)
    if config.transparent_mode then
      return { fg = color }
    end
    return { fg = color, bg = colors.bg1 }
  end

  local groups = {
    hlFg0 = { fg = colors.fg0 },
    hlFg1 = { fg = colors.fg1 },
    hlFg2 = { fg = colors.fg2 },
    hlFg3 = { fg = colors.fg3 },
    hlFg4 = { fg = colors.fg4 },
    hlGray = { fg = colors.gray },
    hlBg0 = { fg = colors.bg0 },
    hlBg1 = { fg = colors.bg1 },
    hlBg2 = { fg = colors.bg2 },
    hlBg3 = { fg = colors.bg3 },
    hlBg4 = { fg = colors.bg4 },
    hlWhite = { fg = colors.white },
    hlRed = { fg = colors.red },
    hlRedBold = { fg = colors.red, bold = config.bold },
    hlGreen = { fg = colors.green },
    hlGreenBold = { fg = colors.green, bold = config.bold },
    hlYellow = { fg = colors.yellow },
    hlYellowBold = { fg = colors.yellow, bold = config.bold },
    hlBlue = { fg = colors.blue },
    hlBlueBold = { fg = colors.blue, bold = config.bold },
    hlPurple = { fg = colors.purple },
    hlPurpleBold = { fg = colors.purple, bold = config.bold },
    hlAqua = { fg = colors.aqua },
    hlAquaBold = { fg = colors.aqua, bold = config.bold },
    hlOrange = { fg = colors.orange },
    hlOrangeBold = { fg = colors.orange, bold = config.bold },
    hlRedSign = sign_color(colors.red),
    hlGreenSign = sign_color(colors.green),
    hlYellowSign = sign_color(colors.yellow),
    hlBlueSign = sign_color(colors.blue),
    hlPurpleSign = sign_color(colors.purple),
    hlAquaSign = sign_color(colors.aqua),
    hlOrangeSign = sign_color(colors.orange),
    hlRedUnderline = { undercurl = config.undercurl, sp = colors.red },
    hlGreenUnderline = { undercurl = config.undercurl, sp = colors.green },
    hlYellowUnderline = { undercurl = config.undercurl, sp = colors.yellow },
    hlBlueUnderline = { undercurl = config.undercurl, sp = colors.blue },
    hlPurpleUnderline = { undercurl = config.undercurl, sp = colors.purple },
    hlAquaUnderline = { undercurl = config.undercurl, sp = colors.aqua },
    hlOrangeUnderline = { undercurl = config.undercurl, sp = colors.orange },

    Normal = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg0 },
    NormalFloat = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg1 },
    NormalNC = config.dim_inactive and { fg = colors.fg0, bg = colors.bg1 } or { link = "Normal" },
    ColorColumn = { bg = colors.bg1 },
    CursorLine = { bg = colors.bg1 },
    CursorColumn = { link = "CursorLine" },
    CursorLineNr = { fg = colors.blue, bg = colors.bg0, bold = config.bold },
    Conceal = { fg = colors.blue },
    LineNr = { fg = colors.bg4 },
    SignColumn = config.transparent_mode and { bg = nil } or { bg = colors.bg0 },
    Folded = { fg = colors.gray, bg = colors.bg1, italic = config.italic.folds },
    FoldColumn = config.transparent_mode and { fg = colors.gray, bg = nil } or { fg = colors.gray, bg = colors.bg1 },
    Cursor = { fg = colors.bg0, bg = colors.fg1 },
    vCursor = { link = "Cursor" },
    iCursor = { link = "Cursor" },
    lCursor = { link = "Cursor" },
    Visual = { bg = colors.bg3 },
    VisualNOS = { link = "Visual" },
    Search = { fg = colors.yellow, bg = colors.bg0 },
    IncSearch = { fg = colors.orange, bg = colors.bg0 },
    CurSearch = { link = "IncSearch" },
    MatchParen = { bg = colors.bg3, bold = config.bold },
    QuickFixLine = { link = "hlPurple" },
    Underlined = { fg = colors.blue, underline = config.underline },
    NonText = { link = "hlBg2" },
    SpecialKey = { link = "hlFg4" },

    TabLineFill = { fg = colors.bg2, bg = colors.bg0 },
    TabLineSel = { fg = colors.fg0, bg = colors.bg1, bold = config.bold },
    TabLine = { link = "TabLineFill" },

    StatusLine = { fg = colors.bg2, bg = colors.fg1 },
    StatusLineNC = { fg = colors.bg1, bg = colors.fg4 },
    WinBar = { fg = colors.fg4, bg = colors.bg0 },
    WinBarNC = { fg = colors.fg3, bg = colors.bg1 },
    WinSeparator = config.transparent_mode and { fg = colors.bg3, bg = nil } or { fg = colors.bg3, bg = colors.bg0 },
    WildMenu = { fg = colors.blue, bg = colors.bg2, bold = config.bold },
    FloatBorder = { fg = colors.blue, bg = config.transparent_mode and nil or colors.bg1 },
    FloatTitle = { fg = colors.blue, bg = config.transparent_mode and nil or colors.bg1, bold = true },

    Directory = { link = "hlGreenBold" },
    Title = { link = "hlGreenBold" },
    ErrorMsg = { fg = colors.bg0, bg = colors.red, bold = config.bold },
    MoreMsg = { link = "hlYellowBold" },
    ModeMsg = { link = "hlYellowBold" },
    Question = { link = "hlOrangeBold" },
    WarningMsg = { link = "hlRedBold" },

    Comment = { fg = colors.gray, italic = config.italic.comments },
    Todo = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, italic = config.italic.comments },
    Error = { fg = colors.red, bold = config.bold },
    Statement = { link = "hlRed" },
    Conditional = { link = "hlRed" },
    Repeat = { link = "hlRed" },
    Label = { link = "hlRed" },
    Operator = { fg = colors.orange, italic = config.italic.operators },
    Keyword = { link = "hlRed" },
    Exception = { link = "hlRed" },
    Identifier = { link = "hlBlue" },
    Function = { link = "hlGreenBold" },
    PreProc = { link = "hlAqua" },
    Include = { link = "hlAqua" },
    Define = { link = "hlAqua" },
    Macro = { link = "hlAqua" },
    PreCondit = { link = "hlAqua" },
    Constant = { link = "hlPurple" },
    Character = { link = "hlPurple" },
    String = { fg = colors.green, italic = config.italic.strings },
    Boolean = { link = "hlPurple" },
    Number = { link = "hlPurple" },
    Float = { link = "hlPurple" },
    Type = { link = "hlYellow" },
    StorageClass = { link = "hlOrange" },
    Structure = { link = "hlAqua" },
    Typedef = { link = "hlYellow" },
    Special = { link = "hlOrange" },
    SpecialChar = { link = "hlOrange" },
    Delimiter = { link = "hlBlue" },
    SpecialComment = { link = "hlAqua" },
    Debug = { link = "hlRed" },
    Tag = { link = "hlBlue" },

    SpellCap = { link = "hlBlueUnderline" },
    SpellBad = { link = "hlRedUnderline" },
    SpellLocal = { link = "hlAquaUnderline" },
    SpellRare = { link = "hlPurpleUnderline" },

    Pmenu = { fg = colors.fg1, bg = colors.bg1 },
    PmenuSel = { fg = colors.white, bg = sel_bg, bold = true },
    PmenuKindSel = { fg = colors.white, bg = sel_bg, bold = true },
    PmenuSbar = { bg = colors.bg1 },
    PmenuThumb = { bg = sel_bg },

    DiffAdd = { fg = colors.green, bg = colors.bg1 },
    DiffChange = { fg = colors.aqua, bg = colors.bg1 },
    DiffDelete = { fg = colors.red, bg = colors.bg1 },
    DiffText = { fg = colors.yellow, bg = colors.bg1, bold = config.bold },
    diffAdded = { link = "DiffAdd" },
    diffChanged = { link = "DiffChange" },
    diffRemoved = { link = "DiffDelete" },

    DiagnosticError = { link = "hlRed" },
    DiagnosticWarn = { link = "hlYellow" },
    DiagnosticInfo = { link = "hlBlue" },
    DiagnosticHint = { link = "hlAqua" },
    DiagnosticSignError = { fg = colors.red, bg = config.transparent_mode and nil or colors.bg0 },
    DiagnosticSignWarn = { fg = colors.yellow, bg = config.transparent_mode and nil or colors.bg0 },
    DiagnosticSignInfo = { fg = colors.blue, bg = config.transparent_mode and nil or colors.bg0 },
    DiagnosticSignHint = { fg = colors.aqua, bg = config.transparent_mode and nil or colors.bg0 },
    DiagnosticUnderlineError = { link = "hlRedUnderline" },
    DiagnosticUnderlineWarn = { link = "hlYellowUnderline" },
    DiagnosticUnderlineInfo = { link = "hlBlueUnderline" },
    DiagnosticUnderlineHint = { link = "hlAquaUnderline" },
    DiagnosticFloatingError = { link = "hlRed" },
    DiagnosticFloatingWarn = { link = "hlOrange" },
    DiagnosticFloatingInfo = { link = "hlBlue" },
    DiagnosticFloatingHint = { link = "hlAqua" },
    DiagnosticVirtualTextError = { fg = colors.red, bg = colors.bg1 },
    DiagnosticVirtualTextWarn = { fg = colors.yellow, bg = colors.bg1 },
    DiagnosticVirtualTextInfo = { fg = colors.blue, bg = colors.bg1 },
    DiagnosticVirtualTextHint = { fg = colors.aqua, bg = colors.bg1 },
    DiagnosticOk = { link = "hlGreenSign" },
    LspReferenceRead = { link = "hlYellowBold" },
    LspReferenceText = { link = "hlYellowBold" },
    LspReferenceWrite = { link = "hlOrangeBold" },
    LspCodeLens = { link = "hlGray" },
    LspInlayHint = { fg = colors.gray, bg = colors.bg1, italic = true },

    GitSignsAdd = { link = "hlGreen" },
    GitSignsChange = { link = "hlOrange" },
    GitSignsDelete = { link = "hlRed" },

    TelescopeNormal = { link = "NormalFloat" },
    TelescopeBorder = { link = "FloatBorder" },
    TelescopePrompt = { link = "NormalFloat" },
    TelescopePromptBorder = { link = "FloatBorder" },
    TelescopeResultsBorder = { link = "FloatBorder" },
    TelescopePreviewBorder = { link = "FloatBorder" },
    TelescopeSelection = { bg = colors.bg2, bold = config.bold },
    TelescopeSelectionCaret = { fg = colors.red },
    TelescopeMultiSelection = { fg = colors.gray },
    TelescopeMatching = { fg = colors.blue, bold = config.bold },
    TelescopePromptPrefix = { fg = colors.red },

    CmpPmenu = { fg = colors.fg1, bg = colors.bg2 },
    CmpPmenuSel = { fg = colors.white, bg = sel_bg, bold = true },
    CmpPmenuSbar = { bg = colors.bg2 },
    CmpPmenuThumb = { bg = sel_bg },
    CmpDocs = { fg = colors.fg1, bg = colors.bg2 },
    CmpItemAbbr = { fg = colors.fg0 },
    CmpItemAbbrDeprecated = { fg = colors.fg3, strikethrough = true },
    CmpItemAbbrMatch = { link = "hlBlueBold" },
    CmpItemAbbrMatchFuzzy = { link = "hlBlueUnderline" },
    CmpItemMenu = { link = "hlGray" },
    CmpItemMenuBuffer = { link = "CmpItemMenu" },
    CmpItemMenuNvimLsp = { link = "CmpItemMenu" },
    CmpItemMenuLuasnip = { link = "CmpItemMenu" },
    CmpItemMenuNvimLua = { link = "CmpItemMenu" },
    CmpItemMenuLatexSymbols = { link = "CmpItemMenu" },
    CmpItemMenuTreesitter = { link = "CmpItemMenu" },
    CmpItemMenuFish = { link = "CmpItemMenu" },
    CmpItemMenuAi = { link = "CmpItemMenu" },
    CmpItemKindText = { link = "hlOrange" },
    CmpItemKindVariable = { link = "hlOrange" },
    CmpItemKindMethod = { link = "hlBlue" },
    CmpItemKindFunction = { link = "hlBlue" },
    CmpItemKindConstructor = { link = "hlYellow" },
    CmpItemKindUnit = { link = "hlBlue" },
    CmpItemKindField = { link = "hlBlue" },
    CmpItemKindClass = { link = "hlYellow" },
    CmpItemKindInterface = { link = "hlYellow" },
    CmpItemKindModule = { link = "hlBlue" },
    CmpItemKindProperty = { link = "hlBlue" },
    CmpItemKindValue = { link = "hlOrange" },
    CmpItemKindEnum = { link = "hlYellow" },
    CmpItemKindOperator = { link = "hlYellow" },
    CmpItemKindKeyword = { link = "hlPurple" },
    CmpItemKindEvent = { link = "hlPurple" },
    CmpItemKindReference = { link = "hlPurple" },
    CmpItemKindColor = { link = "hlPurple" },
    CmpItemKindSnippet = { link = "hlGreen" },
    CmpItemKindFile = { link = "hlBlue" },
    CmpItemKindFolder = { link = "hlBlue" },
    CmpItemKindEnumMember = { link = "hlAqua" },
    CmpItemKindConstant = { link = "hlOrange" },
    CmpItemKindStruct = { link = "hlYellow" },
    CmpItemKindTypeParameter = { link = "hlYellow" },

    IblIndent = { fg = colors.bg4 },
    IblScope = { fg = colors.bg2 },
    MiniIndentscopeSymbol = { fg = colors.bg2 },
    MiniIndentscopeSymbolOff = { fg = colors.bg3 },

    MyFloatBorder = { fg = colors.blue, bg = "NONE", bold = true },
    MyFloatTitle = { fg = colors.blue, bg = colors.bg1, bold = true },
    MyTerminalBackground = { bg = colors.bg1 },
    MySearchBackground = { fg = colors.white, bg = colors.bg1 },
    MyCmdLineTitle = { fg = colors.blue, bg = colors.bg1, bold = true },

    ["@comment"] = { link = "Comment" },
    ["@none"] = { bg = "NONE", fg = "NONE" },
    ["@preproc"] = { link = "PreProc" },
    ["@define"] = { link = "Define" },
    ["@operator"] = { link = "Operator" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { link = "hlOrange" },
    ["@punctuation.special"] = { link = "Delimiter" },
    ["@string"] = { link = "String" },
    ["@string.regex"] = { link = "String" },
    ["@string.regexp"] = { link = "String" },
    ["@string.escape"] = { link = "SpecialChar" },
    ["@string.special"] = { link = "SpecialChar" },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@boolean"] = { link = "Boolean" },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@float"] = { link = "Float" },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { link = "Special" },
    ["@function.call"] = { link = "Function" },
    ["@function.macro"] = { link = "Macro" },
    ["@function.method"] = { link = "Function" },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { link = "Function" },
    ["@constructor"] = { link = "Special" },
    ["@parameter"] = { link = "Identifier" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.conditional"] = { link = "Conditional" },
    ["@keyword.debug"] = { link = "Debug" },
    ["@keyword.directive"] = { link = "PreProc" },
    ["@keyword.directive.define"] = { link = "Define" },
    ["@keyword.exception"] = { link = "Exception" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.operator"] = { link = "hlRed" },
    ["@keyword.repeat"] = { link = "Repeat" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@keyword.storage"] = { link = "StorageClass" },
    ["@conditional"] = { link = "Conditional" },
    ["@repeat"] = { link = "Repeat" },
    ["@debug"] = { link = "Debug" },
    ["@label"] = { link = "Label" },
    ["@include"] = { link = "Include" },
    ["@exception"] = { link = "Exception" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Typedef" },
    ["@type.qualifier"] = { link = "Type" },
    ["@storageclass"] = { link = "StorageClass" },
    ["@attribute"] = { link = "PreProc" },
    ["@field"] = { link = "Identifier" },
    ["@property"] = { link = "Identifier" },
    ["@variable"] = { link = "hlPurple" },
    ["@variable.builtin"] = { link = "Special" },
    ["@variable.member"] = { link = "Identifier" },
    ["@variable.parameter"] = { link = "Identifier" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Special" },
    ["@constant.macro"] = { link = "Define" },
    ["@markup"] = { link = "hlFg1" },
    ["@markup.strong"] = { bold = config.bold },
    ["@markup.italic"] = { italic = config.italic.emphasis },
    ["@markup.underline"] = { underline = config.underline },
    ["@markup.strikethrough"] = { strikethrough = config.strikethrough },
    ["@markup.heading"] = { link = "Title" },
    ["@markup.raw"] = { link = "String" },
    ["@markup.math"] = { link = "Special" },
    ["@markup.link"] = { link = "Underlined" },
    ["@markup.list"] = { link = "Delimiter" },
    ["@comment.todo"] = { link = "Todo" },
    ["@comment.note"] = { link = "SpecialComment" },
    ["@comment.warning"] = { link = "WarningMsg" },
    ["@comment.error"] = { link = "ErrorMsg" },
    ["@diff.plus"] = { link = "diffAdded" },
    ["@diff.minus"] = { link = "diffRemoved" },
    ["@diff.delta"] = { link = "diffChanged" },
    ["@module"] = { link = "hlFg1" },
    ["@namespace"] = { link = "hlFg1" },
    ["@symbol"] = { link = "Identifier" },
    ["@text"] = { link = "hlFg1" },
    ["@text.strong"] = { bold = config.bold },
    ["@text.emphasis"] = { italic = config.italic.emphasis },
    ["@text.underline"] = { underline = config.underline },
    ["@text.strike"] = { strikethrough = config.strikethrough },
    ["@text.title"] = { link = "Title" },
    ["@text.literal"] = { link = "String" },
    ["@text.uri"] = { link = "Underlined" },
    ["@text.math"] = { link = "Special" },
    ["@text.reference"] = { link = "Constant" },
    ["@text.todo"] = { link = "Todo" },
    ["@text.note"] = { link = "SpecialComment" },
    ["@text.warning"] = { link = "WarningMsg" },
    ["@text.danger"] = { link = "ErrorMsg" },
    ["@text.diff.add"] = { link = "diffAdded" },
    ["@text.diff.delete"] = { link = "diffRemoved" },
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { link = "Identifier" },
    ["@tag.delimiter"] = { link = "Delimiter" },
    ["@punctuation"] = { link = "Delimiter" },
    ["@macro"] = { link = "Macro" },
    ["@structure"] = { link = "Structure" },
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = { link = "@comment" },
    ["@lsp.type.decorator"] = { link = "@macro" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.interface"] = { link = "@constructor" },
    ["@lsp.type.macro"] = { link = "@macro" },
    ["@lsp.type.method"] = { link = "@method" },
    ["@lsp.type.modifier.java"] = { link = "@keyword.type.java" },
    ["@lsp.type.namespace"] = { link = "@namespace" },
    ["@lsp.type.parameter"] = { link = "@parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeParameter"] = { link = "@type.definition" },
    ["@lsp.type.variable"] = { link = "@variable" },
  }

  for group, hl in pairs(config.overrides) do
    if groups[group] then
      groups[group].link = nil
    end
    groups[group] = vim.tbl_extend("force", groups[group] or {}, hl)
  end

  return groups
end

Theme.load = function()
  if vim.version().minor < 8 then
    vim.notify_once("you must use neovim 0.8 or higher")
    return
  end

  if vim.g.colors_name then
    vim.cmd.hi("clear")
  end

  vim.g.colors_name = "hlscheme"
  vim.o.termguicolors = true

  local groups = get_groups()
  for group, settings in pairs(groups) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

return Theme
