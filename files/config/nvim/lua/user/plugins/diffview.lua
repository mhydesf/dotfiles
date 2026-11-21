return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    {
      "<leader>dd",
      "<cmd>DiffviewOpen<cr>",
      desc = "Open Diffview",
    },
    {
      "<leader>dp",
      "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<cr>",
      desc = "Diffview PR review (origin/HEAD...HEAD)",
    },
    {
      "<leader>dh",
      "<cmd>DiffviewFileHistory %<cr>",
      desc = "Current file history",
    },
    {
      "<leader>dH",
      "<cmd>DiffviewFileHistory<cr>",
      desc = "Repository history",
    },
    {
      "<leader>df",
      "<cmd>DiffviewToggleFiles<cr>",
      desc = "Toggle file panel",
    },
    {
      "<leader>dq",
      "<cmd>DiffviewClose<cr>",
      desc = "Close Diffview",
    },
  },
  opts = function()
    local actions = require("diffview.actions")
    local lib = require("diffview.lib")
    local Diff1 = require("diffview.scene.layouts.diff_1").Diff1

    local function exit_visual()
      local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
      vim.api.nvim_feedkeys(esc, "nx", false)
    end

    local function get_visual_range()
      local l1 = vim.fn.line("v")
      local l2 = vim.fn.line(".")
      return math.min(l1, l2), math.max(l1, l2)
    end

    local function write_buf(bufnr)
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].modifiable then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent! write")
        end)
      end
    end

    local function is_single_file_entry(entry, layout)
      if not entry then
        return false
      end
      if entry.status == "A" or entry.status == "?" then
        return true
      end
      if not layout or not layout.a or (layout.a.file and layout.a.file.nulled) then
        return true
      end
      return false
    end

    -- Stage or unstage hunk / visual selection (Fugitive `s`, `-`, `u`)
    local function fugitive_stage_or_unstage(is_visual, mode_action)
      local view = lib.get_current_view()
      if not view or not view.cur_entry then
        return
      end

      local entry = view.cur_entry
      local layout = view.cur_layout
      local cur_win = vim.api.nvim_get_current_win()
      local win_a = layout.a and layout.a.id
      local win_b = layout.b and layout.b.id
      local buf_a = layout.a and layout.a.file and layout.a.file.bufnr
      local buf_b = layout.b and layout.b.file and layout.b.file.bufnr
      local l1, l2 = get_visual_range()
      local range = is_visual and (l1 .. "," .. l2) or ""

      if entry.kind == "working" then
        if mode_action == "unstage" then
          if is_visual then
            exit_visual()
          end
          return
        end

        -- Added or untracked file (single window or nulled left pane)
        if is_single_file_entry(entry, layout) then
          if is_visual then
            exit_visual()
            -- Stage only the selected lines of the untracked file into the index
            local lines = vim.api.nvim_buf_get_lines(buf_b, l1 - 1, l2, false)
            local blob = vim.fn.system(
              { "git", "-C", view.adapter.ctx.toplevel, "hash-object", "-w", "--stdin" },
              table.concat(lines, "\n") .. "\n"
            )
            blob = vim.trim(blob)
            if vim.v.shell_error == 0 and blob ~= "" then
              vim.fn.system({
                "git",
                "-C",
                view.adapter.ctx.toplevel,
                "update-index",
                "--add",
                "--cacheinfo",
                "100644," .. blob .. "," .. entry.path,
              })
              actions.refresh_files()
            end
          else
            actions.toggle_stage_entry()
          end
          return
        end

        if cur_win == win_b then
          -- Right pane (WORKING TREE): push hunk / selected lines to INDEX (left pane) and write INDEX
          pcall(vim.cmd, range .. "diffput")
          if is_visual then
            exit_visual()
          end
          write_buf(buf_a)
        elseif cur_win == win_a then
          -- Left pane (INDEX): obtain hunk / selected lines from WORKING TREE and write INDEX
          local ok = pcall(vim.cmd, range .. "diffget")
          if not ok and is_visual then
            vim.cmd(range .. "delete _")
          end
          if is_visual then
            exit_visual()
          end
          write_buf(buf_a)
        end
      elseif entry.kind == "staged" then
        if mode_action == "stage" then
          if is_visual then
            exit_visual()
          end
          return
        end

        -- Staged changes: Left is HEAD (a), Right is INDEX (b)
        if cur_win == win_b then
          if is_single_file_entry(entry, layout) then
            -- Newly added staged file: deleting lines from INDEX unstages them
            if is_visual then
              exit_visual()
              vim.cmd(range .. "delete _")
              write_buf(buf_b)
            else
              actions.toggle_stage_entry()
            end
          else
            pcall(vim.cmd, range .. "diffget")
            if is_visual then
              exit_visual()
            end
            write_buf(buf_b)
          end
        elseif cur_win == win_a then
          pcall(vim.cmd, range .. "diffput")
          if is_visual then
            exit_visual()
          end
          write_buf(buf_b)
        end
      end
    end

    -- Discard hunk / visual selection (Fugitive `X`)
    local function fugitive_discard(is_visual)
      local view = lib.get_current_view()
      if not view or not view.cur_entry then
        return
      end

      local entry = view.cur_entry
      local layout = view.cur_layout
      local cur_win = vim.api.nvim_get_current_win()
      local win_a = layout.a and layout.a.id
      local win_b = layout.b and layout.b.id
      local buf_b = layout.b and layout.b.file and layout.b.file.bufnr
      local l1, l2 = get_visual_range()
      local range = is_visual and (l1 .. "," .. l2) or ""

      if entry.kind == "working" then
        if cur_win == win_b then
          if is_single_file_entry(entry, layout) then
            if is_visual then
              exit_visual()
              vim.cmd(range .. "delete _")
              write_buf(buf_b)
            else
              actions.restore_entry()
            end
            return
          end
          pcall(vim.cmd, range .. "diffget")
          if is_visual then
            exit_visual()
          end
          write_buf(buf_b)
        elseif cur_win == win_a then
          -- In left (INDEX) pane: put deleted lines back into WORKING TREE
          pcall(vim.cmd, range .. "diffput")
          if is_visual then
            exit_visual()
          end
          write_buf(buf_b)
        end
      elseif entry.kind == "staged" then
        -- In Staged changes, `X` unstages the hunk/lines back to HEAD
        fugitive_stage_or_unstage(is_visual, "unstage")
      end
    end

    -- Forward LSP / goto-preview requests from `diffview://` buffers (left pane)
    -- to the right pane's real LSP buffer (or fallback to Telescope workspace symbols).
    local function find_lsp_target_in_right_pane()
      local view = lib.get_current_view()
      local layout = view and view.cur_layout
      local win_b = layout and layout.b and layout.b.id
      local buf_b = layout and layout.b and layout.b.file and layout.b.file.bufnr
      if not (win_b and buf_b and vim.api.nvim_win_is_valid(win_b) and vim.api.nvim_buf_is_valid(buf_b)) then
        return nil
      end
      if #vim.lsp.get_clients({ bufnr = buf_b }) == 0 then
        return nil
      end

      local cword = vim.fn.expand("<cword>")
      if cword == "" then
        return nil
      end

      local cur_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_get_lines(buf_b, 0, -1, false)
      local pat = "\\V\\<" .. vim.fn.escape(cword, "\\") .. "\\>"

      local best_lnum, best_col, best_dist
      for lnum, line in ipairs(lines) do
        local col = vim.fn.match(line, pat)
        if col ~= -1 then
          local dist = math.abs(lnum - cur_line)
          if not best_dist or dist < best_dist then
            best_lnum, best_col, best_dist = lnum, col, dist
          end
        end
      end

      if not best_lnum then
        return { win_b = win_b, buf_b = buf_b, cword = cword }
      end

      return {
        win_b = win_b,
        buf_b = buf_b,
        lnum = best_lnum,
        col = best_col,
        cword = cword,
      }
    end

    local function fallback_workspace_symbols(win_b, cword)
      cword = cword or vim.fn.expand("<cword>")
      if cword == "" then
        return
      end
      local ok_tel, builtin = pcall(require, "telescope.builtin")
      if not ok_tel then
        return
      end
      if win_b and vim.api.nvim_win_is_valid(win_b) then
        vim.api.nvim_win_call(win_b, function()
          builtin.lsp_dynamic_workspace_symbols({ default_text = cword })
        end)
      else
        builtin.grep_string({ search = cword })
      end
    end

    local function run_on_right_pane(fn)
      local target = find_lsp_target_in_right_pane()
      if not target or not target.lnum then
        fallback_workspace_symbols(target and target.win_b, target and target.cword)
        return
      end
      vim.api.nvim_win_call(target.win_b, function()
        local saved = vim.api.nvim_win_get_cursor(target.win_b)
        pcall(vim.api.nvim_win_set_cursor, target.win_b, { target.lnum, target.col })
        fn(target)
        pcall(vim.api.nvim_win_set_cursor, target.win_b, saved)
      end)
    end

    local function hover_from_right_pane()
      local target = find_lsp_target_in_right_pane()
      if not target or not target.lnum then
        fallback_workspace_symbols(target and target.win_b, target and target.cword)
        return
      end
      local client = vim.lsp.get_clients({ bufnr = target.buf_b })[1]
      local enc = client and client.offset_encoding or "utf-16"
      local params
      vim.api.nvim_win_call(target.win_b, function()
        local saved = vim.api.nvim_win_get_cursor(target.win_b)
        pcall(vim.api.nvim_win_set_cursor, target.win_b, { target.lnum, target.col })
        params = vim.lsp.util.make_position_params(target.win_b, enc)
        pcall(vim.api.nvim_win_set_cursor, target.win_b, saved)
      end)
      vim.lsp.buf_request_all(target.buf_b, "textDocument/hover", params, function(results)
        local contents = {}
        for _, resp in pairs(results or {}) do
          if resp.result and resp.result.contents then
            vim.list_extend(contents, vim.lsp.util.convert_input_to_markdown_lines(resp.result.contents))
          end
        end
        if #contents > 0 then
          vim.lsp.util.open_floating_preview(contents, "markdown", { focus_id = "textDocument/hover" })
        else
          vim.notify("No information available", vim.log.levels.INFO)
        end
      end)
    end

    return {
      default_args = {
        DiffviewOpen = { "--imply-local" },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          if not vim.api.nvim_buf_get_name(bufnr):match("^diffview://") then
            return
          end
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          map("K", hover_from_right_pane, "LSP hover (via working tree)")
          map("gd", function()
            run_on_right_pane(function()
              vim.lsp.buf.definition()
            end)
          end, "LSP definition (via working tree)")
          map("gD", function()
            run_on_right_pane(function()
              vim.lsp.buf.declaration()
            end)
          end, "LSP declaration (via working tree)")
          map("gi", function()
            run_on_right_pane(function()
              vim.lsp.buf.implementation()
            end)
          end, "LSP implementation (via working tree)")
          map("gr", function()
            run_on_right_pane(function()
              vim.lsp.buf.references()
            end)
          end, "LSP references (via working tree)")

          local ok_gp, gp = pcall(require, "goto-preview")
          if ok_gp then
            map("gpd", function()
              run_on_right_pane(function()
                gp.goto_preview_definition()
              end)
            end, "Preview definition (via working tree)")
            map("gpt", function()
              run_on_right_pane(function()
                gp.goto_preview_type_definition()
              end)
            end, "Preview type definition (via working tree)")
            map("gpi", function()
              run_on_right_pane(function()
                gp.goto_preview_implementation()
              end)
            end, "Preview implementation (via working tree)")
            map("gpD", function()
              run_on_right_pane(function()
                gp.goto_preview_declaration()
              end)
            end, "Preview declaration (via working tree)")
            map("gpr", function()
              run_on_right_pane(function()
                gp.goto_preview_references()
              end)
            end, "Preview references (via working tree)")
          end
        end,
        view_opened = function(view)
          if not view.emitter then
            return
          end

          local was_panel_focused = false
          local was_layout_focused = false

          view.emitter:on("file_open_pre", function(_, entry)
            was_panel_focused = view.panel and view.panel:is_focused() or false
            was_layout_focused = view.cur_layout and view.cur_layout:is_focused() or false

            if entry.status == "A" or entry.status == "?" then
              if not entry.layout:instanceof(Diff1) then
                entry:convert_layout(Diff1)
              end
              if entry.layout.b and entry.layout.b.file then
                entry.layout.b.file.winopts = vim.tbl_extend("force", entry.layout.b.file.winopts or {}, {
                  diff = false,
                  scrollbind = false,
                  cursorbind = false,
                  foldmethod = "manual",
                  foldenable = false,
                })
              end
            elseif entry.kind ~= "conflicting" and entry.layout:instanceof(Diff1) and view.default_layout then
              entry:convert_layout(view.default_layout)
              if entry.layout.b and entry.layout.b.file then
                entry.layout.b.file.winopts = vim.tbl_extend("force", entry.layout.b.file.winopts or {}, {
                  diff = true,
                  scrollbind = true,
                  cursorbind = true,
                  foldmethod = "diff",
                  foldenable = true,
                })
              end
            end
          end)

          view.emitter:on("file_open_post", function()
            if was_panel_focused and view.panel and view.panel:is_open() then
              view.panel:focus()
            elseif was_layout_focused and view.cur_layout then
              local main_win = view.cur_layout:get_main_win()
              if main_win and main_win:is_valid() then
                main_win:focus()
              end
            end
          end)
        end,
      },
      keymaps = {
        view = {
          -- Visual mode: Fugitive-style partial line staging / unstaging / discarding
          {
            "x",
            "s",
            function()
              fugitive_stage_or_unstage(true, "stage")
            end,
            { desc = "Stage visually selected lines" },
          },
          {
            "x",
            "u",
            function()
              fugitive_stage_or_unstage(true, "unstage")
            end,
            { desc = "Unstage visually selected lines" },
          },
          {
            "x",
            "-",
            function()
              fugitive_stage_or_unstage(true, "toggle")
            end,
            { desc = "Stage/unstage visually selected lines" },
          },
          {
            "x",
            "X",
            function()
              fugitive_discard(true)
            end,
            { desc = "Discard visually selected lines" },
          },
          -- Normal mode: Fugitive-style hunk staging / unstaging / discarding
          {
            "n",
            "-",
            function()
              fugitive_stage_or_unstage(false, "toggle")
            end,
            { desc = "Stage/unstage hunk under cursor" },
          },
          {
            "n",
            "X",
            function()
              fugitive_discard(false)
            end,
            { desc = "Discard hunk under cursor" },
          },
        },
        file_panel = {
          { "n", "u", actions.toggle_stage_entry, { desc = "Unstage / stage selected entry" } },
          { "n", "cc", "<Cmd>Git commit <bar> wincmd J<CR>", { desc = "Commit staged changes (Fugitive)" } },
          { "n", "ca", "<Cmd>Git commit --amend <bar> wincmd J<CR>", { desc = "Amend last commit (Fugitive)" } },
        },
      },
    }
  end,
}
