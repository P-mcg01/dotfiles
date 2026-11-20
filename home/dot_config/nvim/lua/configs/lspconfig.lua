require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("yamlls", {
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = { enable = false },
      validate = true,
      completion = true,
      hover = true,
      keyOrdering = false,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
    },
  },
})

local servers = {
  "html",
  "cssls",
  "yamlls",
  "gh_actions_ls",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
