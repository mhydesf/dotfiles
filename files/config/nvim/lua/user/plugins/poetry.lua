return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    { "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  ft = "python",
  keys = { { "<leader>v", "<cmd>VenvSelect<cr>" } }, -- Open picker on keymap
  opts = {
    options = {
      override_notify = false,
      picker = "telescope",
    },
    search = {}
  },
}
