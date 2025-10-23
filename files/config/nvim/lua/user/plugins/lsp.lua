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
        "cmake","dockerls","bashls","jsonls","yamlls","marksman","pyright","lua_ls","clangd",
      }

      -- mason-lspconfig: ensure_installed ONLY; do NOT use setup_handlers here.
      mls.setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      ---------------------------------------------------------------------------
      -- Shared caps
      ---------------------------------------------------------------------------
      local capabilities = (pcall(require, "cmp_nvim_lsp") and require("cmp_nvim_lsp").default_capabilities())
        or vim.lsp.protocol.make_client_capabilities()

      -- Global defaults for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
        root_markers = { ".git" },
        -- Force manual start everywhere (prevents any auto-start path)
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

      -- vim.lsp.config("clangd", {
      --   cmd = {
      --     "clangd",
      --     "--background-index",
      --     "--compile-commands-dir=build",
      --     "--query-driver=/opt/Xilinx/Vitis/*/gnu/aarch64/lin/aarch64-none/bin/aarch64-none-elf-*," ..
      --                     "/usr/bin/*-linux-gnu-*,/usr/bin/*-linux-gnueabihf-*",
      --   },
      --   filetypes = { "c", "cpp", "objc", "objcpp" },
      --   root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
      --   single_file_support = false
      -- })

      local qd = require("user.plugins.utils.clangd_query_driver").compute_query_driver({
        root_dir = vim.fn.getcwd(),
        compile_commands_dir = "build",  -- matches your --compile-commands-dir
      })

      local cmd = {
        "clangd",
        "--background-index",
        "--compile-commands-dir=build",
      }
      if qd then
        table.insert(cmd, "--query-driver=" .. qd)
      end

      vim.lsp.config("clangd", {
        cmd = cmd,
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
        single_file_support = false,
      })

      ---------------------------------------------------------------------------
      -- Start exactly once (no duplicates)
      ---------------------------------------------------------------------------
      vim.lsp.enable(servers)

      local function stop_lsp(targets)
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
