-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.colorcolumn = "80"
vim.opt.wrap = true

vim.opt.swapfile = false

vim.opt.relativenumber = true
vim.g.autoformat = true

vim.opt.laststatus = 3

vim.cmd([[
  set list
  set listchars+=eol:↲
  set winbar=%=%m\ %f
]])
