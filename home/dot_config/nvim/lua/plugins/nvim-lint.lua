return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },

  config = function()
    local lint = require "lint"

    --[[
    --  LINTERS BY FILETYPE
    --]]
    lint.linters_by_ft = {
      yaml = { "yamllint" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dockerfile = { "hadolint" },
      ["yaml.ansible"] = {
        "yamllint",
        "ansible_lint",
      },
    }

    --[[
    --  GITHUB ACTIONS
    --]]
    local function is_github_workflow(bufnr)
      local path = vim.api.nvim_buf_get_name(bufnr):gsub("\\", "/")
      return path:match "/%.github/workflows/[^/]+%.ya?ml$" ~= nil
    end

    local function run_lint(bufnr)
      local names = vim.deepcopy(lint.linters_by_ft[vim.bo[bufnr].filetype] or {})

      if is_github_workflow(bufnr) then
        table.insert(names, "actionlint")
      end

      if #names > 0 then
        lint.try_lint(names)
      end
    end

    --[[
    --  AUTOCMD
    --]]
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function(args)
        run_lint(args.buf)
      end,
    })
  end,
}
