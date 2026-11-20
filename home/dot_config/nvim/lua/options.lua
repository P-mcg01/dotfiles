require "nvchad.options"

vim.filetype.add {
  filename = { Containerfile = "dockerfile" },
  pattern = {
    ["Containerfile%..*"] = "dockerfile",
    [".*%.containerfile"] = "dockerfile",
  },
}

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
