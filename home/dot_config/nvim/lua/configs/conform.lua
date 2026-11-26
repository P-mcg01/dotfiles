local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
    yaml = { "yamlfmt" },
    terraform = { "terraform_fmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    dockerfile = { "dockerfmt" },
    python = { "ruff_format" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
