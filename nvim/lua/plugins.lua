vim.pack.add({ "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/hedyhli/outline.nvim",
    "https://github.com/rmagatti/auto-session",
    "https://github.com/rebelot/heirline.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/akinsho/toggleterm.nvim",
    -- "https://github.com/navarasu/onedark.nvim",
    "https://github.com/D0nw0r/dark2026.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/saghen/blink.lib",
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/saghen/blink.cmp"
})

-- require("onedark").load()
vim.cmd.packadd("dark2026.nvim")
vim.cmd.colorscheme("dark2026")

require("fzf-lua").setup({ "default" })

require("nvim-tree").setup({
    view = { side = "left", width = 35 },
    renderer = { group_empty = true },
    filters = { dotfiles = false },
})

require("outline").setup({
    outline_window = { position = "right", width = 35 },
})

require("auto-session").setup({})

vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("nvim-treesitter-context")

require("nvim-treesitter").setup({})

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

require("treesitter-context").setup({
    enable = true,
    max_lines = 3,
})

require("gitsigns").setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
    },
    signs_staged_enable = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    current_line_blame = false,
})



local cmp = require("blink.cmp")


cmp.build():pwait()
cmp.setup({
    keymap = {
        preset = "default",
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<CR>"] = { "accept", "fallback" }
    },
    completion = {
        -- menu = { auto_show = false },
        documentation = { auto_show = false }
    },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "rust" },
})
