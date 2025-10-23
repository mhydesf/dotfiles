return {
	"folke/noice.nvim",
	config = function()
		require("noice").setup({
			-- add any options here
			-- routes = {
			--   {
			--     view = "notify",
			--     filter = { event = "msg_showmode" },
			--   },
			-- },
		})

		vim.keymap.set("n", "<leader>dn", function()
			require("noice").cmd("dismiss")
		end, { desc = "Dismiss Noice notifications" })
	end,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	}
}
