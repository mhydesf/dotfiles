-- Vim Options
vim.o.termguicolors = true

vim.opt.nu = true
vim.opt.rnu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.scrolloff = 2
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 30
vim.g.clipboard = nil
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 2
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.conceallevel = 0
vim.opt.ignorecase = true
vim.opt.pumheight = 10
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 0
vim.opt.writebackup = false
vim.opt.cursorline = true
vim.opt.numberwidth = 2
vim.opt.linebreak = true
vim.opt.sidescrolloff = 8
vim.opt.whichwrap = "bs<>[]hl"

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local ft_group = vim.api.nvim_create_augroup('FileTypeSettings', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = 'lua',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = 'yaml',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 0
  end,
})
