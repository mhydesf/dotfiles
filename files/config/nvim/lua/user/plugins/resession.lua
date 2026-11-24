return {
  "stevearc/resession.nvim",
  config = function ()
    local resession = require("resession")
    resession.setup({
      autosave = {
        enabled = true,
        interval = 30,
        notify = false,
      },
    })
    vim.keymap.set("n", "<leader>ss", resession.save, { desc = "Save session" })
    vim.keymap.set("n", "<leader>sl", resession.load, { desc = "Load session" })
    vim.keymap.set("n", "<leader>sD", resession.delete, { desc = "Delete session" })
  end,
}
