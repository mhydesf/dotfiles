return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local mason_dap = require("mason-nvim-dap")

      mason_dap.setup({
        ensure_installed = { "cpptools" },
        automatic_installation = true,
        handlers = {
          function(config) mason_dap.default_setup(config) end,
        },
      })

      local function cppdbg_path()
        local ok_path, mason_path = pcall(require, "mason-core.path")
        if not ok_path then
          return nil
        end
        local mason_root = vim.env.MASON or require("mason.settings").current.install_root_dir
        local path = mason_path.concat({
          mason_root,
          "packages",
          "cpptools",
          "extension",
          "debugAdapters",
          "bin",
          "OpenDebugAD7",
        })
        return (vim.loop.fs_stat(path) and path) or nil
      end

      dap.adapters.cppdbg = function(callback)
        local path = cppdbg_path()
        if not path then
          vim.schedule(function()
            vim.notify("[dap] cpptools adapter is not available yet; install it via :MasonInstall cpptools", vim.log.levels.WARN)
          end)
          return
        end
        callback({ id = "cppdbg", type = "executable", command = path, options = { detached = false } })
      end

      local function pretty_printing()
        return {
          {
            text = "-enable-pretty-printing",
            description = "Enable GDB pretty printing",
            ignoreFailures = true,
          },
        }
      end

      local function pick_executable()
        return vim.fn.input({
          prompt = "Path to executable: ",
          default = vim.fn.getcwd() .. "/",
          completion = "file",
        })
      end

      dap.configurations.cpp = {
        {
          name = "Launch with Executable",
          type = "cppdbg",
          request = "launch",
          program = pick_executable,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          MIMode = "gdb",
          miDebuggerPath = vim.fn.exepath("gdb") ~= "" and vim.fn.exepath("gdb") or "gdb",
          setupCommands = pretty_printing(),
        },
        -- {
        --   name = "Attach to gdbserver :1234",
        --   type = "cppdbg",
        --   request = "launch",
        --   program = pick_executable,
        --   cwd = "${workspaceFolder}",
        --   MIMode = "gdb",
        --   miDebuggerServerAddress = "localhost:1234",
        --   miDebuggerPath = vim.fn.exepath("gdb") ~= "" and vim.fn.exepath("gdb") or "gdb",
        --   setupCommands = pretty_printing(),
        -- },
      }

      dap.configurations.c = dap.configurations.cpp
      dap.configurations.objc = dap.configurations.cpp
      dap.configurations.objcpp = dap.configurations.cpp

      require("nvim-dap-virtual-text").setup({
        commented = true,
      })

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
      end

      map("<F5>", dap.continue, "DAP Continue/Start")
      map("<F10>", dap.step_over, "DAP Step Over")
      map("<F11>", dap.step_into, "DAP Step Into")
      map("<F12>", dap.step_out, "DAP Step Out")
      map("<leader>db", dap.toggle_breakpoint, "DAP Toggle Breakpoint")
      map("<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, "DAP Conditional Breakpoint")
      map("<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, "DAP Log Point")
      map("<leader>dr", dap.run_to_cursor, "DAP Run to Cursor")
      map("<leader>dR", dap.run_last, "DAP Run Last")
      map("<leader>dk", function() dap.terminate() end, "DAP Terminate Session")
      map("<leader>du", dapui.toggle, "DAP Toggle UI")
      map("<leader>de", function() dapui.eval(nil, { enter = true }) end, "DAP Evaluate Expression")
    end,
  },
}
