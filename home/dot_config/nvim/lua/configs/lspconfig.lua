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

vim.lsp.config("bashls", {
  settings = {
    bashIde = {
      shellcheckPath = "",
    },
  },
  on_attach = function(client, _)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

vim.lsp.config("dockerls", {
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
})

local servers = {
  "html",
  "cssls",
  "yamlls",
  "gh_actions_ls",
  "bashls",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
