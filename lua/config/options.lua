vim.opt.wrap = true
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard:prepend({ "unnamed", "unnamedplus" })
vim.cmd.colorscheme("slate")
vim.o.shell = "pwsh"
vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.o.shellquote = ""
vim.o.shellxquote = ""
