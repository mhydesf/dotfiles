return {
  "ThePrimeagen/git-worktree.nvim",
  config = function()
    require("git-worktree").setup()
    require("telescope").load_extension("git_worktree")
    vim.keymap.set("n", "<leader>sr", function()
      require("telescope").extensions.git_worktree.git_worktrees()
    end, { desc = "Switch git worktree" })
    vim.keymap.set("n", "<leader>sR", function()
      require("telescope").extensions.git_worktree.create_git_worktree()
    end, { desc = "Create git worktree" })
  end,
}
