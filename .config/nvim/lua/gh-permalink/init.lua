local M = {}

local defaults = {
  remote = "origin",
  warn_on_dirty = true,
  mappings = nil,
}

local config = vim.deepcopy(defaults)

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "gh-permalink.nvim" })
end

local function git(args, cwd)
  local cmd = { "git" }
  if cwd and cwd ~= "" then
    table.insert(cmd, "-C")
    table.insert(cmd, cwd)
  end

  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, table.concat(output, "\n")
  end

  return output, nil
end

local function first_line(output)
  if not output or output[1] == nil or output[1] == "" then
    return nil
  end
  return output[1]
end

local function strip_suffix(value, suffix)
  if value:sub(-#suffix) == suffix then
    return value:sub(1, #value - #suffix)
  end
  return value
end

local function parse_remote_url(remote_url)
  remote_url = vim.trim(remote_url or "")
  remote_url = strip_suffix(remote_url, ".git")

  local host, repo = remote_url:match("^https?://([^/]+)/(.+)$")
  if host and repo then
    host = host:gsub("^.*@", "")
    return host, repo
  end

  host, repo = remote_url:match("^git://([^/]+)/(.+)$")
  if host and repo then
    return host, repo
  end

  host, repo = remote_url:match("^ssh://[^@]+@([^/:]+):?%d*/(.+)$")
  if host and repo then
    return host, repo
  end

  host, repo = remote_url:match("^[^@]+@([^:]+):(.+)$")
  if host and repo then
    return host, repo
  end

  return nil, nil
end

local function encode_path(path)
  return (path:gsub("([^%w%-%._~/%:])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil, "Current buffer has no file name"
  end

  return vim.fn.fnamemodify(path, ":p"), nil
end

local function file_context()
  local file, file_err = current_file()
  if not file then
    return nil, file_err
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local root = first_line(git({ "rev-parse", "--show-toplevel" }, dir))
  if not root then
    return nil, "Current file is not inside a Git repository"
  end

  local root_real = vim.loop.fs_realpath(root) or root
  local file_real = vim.loop.fs_realpath(file) or file
  local prefix = root_real .. "/"

  if file_real:sub(1, #prefix) ~= prefix then
    return nil, "Could not resolve file path relative to Git root"
  end

  local relpath = file_real:sub(#prefix + 1)
  local tracked = git({ "ls-files", "--error-unmatch", "--", relpath }, root)
  if not tracked then
    return nil, "Current file is not tracked by Git"
  end

  return {
    file = file,
    root = root,
    relpath = relpath,
  }, nil
end

local function range_from_opts(opts)
  opts = opts or {}
  local line1 = opts.line1
  local line2 = opts.line2

  if not line1 or line1 == 0 then
    line1 = vim.fn.line(".")
  end
  if not line2 or line2 == 0 then
    line2 = line1
  end
  if line2 < line1 then
    line1, line2 = line2, line1
  end

  return line1, line2
end

local function dirty_warning(ctx)
  if not config.warn_on_dirty then
    return
  end

  local status = git({ "status", "--porcelain", "--untracked-files=no", "--", ctx.relpath }, ctx.root)
  if status and #status > 0 then
    notify("File has uncommitted changes; the permalink points at HEAD, so line numbers may not match.", vim.log.levels.WARN)
  end
end

function M.url(opts)
  local ctx, ctx_err = file_context()
  if not ctx then
    return nil, ctx_err
  end

  local rev = first_line(git({ "rev-parse", "HEAD" }, ctx.root))
  if not rev then
    return nil, "Could not resolve HEAD"
  end

  local remote_name = (opts and opts.remote) or config.remote
  local remote_url = first_line(git({ "remote", "get-url", remote_name }, ctx.root))
  if not remote_url then
    return nil, "Could not resolve Git remote: " .. remote_name
  end

  local host, repo = parse_remote_url(remote_url)
  if not host or not repo then
    return nil, "Could not parse GitHub remote URL: " .. remote_url
  end

  dirty_warning(ctx)

  local line1, line2 = range_from_opts(opts)
  local url = ("https://%s/%s/blob/%s/%s#L%d"):format(host, repo, rev, encode_path(ctx.relpath), line1)
  if line2 ~= line1 then
    url = url .. ("-L%d"):format(line2)
  end

  return url, nil
end

local function set_clipboard(url)
  vim.fn.setreg("+", url)
  vim.fn.setreg('"', url)
end

local function open_url(url)
  if vim.ui and vim.ui.open then
    vim.ui.open(url)
    return
  end

  local opener
  if vim.fn.has("mac") == 1 then
    opener = { "open", url }
  elseif vim.fn.has("win32") == 1 then
    opener = { "rundll32", "url.dll,FileProtocolHandler", url }
  else
    opener = { "xdg-open", url }
  end

  vim.fn.jobstart(opener, { detach = true })
end

function M.open(opts)
  local url, err = M.url(opts)
  if not url then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  open_url(url)
  notify(url)
  return url
end

function M.copy(opts)
  local url, err = M.url(opts)
  if not url then
    notify(err, vim.log.levels.ERROR)
    return nil
  end

  set_clipboard(url)
  notify("Copied " .. url)
  return url
end

local function command_opts(command)
  if command.range and command.range > 0 then
    return { line1 = command.line1, line2 = command.line2 }
  end
  return { line1 = vim.fn.line("."), line2 = vim.fn.line(".") }
end

local function create_commands()
  vim.api.nvim_create_user_command("GHLink", function(command)
    M.open(command_opts(command))
  end, { range = true, force = true, desc = "Open a GitHub permalink for the current line or range" })

  vim.api.nvim_create_user_command("GHLinkCopy", function(command)
    M.copy(command_opts(command))
  end, { range = true, force = true, desc = "Copy a GitHub permalink for the current line or range" })
end

local function create_mappings()
  if not config.mappings then
    return
  end

  if config.mappings.open then
    vim.keymap.set("n", config.mappings.open, M.open, { desc = "Open GitHub permalink" })
    vim.keymap.set("x", config.mappings.open, ":'<,'>GHLink<CR>", { desc = "Open GitHub permalink" })
  end

  if config.mappings.copy then
    vim.keymap.set("n", config.mappings.copy, M.copy, { desc = "Copy GitHub permalink" })
    vim.keymap.set("x", config.mappings.copy, ":'<,'>GHLinkCopy<CR>", { desc = "Copy GitHub permalink" })
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  create_commands()
  create_mappings()
end

M._parse_remote_url = parse_remote_url
M._encode_path = encode_path

return M
