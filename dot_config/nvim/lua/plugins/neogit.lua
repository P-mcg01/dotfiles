return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim", -- optional
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
  }
}
