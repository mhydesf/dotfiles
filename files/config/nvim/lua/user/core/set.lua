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
vim.g.clipboard = {
  name = "xclip",
  copy = {
    ["+"] = "xclip -selection clipboard -in -t text/plain",
    ["*"] = "xclip -selection primary -in -t text/plain",
  },
  paste = {
    ["+"] = "xclip -selection clipboard -out",
    ["*"] = "xclip -selection primary -out",
  },
  cache_enabled = 0,
}
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 2
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.conceallevel = 0
vim.opt.fileencoding = "utf-8"
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

vim.o.completeopt = 'menuone,noselect'

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

-- Set Tab Spacing to 2 for Lua files
vim.cmd[[ autocmd FileType lua set tabstop=2 shiftwidth=2 ]]
-- Set Tab Spacing to 4 for YAML files
vim.cmd[[ autocmd FileType yaml set tabstop=4 shiftwidth=4 ]]
-- Enable Text Wrapping for Markdown files
vim.cmd[[
  augroup MarkdownWrap
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal textwidth=0
  augroup END
]]
