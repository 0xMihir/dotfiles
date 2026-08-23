-- comment toggle
vim.keymap.set('n', '<leader>/', 'gcc', { desc = 'Toggle comment', remap = true })
vim.keymap.set('v', '<C-_>', 'gc', { desc = 'Toggle comment', remap = true })

-- buffer delete
vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- buffer navigation
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true })

-- insert mode navigation
vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'Move down' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'Move up' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'Move right' })

-- window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- lsp
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
vim.keymap.set('n', 'ds', function()
    vim.diagnostic.setqflist()
    vim.cmd('copen')
end, { desc = 'Show all diagnostics' })

-- nvim-tree
vim.keymap.set('n', '<C-n>', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file tree' })

-- outline
vim.keymap.set('n', '<leader>o', '<cmd>Outline<CR>', { desc = 'Toggle outline' })

-- fugitive
vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<leader>gd', '<cmd>Gdiffsplit<CR>', { desc = 'Git diff' })
vim.keymap.set('n', '<leader>gb', '<cmd>Git blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', '<leader>gl', '<cmd>Git log<CR>', { desc = 'Git log' })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>', { desc = 'Git push' })

-- fzf-lua
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fw', '<cmd>FzfLua live_grep<CR>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua git_files<CR>', { desc = 'Git files' })


vim.keymap.set('n', '<leader>fm', function()
    vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer' })
