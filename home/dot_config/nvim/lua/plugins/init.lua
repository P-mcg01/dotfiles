return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "yaml",
        "bash",
        "dockerfile",
        "markdown",
        "markdown_inline",
        "json",
        "ini",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "yaml-language-server",
        "yamlfmt",
        "yamllint",
        "gh-actions-language-server",
        "actionlint",
        "bash-language-server",
        "shfmt",
        "shellcheck",
        "hadolint",
        "dockerfile-language-server",
        "dockerfmt",
        "ansiblels",
        "ansible-lint",
        "basedpyright",
        "ruff",
      },
    },
  },
}
