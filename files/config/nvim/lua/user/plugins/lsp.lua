return {
  {
    "neovim/nvim-lspconfig", -- still provides default configs; we don't call lspconfig.setup()
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", tag = "legacy" },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      ---------------------------------------------------------------------------
      -- Install-only (no auto-start)
      ---------------------------------------------------------------------------
      require("mason").setup()

      local mls = require("mason-lspconfig")
      local servers = {
        "cmake","dockerls","bashls","jsonls","yamlls","marksman","pyright","lua_ls","clangd", "rust_analyzer"
      }

      -- mason-lspconfig: ensure_installed ONLY; do NOT use setup_handlers here.
      mls.setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      ---------------------------------------------------------------------------
      -- Shared caps
      ---------------------------------------------------------------------------

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
        root_markers = { ".git" },
        autostart = false,
      })

      ---------------------------------------------------------------------------
      -- LspAttach mappings
      ---------------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("my.lsp.attach", {}),
        callback = function(args)
          local b = args.buf
          local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = b, silent = true }) end
          map("gd",  vim.lsp.buf.definition)
          map("gD",  vim.lsp.buf.declaration)
          map("gi",  vim.lsp.buf.implementation)
          map("gr",  vim.lsp.buf.references)
          map("K",   vim.lsp.buf.hover)
          map("<space>rn", vim.lsp.buf.rename)
          map("<space>ca", vim.lsp.buf.code_action)
        end,
      })

      ---------------------------------------------------------------------------
      -- Per-server configs (0.11)
      ---------------------------------------------------------------------------
      vim.lsp.config("pyright", {
        settings = {
          python = { analysis = {
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            useLibraryCodeForTypes = true,
            typeCheckingMode = "off",
          }},
        },
      })

      do
        local rp = vim.split(package.path, ";")
        table.insert(rp, "lua/?.lua"); table.insert(rp, "lua/?/init.lua")
        vim.lsp.config("lua_ls", {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT", path = rp },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
              telemetry = { enable = false },
            },
          },
        })
      end

      for _, s in ipairs({ "cmake","dockerls","bashls","jsonls","yamlls","marksman" }) do
        vim.lsp.config(s, {})
      end

      -- clangd: single instance + compile_commands picker

      local qd = require("user.plugins.utils.clangd_query_driver").compute_query_driver({
        root_dir = vim.fn.getcwd(),
        compile_commands_dir = "build",
      })

      local cmd = {
        "clangd",
        "--background-index",
        "--compile-commands-dir=build",
        "--header-insertion=never",
        "--enable-config",
      }

      if qd and qd ~= "" then
        table.insert(cmd, "--query-driver=" .. qd)
      end

      vim.lsp.config("clangd", {
        cmd = cmd,
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
        single_file_support = false,
      })

      vim.keymap.set("n", "<leader>sc", function()
        local driver_str = nil
        local ok, mod = pcall(require, "user.plugins.utils.clangd_query_driver")
        if ok then
          driver_str = mod.compute_query_driver({
            root_dir = vim.fn.getcwd(),
            compile_commands_dir = "build",
          })
        end

        if not driver_str or driver_str == "" then
          vim.notify("No compile_commands.json found or no compilers detected.",
            vim.log.levels.WARN, { title = "Clangd" })
          return
        end

        local drivers = {}
        for item in string.gmatch(driver_str, "([^,]+)") do
          table.insert(drivers, vim.trim(item))
        end

        local msg = table.concat(drivers, "\n")
        vim.notify(msg, vim.log.levels.INFO, { title = "Clangd Compilers" })
      end, { desc = "Show clangd compiler paths" })

      ---------------------------------------------------------------------------
      -- Start exactly once (no duplicates)
      ---------------------------------------------------------------------------
      vim.lsp.enable(servers)

      local function stop_lsp(_)
        vim.lsp.stop_client(vim.lsp.get_clients())
      end

      vim.keymap.set("n", "slsp", function()
        stop_lsp()
      end, { desc = "Stop configured LSP servers" })

      ---------------------------------------------------------------------------
      -- Diagnostics UI
      ---------------------------------------------------------------------------
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
          },
        },
        virtual_text = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end
  },
}
