return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup {
      signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '-' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "<leader>nc", function()
          if vim.wo.diff then return "<leader>nc" end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, {expr=true})

        map("n", "<leader>pc", function()
          if vim.wo.diff then return "<leader>pc" end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, {expr=true})

        -- Actions
        map("n", "<leader>bt", gs.toggle_current_line_blame)
      end
    }
	end
}
