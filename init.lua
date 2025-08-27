vim.opt.wrap = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard:prepend({ "unnamed", "unnamedplus" })
vim.cmd.colorscheme("slate")
vim.o.shell = "pwsh"
vim.o.shellcmdflag =
"-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.o.shellquote = ""
vim.o.shellxquote = ""


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Setup plugins (currently empty)
-- =========================
require("lazy").setup({
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls" }, -- only Lua for now
                automatic_installation = false,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- If Mason's bin isn't on PATH, prepend it so lua_ls can start
            vim.env.PATH = vim.fn.stdpath("data") .. "\\mason\\bin;" .. vim.env.PATH

            local lsp = require("lspconfig")

            -- Tiny on_attach with a couple of useful keys
            local on_attach = function(_, bufnr)
                local map = function(m, lhs, rhs) vim.keymap.set(m, lhs, rhs, { buffer = bufnr }) end
                map("n", "gd", vim.lsp.buf.definition)
                map("n", "K", vim.lsp.buf.hover)
                map("n", "gr", vim.lsp.buf.references)
                map("n", "<leader>rn", vim.lsp.buf.rename)
            end

            -- Capabilities for nvim-cmp (completion)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if ok_cmp then
                capabilities = cmp_lsp.default_capabilities(capabilities)
            end

            -- Lua LSP tuned for Neovim config
            lsp.lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } }, -- don't warn about 'vim'
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME, -- Neovim runtime
                                -- Add your config path so lua_ls sees your files
                                (vim.fn.stdpath("config") or ""),
                            },
                        },
                        telemetry = { enable = false },
                    },
                },
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- accept first item
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-j>"] = cmp.mapping.scroll_docs(4),
                    ["<C-k>"] = cmp.mapping.scroll_docs(-4),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                },
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" }, -- format Lua with stylua
                },
                notify_on_error = false,
            })

            -- Optional: format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function(args)
                    require("conform").format({ bufnr = args.buf, lsp_fallback = true, async = false })
                end,
            })

            -- Optional: manual format key
            vim.keymap.set("n", "<leader>f", function()
                require("conform").format({ async = false, lsp_fallback = true })
            end, { desc = "Format buffer" })
        end,
    },
})
