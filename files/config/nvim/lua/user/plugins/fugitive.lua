return {
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gcb", ":Git checkout ")
    vim.keymap.set("n", "<leader>gnb", ":Git checkout -b ")
    vim.keymap.set("n", "<leader>gc", ':Git commit -m "')
    vim.keymap.set("n", "<leader>gp", "<cmd>Git push -u origin HEAD<CR>")
    vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>")
    vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>")
  end,
}
