-- Keymaps
local keymap = vim.keymap.set

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<leader>vs", ":vsplit<CR>")
keymap("n", "<leader>hs", ":split<CR>")
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

local fullscreen_state = {
  is_fullscreen = false,
  session_data = nil,
}

function ToggleFullscreen()
  if not fullscreen_state.is_fullscreen then
    -- Save current session to a temporary file or in memory
    fullscreen_state.session_data = vim.fn.execute('mksession! /tmp/nvim_fullscreen.vim')

    -- Make current window fullscreen
    vim.cmd("only")
    fullscreen_state.is_fullscreen = true
  else
    -- Restore previous session layout
    vim.cmd("silent! source /tmp/nvim_fullscreen.vim")
    fullscreen_state.is_fullscreen = false
  end
end

vim.keymap.set("n", "<leader>ll", ToggleFullscreen, { silent = true, desc = "Toggle fullscreen buffer" })

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>")
keymap("n", "<C-Down>", ":resize +2<CR>")
keymap("n", "<C-Left>", ":vertical resize +2<CR>")
keymap("n", "<C-Right>", ":vertical resize -2<CR>")

-- Navigate buffers
keymap("n", "<TAB>", ":bnext<CR>")
keymap("n", "<S-TAB>", ":bprevious<CR>")
keymap("n", "<leader>x", "<cmd>close<CR>")

-- Move text up and down
keymap("n", "J", ":m .+1<CR>==")
keymap("n", "K", ":m .-2<CR>==")

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv^")
keymap("v", ">", ">gv^")

keymap("v", "p", '"_dP')

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":m '>+1<CR>gv=gv")
keymap("x", "K", ":m '<-2<CR>gv=gv")

-- files
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "E", "$", {noremap=false})
vim.api.nvim_set_keymap("n", "B", "^", {noremap=false})
vim.api.nvim_set_keymap("n", "ss", ":noh<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<leader>nf", ":enew<CR>", {noremap=true})

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
