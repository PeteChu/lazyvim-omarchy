vim.api.nvim_create_user_command("Glow", function()
  require("glow").open()
end, {})


vim.api.nvim_create_user_command("Glowh", function()
  require("glow").open({ horizontal = true })
end, {})
