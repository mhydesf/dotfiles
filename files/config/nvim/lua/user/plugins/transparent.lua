return {
  "xiyaowong/nvim-transparent",
  config = function()
    local transparent = require("transparent")
    transparent.setup()
    transparent.clear_prefix("NvimTree")
    vim.keymap.set("n", "<leader>tt", "<cmd>TransparentToggle<CR>", { desc = "Toggle transparency" })
  end,
}
