local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local colors = {
    normal   = "#61afef",
    insert   = "#98c379",
    visual   = "#c678dd",
    replace  = "#e06c75",
    command  = "#e5c07b",
    bg       = "#21252b",
    fg       = "#abb2bf",
    dimfg    = "#5c6370",
    yellow   = "#e5c07b",
    red      = "#e06c75",
    green    = "#98c379",
    cyan     = "#56b6c2",
}

local mode_colors = {
    n  = colors.normal,
    i  = colors.insert,
    v  = colors.visual,
    V  = colors.visual,
    ["\22"] = colors.visual,
    c  = colors.command,
    R  = colors.replace,
    r  = colors.replace,
    ["!"] = colors.red,
    t  = colors.green,
}

local Mode = {
    init = function(self) self.mode = vim.fn.mode(1) end,
    static = {
        names = {
            n = "NORMAL", no = "N-OP", nov = "N-OP", noV = "N-OP",
            i = "INSERT", ic = "INSERT", ix = "INSERT",
            v = "VISUAL", V = "V-LINE", ["\22"] = "V-BLOCK",
            c = "COMMAND", cv = "EX", r = "PROMPT", rm = "MORE",
            ["r?"] = "CONFIRM", ["!"] = "SHELL", t = "TERM",
            s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
            R = "REPLACE", Rc = "REPLACE", Rx = "REPLACE",
        },
    },
    provider = function(self)
        return " " .. (self.names[self.mode] or self.mode) .. " "
    end,
    hl = function(self)
        local m = self.mode:sub(1, 1)
        return { fg = colors.bg, bg = mode_colors[m] or colors.normal, bold = true }
    end,
    update = { "ModeChanged", pattern = "*:*" },
}

local FileIcon = {
    init = function(self)
        local ok, devicons = pcall(require, "nvim-web-devicons")
        if ok then
            self.icon, self.icon_color = devicons.get_icon_color(
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"),
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":e"),
                { default = true }
            )
        end
    end,
    provider = function(self) return self.icon and (self.icon .. " ") or "" end,
    hl = function(self) return { fg = self.icon_color } end,
}

local FileName = {
    provider = function()
        local name = vim.api.nvim_buf_get_name(0)
        name = vim.fn.fnamemodify(name, ":~:.")
        if name == "" then return "[No Name]" end
        if #name > 40 then name = "…" .. name:sub(-38) end
        return name
    end,
    hl = { fg = colors.fg },
}

local FileFlags = {
    {
        condition = function() return vim.bo.modified end,
        provider = " ●",
        hl = { fg = colors.green },
    },
    {
        condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
        provider = " ",
        hl = { fg = colors.red },
    },
}

local Git = {
    condition = conditions.is_git_repo,
    init = function(self)
        self.status = vim.b.gitsigns_status_dict or {}
    end,
    {
        provider = function(self)
            return "  " .. (self.status.head or "")
        end,
        hl = { fg = colors.cyan, bold = true },
    },
    {
        provider = function(self)
            local s = ""
            if (self.status.added or 0) > 0 then s = s .. " +" .. self.status.added end
            if (self.status.changed or 0) > 0 then s = s .. " ~" .. self.status.changed end
            if (self.status.removed or 0) > 0 then s = s .. " -" .. self.status.removed end
            return s
        end,
        hl = { fg = colors.dimfg },
    },
}

local Diagnostics = {
    condition = conditions.has_diagnostics,
    init = function(self)
        self.errors   = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints    = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.info     = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
        provider = function(self) return self.errors > 0 and (" E:" .. self.errors) or "" end,
        hl = { fg = colors.red },
    },
    {
        provider = function(self) return self.warnings > 0 and (" W:" .. self.warnings) or "" end,
        hl = { fg = colors.yellow },
    },
    {
        provider = function(self) return self.hints > 0 and (" H:" .. self.hints) or "" end,
        hl = { fg = colors.cyan },
    },
}

local LSPActive = {
    condition = conditions.lsp_attached,
    provider = function()
        local names = {}
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, client.name)
        end
        return " [" .. table.concat(names, ", ") .. "]"
    end,
    hl = { fg = colors.green },
}

local FileType = {
    provider = function() return " " .. (vim.bo.filetype ~= "" and vim.bo.filetype or "plain") .. " " end,
    hl = { fg = colors.dimfg },
}

local Ruler = {
    provider = " %l:%c  %P ",
    hl = { fg = colors.fg },
}

local Align = { provider = "%=" }
local Space = { provider = " " }

local StatusLine = {
    hl = { bg = colors.bg },
    Mode,
    Space,
    FileIcon,
    FileName,
    FileFlags,
    Git,
    Space,
    Diagnostics,
    Align,
    LSPActive,
    FileType,
    Ruler,
}

require("heirline").setup({ statusline = StatusLine })
