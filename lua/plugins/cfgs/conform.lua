require("conform").setup({
  formatters_by_ft = {
    nix = { "nixfmt" },
    lua = { "stylua" },
    swift = { "swift_format" },
  },
  format_on_save = function(bufnr)
    if vim.bo[bufnr].buftype ~= "" then
      return nil
    end

    return {
      timeout_ms = 500,
      lsp_format = "fallback",
    }
  end,
  notify_no_formatters = false,
})
