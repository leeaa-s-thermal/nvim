-- lua/config/lsp.lua

local lspconfig = require("lspconfig")

-- Ensure Mason-installed binaries are on PATH
vim.env.PATH = vim.fn.stdpath("data") .. "\\mason\\bin;" .. vim.env.PATH

-- Attach useful keymaps when LSP starts
local on_attach = function(_, bufnr)
	local map = function(mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
	end

	map("n", "gd", vim.lsp.buf.definition)
	map("n", "K", vim.lsp.buf.hover)
	map("n", "gr", vim.lsp.buf.references)
	map("n", "<leader>rn", vim.lsp.buf.rename)
end

-- Capabilities for nvim-cmp integration
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Configure Lua language server
lspconfig.lua_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.stdpath("config"),
				},
			},
			telemetry = { enable = false },
		},
	},
})
