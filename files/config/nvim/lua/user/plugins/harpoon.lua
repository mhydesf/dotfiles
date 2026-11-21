return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").load_extension("harpoon")
    require("harpoon").setup({
      menu = {
        width = math.max(60, vim.o.columns - 80),
      },
    })
    vim.keymap.set("n", "<leader>sm", "<cmd>Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
    vim.keymap.set("n", "<leader>m", function()
      require("harpoon.mark").add_file()
    end, { desc = "Harpoon mark file" })
    vim.keymap.set("n", "<leader>hh", function()
      require("harpoon.ui").toggle_quick_menu()
    end, { desc = "Harpoon quick menu" })
  end,
}
