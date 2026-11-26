require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("yamlls", {
  filetypes = {
    "yaml",
    "yaml.ansible",
  },
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

vim.lsp.config("ansiblels", {
  ansible = {
    ansible = {
      path = "ansible",
    },
    executionEnvironment = {
      enabled = false,
    },
    python = {
      interpreterPath = "python3",
    },
    validation = {
      enabled = true,
      lint = {
        enabled = false,
      },
    },
  },
})

local servers = {
  "html",
  "cssls",
  "yamlls",
  "gh_actions_ls",
  "bashls",
  "ansiblels",
}

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
