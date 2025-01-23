local lspconfig = require("lspconfig")

local M = {}

-- Configure diagnostics to show inline
vim.diagnostic.config({
  virtual_text = true,      -- Enable inline diagnostics
  signs = true,             -- Show signs in the sign column
  underline = true,         -- Underline the text with an error
  update_in_insert = true,  -- Update diagnostics in insert mode
  severity_sort = true,     -- Sort diagnostics by severity
  float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
  },
})

M.on_attach = function(client, _)
  client.server_capabilities.documentFormattingProvider = true
  client.server_capabilities.documentRangeFormattingProvider = true
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}


local servers = { "pyright", "clangd", "gopls" }

for _, k in ipairs(servers) do
  lspconfig[k].setup {
  }
end

lspconfig.lua_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace"
      },
      diagnostics = {
        globals = { "vim", "awesome", "client", "screen", "mouse", "tag" },
      },
    },
  }
}

return M