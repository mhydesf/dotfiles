return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip'
	},
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local has_autopairs, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')

    local has_vscode_loader, vscode_loader = pcall(require, "luasnip.loaders.from_vscode")
    if has_vscode_loader then
      vscode_loader.lazy_load()
    end

    if has_autopairs then
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },
      window = {
        completion = {
          border = "rounded",
          max_width = 60,
          max_height = 15,
        },
        documentation = {
          border = "rounded",
          max_width = 60,
          max_height = 15,
        },
      },
      mapping = cmp.mapping.preset.insert {
        ['<CR>'] = cmp.mapping.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },
      sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      },
		}
	end
}
