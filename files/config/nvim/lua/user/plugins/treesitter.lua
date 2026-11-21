return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Neovim 0.12 requires the 'main' branch (master does not support 0.12)
  build = ":TSUpdate",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
  },
  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Ensure parsers are installed (no-op if already installed)
    local parsers = {
      "c",
      "cpp",
      "python",
      "bash",
      "json",
      "lua",
      "regex",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "query",
    }
    ts.install(parsers)

    -- Neovim 0.12 native Treesitter highlighting & indentation per buffer
    local ts_group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = ts_group,
      callback = function(args)
        local bufnr = args.buf
        if vim.bo[bufnr].buftype ~= "" then
          return
        end
        -- Start native Neovim 0.12 treesitter highlighting if a parser exists for this filetype
        if pcall(vim.treesitter.start, bufnr) then
          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- Configure nvim-treesitter-textobjects (main branch API for 0.12)
    local ok_to, ts_textobjects = pcall(require, "nvim-treesitter-textobjects")
    if ok_to then
      ts_textobjects.setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move   = require("nvim-treesitter-textobjects.move")
      local swap   = require("nvim-treesitter-textobjects.swap")

      -- Select textobjects
      local select_maps = {
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for lhs, query in pairs(select_maps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { silent = true, desc = "TS Select " .. query })
      end

      -- Move textobjects
      vim.keymap.set({ "n", "x", "o" }, "]m", function() move.goto_next_start("@function.outer", "textobjects") end, { silent = true, desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]]", function() move.goto_next_start("@class.outer", "textobjects") end, { silent = true, desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "]M", function() move.goto_next_end("@function.outer", "textobjects") end, { silent = true, desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "][", function() move.goto_next_end("@class.outer", "textobjects") end, { silent = true, desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "[m", function() move.goto_previous_start("@function.outer", "textobjects") end, { silent = true, desc = "Prev function start" })
      vim.keymap.set({ "n", "x", "o" }, "[[", function() move.goto_previous_start("@class.outer", "textobjects") end, { silent = true, desc = "Prev class start" })
      vim.keymap.set({ "n", "x", "o" }, "[M", function() move.goto_previous_end("@function.outer", "textobjects") end, { silent = true, desc = "Prev function end" })
      vim.keymap.set({ "n", "x", "o" }, "[]", function() move.goto_previous_end("@class.outer", "textobjects") end, { silent = true, desc = "Prev class end" })

      -- Swap parameters
      vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { silent = true, desc = "Swap next parameter" })
      vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { silent = true, desc = "Swap prev parameter" })
    end
  end,
}
