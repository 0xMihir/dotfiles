vim.api.nvim_create_augroup("hybrid_numbers", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    group = "hybrid_numbers",
    pattern = "*",
    callback = function()
        if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
            vim.wo.relativenumber = true
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    group = "hybrid_numbers",
    pattern = "*",
    callback = function()
        if vim.wo.number then
            vim.wo.relativenumber = false
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-format-on-save", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Check if the LSP server supports formatting
        if client and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    -- async = false blocks the editor briefly so the file saves
                    -- only after the formatting edits have been applied safely.
                    vim.lsp.buf.format({ async = false, id = client.id })
                end,
            })
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/semanticTokens/full") then
            vim.lsp.semantic_tokens.enable(true, { bufnr = ev.buf })
        end
        if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end
    end,
})
