return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        win = {
          config = function(terminal)
            if vim.api.nvim_win_get_width(0) < 2 * terminal.opts.split.width then
              terminal.opts.layout = "bottom"
            end
          end,
        },
        tools = {
          omp = {
            cmd = { "omp" }
          }
        }
      }
    },
  }
}
