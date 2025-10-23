return {
  "github/copilot.vim",
  config = function()
    -- Disable the default <Tab> mapping
    vim.g.copilot_no_tab_map = true

    -- Custom keymap to accept Copilot suggestion
    vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Accept("<CR>")', {
      expr = true,
      silent = true,
      script = true,
      noremap = true,
    })
    vim.api.nvim_set_keymap("i", "<C-k>", 'copilot#Next()', {
      expr = true,
      silent = true,
      script = true,
      noremap = true,
    })
    vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Previous()', {
      expr = true,
      silent = true,
      script = true,
      noremap = true,
    })
  end,
}
