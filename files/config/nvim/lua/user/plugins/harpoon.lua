return {
	'ThePrimeagen/harpoon',
	config = function()
		require("telescope").load_extension('harpoon')
    require("harpoon").setup({
      menu = {
        width = vim.api.nvim_win_get_width(0) - 80,
      }
    })
		vim.keymap.set('n', '<leader>sm', ":Telescope harpoon marks<CR>", { desc = 'Harpoon [M]arks' })
		vim.api.nvim_set_keymap("n", "<leader>m", ":lua require('harpoon.mark').add_file()<CR>", {noremap=true})
		vim.api.nvim_set_keymap("n", "<leader>hh", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", {noremap=true})
	end
}
