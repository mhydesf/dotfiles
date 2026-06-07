return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    'smartpde/telescope-recent-files',
    'nvim-telescope/telescope-ui-select.nvim',  -- ← add this
  },
  config = function()
    local telescope = require('telescope')
    local themes    = require('telescope.themes')
    local actions   = require('telescope.actions')
    local action_state = require("telescope.actions.state")

    local function smart_tab(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      if picker.sorting_strategy == "ascending" then
        actions.move_selection_next(prompt_bufnr)
      else
        actions.move_selection_previous(prompt_bufnr)
      end
    end

    local function smart_s_tab(prompt_bufnr)
      local picker = action_state.get_current_picker(prompt_bufnr)
      if picker.sorting_strategy == "ascending" then
        actions.move_selection_previous(prompt_bufnr)
      else
        actions.move_selection_next(prompt_bufnr)
      end
    end

    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--no-ignore",
        },
        mappings = {
          i = {
            ["<Tab>"]   = smart_tab,
            ["<S-Tab>"] = smart_s_tab,
          },
          n = {
            ["<Tab>"]   = smart_tab,
            ["<S-Tab>"] = smart_s_tab,
          },
        },
      },
      pickers = {
        find_files = {
          no_ignore = true,
        },
        git_status = {
          mappings = {
            i = {
              ["<Tab>"]   = actions.move_selection_previous,
              ["<S-Tab>"] = actions.move_selection_next,
              ["<C-Space>"] = actions.toggle_selection,
            },
            n = {
              ["<Tab>"]   = actions.move_selection_previous,
              ["<S-Tab>"] = actions.move_selection_next,
              ["<C-Space>"] = actions.toggle_selection,
            },
          },
        },
      },
      extensions = {
        undo = {
          use_delta = true,
          mappings = {},
        },
        ["ui-select"] = themes.get_dropdown({
          previewer = false,
          sorting_strategy = "ascending",
          layout_config = {
            width  = 0.6,
            height = 0.55,
          },
        }),
      },
    })

    -- load extensions
    pcall(telescope.load_extension, 'fzf')
    telescope.load_extension('undo')
    telescope.load_extension('recent_files')
    telescope.load_extension('ui-select')   -- ← important

    -- your keymaps (unchanged)
    vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>fd', ":Telescope find_files hidden=true<CR>", { desc = '[S]earch [D]otfiles' })
    vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>fc', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>fs', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>fg', require('telescope.builtin').git_status, { desc = '' })
    vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set("n", "<leader>u", ":Telescope undo<CR>")
    vim.keymap.set('n', '<leader>sb', function()
      require('telescope.builtin').current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer]' })
  end,

}
