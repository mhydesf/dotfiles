return {
  "rmagatti/goto-preview",
  config = function()
    local goto_preview = require("goto-preview")

    local function open_preview_in_current_window(buf, win)
      local cursor = vim.api.nvim_win_get_cursor(win)
      vim.api.nvim_win_close(win, true)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.api.nvim_set_current_buf(buf)
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
      end)
    end

    goto_preview.setup({
      width = 120, -- Width of the floating window
      height = 25, -- Height of the floating window
      border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" }, -- Border characters of the floating window
      default_mappings = true,
      debug = false,
      opacity = 10, -- 0-100 opacity level of the floating window where 100 is fully transparent.
      resizing_mappings = true,
      post_open_hook = function(buf, win)
        vim.keymap.set("n", "gpf", function()
          if vim.api.nvim_get_current_win() ~= win then
            return
          end
          open_preview_in_current_window(buf, win)
        end, { buffer = buf, desc = "Open preview target in current window" })
      end,
      post_close_hook = function(buf)
        pcall(vim.keymap.del, "n", "gpf", { buffer = buf })
      end,
      references = {
        telescope = require("telescope.themes").get_dropdown({ hide_preview = false }),
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
      bufhidden = "wipe",
      stack_floating_preview_windows = true,
      preview_window_title = { enable = true, position = "left" },
    })

    -- gpd = goto_preview_definition()
    -- gpt = goto_preview_type_definition()
    -- gpi = goto_preview_implementation()
    -- gpr = goto_preview_references()
    -- gP  = close_all_win()
    -- gpf = open preview target in current window
  end,
}
