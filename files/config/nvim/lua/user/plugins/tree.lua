return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function ()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      disable_netrw = true,
      sync_root_with_cwd = true,
      view = {
        width = 30,
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
      actions = {
        remove_file = {
          close_window = true,
        }
      },
      renderer = {
        highlight_git = true,
        root_folder_modifier = ":t",
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            git = {
              unstaged = "󰍶",
              staged = "",
              unmerged = "",
              renamed = "➜",
              untracked = "",
              deleted = "",
              ignored = "◌",
            },
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
            },
          },
        },
      },
    })
    local function apply_tree_highlights()
      local set_hl = vim.api.nvim_set_hl
      local text_fg = "#D0D0D8"

      set_hl(0, "NvimTreeIndentMarker", { fg = "#3FC5FF" })
      set_hl(0, "NvimTreeNormal", { fg = text_fg })
      set_hl(0, "NvimTreeNormalNC", { fg = text_fg })

      set_hl(0, "NvimTreeFolderName", { fg = text_fg })
      set_hl(0, "NvimTreeEmptyFolderName", { fg = text_fg })
      set_hl(0, "NvimTreeSymlinkFolderName", { fg = text_fg })
      set_hl(0, "NvimTreeOpenedFolderName", { fg = text_fg })

      local git_colors = {
        Deleted = "#F26D7A",
        Dirty = "#6DB7A9",
        Ignored = "#5C5F6B",
        Merge = "#E7A26C",
        New = "#F3C972",
        Renamed = "#F08D67",
        Staged = "#7CCB8F",
      }

      for status, color in pairs(git_colors) do
        local base = "NvimTreeGit" .. status
        set_hl(0, base, { fg = color })
        set_hl(0, base .. "Icon", { fg = color })
        set_hl(0, "NvimTreeGitFile" .. status .. "HL", { fg = color })
        set_hl(0, "NvimTreeGitFolder" .. status .. "HL", { fg = color })
      end
    end

    apply_tree_highlights()
    local highlight_group = vim.api.nvim_create_augroup("my.nvimtree.highlights", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = highlight_group,
      callback = function()
        vim.schedule(apply_tree_highlights) -- colorscheme load can reset custom highlights
      end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      group = highlight_group,
      pattern = "NvimTree",
      callback = function()
        vim.schedule(apply_tree_highlights)
      end,
    })
  end,
  vim.keymap.set('n', '<leader>nt', ':NvimTreeToggle<CR>', {noremap=true})
}
