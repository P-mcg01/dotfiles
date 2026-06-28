require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "terraformls", "ansiblels", "bashls", "yamlls", "docker_language_server", "hyprls"}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
