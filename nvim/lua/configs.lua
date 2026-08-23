local o = vim.opt

o.termguicolors = true
o.signcolumn = "yes"
o.laststatus = 3
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400


local undo_dir = vim.fn.expand('~/.local/state/nvim/undo')
if vim.fn.isdirectory(undo_dir) == 0 then
    vim.fn.mkdir(undo_dir, 'p')
end
o.undofile = true
o.undodir = undo_dir

-- relative numbering
o.number = true
o.relativenumber = true


-- tabs
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
