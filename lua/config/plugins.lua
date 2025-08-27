-- Bootstrap lazy.nvim if it's not installed
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

-- Load and configure plugins
require("lazy").setup({
	-- Mason: LSP installer
	--
	{
		"seblyng/roslyn.nvim",
		opts = {
			on_attach = function(client, bufnr)
				print("Roslyn attached to buffer " .. bufnr)
				-- optional: define your keymaps here
			end,

			cmd_env = {
				Configuration = "Debug", -- or "Release"
			},

			settings = {
				-- These are Roslyn-specific options
				csharp = {
					inlay_hints = {
						csharp_enable_inlay_hints_for_implicit_object_creation = true,
						csharp_enable_inlay_hints_for_implicit_variable_types = true,
					},
					code_lens = {
						dotnet_enable_references_code_lens = true,
					},
				},
			},
		},
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
				},
				automatic_installation = false,
			})
		end,
	},
	-- mason tool installer
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"roslyn",
					-- add others like "prettier", "eslint_d", etc.
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
	-- LSP Config
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("config.lsp")
		end,
	},

	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			require("config.cmp")
		end,
	},

	-- Formatter (Conform)
	{
		"stevearc/conform.nvim",
		config = function()
			require("config.format")
		end,
	},

	-- OPTIONAL: Session manager (disabled by default)
	-- {
	--   "rmagatti/auto-session",
	--   config = function()
	--     require("auto-session").setup({})
	--   end,
	-- },
})
