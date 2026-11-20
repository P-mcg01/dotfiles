return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local lint = require "lint"

    lint.linters_by_ft = {
      yaml = { "yamllint" },
    }

    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
