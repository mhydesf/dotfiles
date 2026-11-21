return {
  "Civitasv/cmake-tools.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },

  config = function()
    require("cmake-tools").setup({
      cmake_regenerate_on_save = false,
      cmake_build_directory = "build",
      cmake_build_options = {
        "--parallel",
        "16",
      },
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.uv.cwd() .. "/build",
      },
      cmake_virtual_text_support = false,
      cmake_notifications = {
        runner = { enabled = false },
        executor = { enabled = false },
      },
      cmake_executor = {
        name = "quickfix",
        opts = {
          show = "always",
          position = "belowright",
          size = 10,
          encoding = "utf-8",
          auto_close_when_success = true,
        },
      },
    })

    -- Batch quickfix line appends (every 30ms) so burst CMake/Ninja output
    -- doesn't call setqflist() + :cbottom thousands of times one line at a time.
    local qf = require("cmake-tools.quickfix")
    local Job = require("plenary.job")
    qf.run = function(cmd, _env_script, env, args, cwd, opts, on_exit, on_output)
      vim.fn.setqflist({}, " ", { title = cmd .. " " .. table.concat(args, " ") })
      if opts.show == "always" then
        qf.show(opts)
      end

      env = vim.tbl_deep_extend("keep", env, vim.fn.environ())

      local pending = {}
      local timer = vim.uv.new_timer()

      local function flush()
        if #pending == 0 then
          return
        end
        local lines = pending
        pending = {}
        vim.fn.setqflist({}, "a", { lines = lines })
        if qf.check_scroll() then
          qf.scroll_to_bottom()
        end
      end

      local function enqueue(encoding, err, data)
        local line = err and err or data
        if not line then
          return
        end
        if encoding ~= "utf-8" then
          line = vim.fn.iconv(line, encoding, "utf-8")
        end
        pending[#pending + 1] = line
      end

      timer:start(30, 30, vim.schedule_wrap(flush))

      qf.job = Job:new({
        command = cmd,
        args = args,
        cwd = cwd,
        env = env,
        on_stdout = function(err, data)
          enqueue(opts.encoding, err, data)
          if on_output then
            vim.schedule(function()
              on_output(data, err)
            end)
          end
        end,
        on_stderr = function(err, data)
          enqueue(opts.encoding, err, data)
          if on_output then
            vim.schedule(function()
              on_output(data, err)
            end)
          end
        end,
        on_exit = vim.schedule_wrap(function(_, code, signal)
          if not timer:is_closing() then
            timer:stop()
            timer:close()
          end
          code = signal == 0 and code or 128 + signal
          enqueue(opts.encoding, "Exited with code " .. code)
          flush()
          if code ~= 0 and opts.show == "only_on_error" then
            qf.show(opts)
            qf.scroll_to_bottom()
          end
          if code == 0 and opts.auto_close_when_success then
            qf.close(opts)
          end
          if on_exit ~= nil then
            on_exit(code)
          end
        end),
      })

      qf.job:start()
    end

    vim.keymap.set('n', '<leader>mp', '<cmd>CMakeSelectConfigurePreset<CR>')
    vim.keymap.set('n', '<leader>mc', '<cmd>CMakeSelectBuildPreset<CR>')
    vim.keymap.set('n', '<leader>mb', '<cmd>CMakeBuild<CR>')
    vim.keymap.set('n', '<leader>mt', '<cmd>CMakeSelectBuildTarget<CR>')
    vim.keymap.set('n', '<leader>mx', '<cmd>CMakeClean<CR>')
    vim.keymap.set('n', '<leader>mz', '<cmd>CMakeStopExecutor<CR>')
  end,
}
