return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && npm install",
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 0

    -- Add keymap to run markdown-toc on current markdown file
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.keymap.set("n", "<leader>mt", function()
          vim.cmd("w")                             -- Save file
          vim.cmd("!markdown-toc -i %")            -- Run markdown-toc in-place
          vim.cmd("e")                             -- Reload buffer
        end, { buffer = true, desc = "Update Markdown TOC" })
      end,
    })
  end,
}
