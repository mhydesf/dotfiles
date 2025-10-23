return {
  "Civitasv/cmake-tools.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    require("cmake-tools").setup({
      cmake_regenerate_on_save = false,
      cmake_build_directory = "build",
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.loop.cwd() .. "/build",
      },
      cmake_virtual_text_support = false,
    })

    vim.keymap.set('n', '<leader>mp', '<cmd>CMakeSelectConfigurePreset<CR>')
    vim.keymap.set('n', '<leader>mc', '<cmd>CMakeSelectBuildPreset<CR>')
    vim.keymap.set('n', '<leader>mb', '<cmd>CMakeBuild<CR>')
    vim.keymap.set('n', '<leader>mt', '<cmd>CMakeSelectBuildTarget<CR>')
    vim.keymap.set('n', '<leader>mx', '<cmd>CMakeClean<CR>')
  end,
}
