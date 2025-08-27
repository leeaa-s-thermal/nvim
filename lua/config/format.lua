-- lua/config/format.lua

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
	},
	notify_on_error = false,
})

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		require("conform").format({
			bufnr = args.buf,
			lsp_fallback = true,
			async = false,
		})
	end,
})

-- Manual formatting key
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({
		async = false,
		lsp_fallback = true,
	})
end, { desc = "Format buffer" })
