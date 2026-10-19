local M = {}

local function is_markdown(filename)
  local md_ext = ".md"
  return filename:sub(-string.len(md_ext)) == md_ext
end

local function is_glow_installed()
  return vim.fn.executable("glow") == 1
end

local function is_tmux_installed()
  return vim.fn.executable("tmux") == 1
end

local function trim(s)
  return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

---@param command string
---@return string output
---@return boolean|nil ok
---@return string|nil reason
---@return integer|nil code
local function run_command(command)
  local pipe = assert(io.popen(command .. " 2>&1"), "r")
  local output = pipe:read("*a")
  local ok, reason, code = pipe:close()

  return trim(output), ok, reason, code
end

---@return boolean
local function is_inside_tmux()
  return run_command("echo $TMUX") ~= ""
end

local function get_pane_width()
  local width, ok, reason = run_command("tmux display-message -p '#{pane_width}'")
  if not ok then
    return "0", false, reason
  end

  return width, true, nil
end

---@param opts? { horizontal?: boolean } horizontal opens the preview below instead of beside
function M.open(opts)
  local horizontal = opts and opts.horizontal
  local filepath = vim.fn.expand("%:p")

  if not filepath or filepath == "" or not is_markdown(filepath) then
    vim.notify("not a markdown file", vim.log.levels.ERROR)
    return
  end

  if not is_glow_installed() or not is_tmux_installed() then
    vim.notify('"glow" or "tmux" is not install.', vim.log.levels.ERROR)
    return
  end

  if not is_inside_tmux() then
    vim.notify("must be inside tmux session", vim.log.levels.ERROR)
    return
  end

  local width, ok, err = get_pane_width()
  if not ok then
    vim.notify(("failed to get pane width: %s"):format(err), vim.log.levels.ERROR)
    return
  end

  local new_width = horizontal and tonumber(width) - 2 or math.floor(tonumber(width) / 2) - 1
  local glow_cmd = "glow -w " .. new_width .. " -t " .. vim.fn.shellescape(filepath)
  local split_flag = horizontal and "-v" or "-h"
  local pane, opened, reason =
    run_command("tmux split-window " .. split_flag .. " -P -F '#{pane_id}' " .. vim.fn.shellescape(glow_cmd))
  if not opened then
    vim.notify(("failed to open glow: %s"):format(reason), vim.log.levels.ERROR)
    return
  end

  -- Glow has no keymap config, and h/Escape/Left leave the preview for an empty file list.
  os.execute("tmux set -p -t " .. vim.fn.shellescape(pane) .. " @glow_preview 1")
  for _, key in ipairs({ "h", "Escape", "Left" }) do
    os.execute(("tmux bind -n %s if -F '#{@glow_preview}' '' 'send-keys %s'"):format(key, key))
  end

  -- shortcut: Glow's TUI ignores width on its first render; remove after upstream fixes it.
  vim.defer_fn(function()
    os.execute("tmux send-keys -t " .. vim.fn.shellescape(pane) .. " r")
  end, 100)
end

return M
