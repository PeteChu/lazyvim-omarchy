-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = function(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Move line
keymap("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
keymap("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- replace without copy current selected
keymap("x", "<leader>p", [["_dP]])

-- Make file executable
keymap("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make [X]ecutable file" })

-- disable
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- macro
vim.keymap.set("n", "Q", "@qj", { noremap = true, silent = true })
vim.keymap.set("x", "Q", ":norm @q<cr>", { noremap = true, silent = true })

-- smart_dd
vim.keymap.set("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { noremap = true, expr = true })

vim.keymap.set("n", "yc", function()
  vim.api.nvim_feedkeys("yygccp", "m", false)
end)

vim.keymap.set("n", "<C-c>", "ciw")

if not vim.g.vscode then
  vim.api.nvim_create_user_command("G", require("neogit").open, {})
end
