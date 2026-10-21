local M = {}

local function notify_error(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

---@param cmd string[]
---@return string? stdout
---@return string? err
local function run(cmd)
  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr)
  end
  return vim.trim(res.stdout)
end

function M.open(opts)
  opts = opts or {}
  local filepath = vim.fn.expand("%:p")

  if not vim.endswith(filepath, ".md") then
    return notify_error("not a markdown file")
  end

  if vim.fn.executable("glow") == 0 or vim.fn.executable("tmux") == 0 then
    return notify_error('"glow" or "tmux" is not installed')
  end

  if not vim.env.TMUX then
    return notify_error("must be inside a tmux session")
  end

  local out, err = run({ "tmux", "display-message", "-p", "#{pane_width}" })
  local width = tonumber(out)
  if not width then
    return notify_error("failed to get pane width: " .. tostring(err))
  end

  local new_width = opts.horizontal and width - 2 or math.floor(width / 2) - 1
  local glow_cmd = ("glow -w %d -t %s"):format(new_width, vim.fn.shellescape(filepath))
  local pane, split_err =
    run({ "tmux", "split-window", opts.horizontal and "-v" or "-h", "-P", "-F", "#{pane_id}", glow_cmd })
  if not pane then
    return notify_error("failed to open glow: " .. split_err)
  end

  -- Glow has no keymap config, and h/Escape/Left leave the preview for an empty file list.
  run({ "tmux", "set", "-p", "-t", pane, "@glow_preview", "1" })
  for _, key in ipairs({ "h", "Escape", "Left" }) do
    run({ "tmux", "bind", "-n", key, "if", "-F", "#{@glow_preview}", "", "send-keys " .. key })
  end

  -- shortcut: Glow's TUI ignores width on its first render; remove after upstream fixes it.
  vim.defer_fn(function()
    run({ "tmux", "send-keys", "-t", pane, "r" })
  end, 100)
end

return M
