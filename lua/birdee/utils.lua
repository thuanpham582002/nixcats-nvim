local M = {}

---@param file_path string
---@return boolean existed
function M.deleteFileIfExists(file_path)
  if vim.fn.filereadable(file_path) == 1 then
    os.remove(file_path)
    return true
  end
  return false
end

function M.split_string(str, delimiter)
  local result = {}
  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

---Requires plenary
---@param cmd string[]
---@param cwd string
---@return table
---@return unknown
---@return table
function M.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print("[get_os_command_output]: cmd has to be a table")
    ---@diagnostic disable-next-line: return-type-mismatch
    return {}, nil, nil
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = require("plenary.job")
      :new({
        command = command,
        args = cmd,
        cwd = cwd,
        on_stderr = function(_, data)
          table.insert(stderr, data)
        end,
      })
      :sync()
  return stdout, ret, stderr
end

function M.authTerminal()
  local session
  local handle
  local ok = false
  handle = io.popen([[bw login --check ]], "r")
  if handle then
    session = handle:read("*l")
    handle:close()
  end
  if vim.fn.expand('$BW_SESSION') ~= "$BW_SESSION" then
    session = vim.fn.expand('$BW_SESSION')
  else
    if session == "You are logged in!" then
      handle = io.popen([[bw unlock --raw --nointeraction ]] .. vim.fn.inputsecret('Enter password: '), "r")
      if handle then
        session = handle:read("*l")
        handle:close()
        ok = true
      end
    else
      local email = vim.fn.inputsecret('Enter email: ')
      local pass = vim.fn.inputsecret('Enter password: ')
      handle = io.popen([[bw login --raw --quiet ]] .. email .. " " .. pass .. ">/dev/null 2>&1", "w")
      if handle then
        local client_secret = vim.fn.inputsecret('Enter new device login code: ')
        handle:write(client_secret)
        handle:close()
      end
      handle = io.popen([[bw unlock --raw --nointeraction ]] .. pass, "r")
      if handle then
        session = handle:read("*l")
        handle:close()
        ok = true
      end
    end
  end
  return session, ok
end

---@class birdee.authentry
---@field enable boolean
---@field cache boolean
---@field bw_id string
---@field localpath string
---@field action fun(key)

---@param entries table<string, birdee.authentry>
function M.get_auths(entries)
  local to_fetch = {}
  local cached = {}
  for name, entry in pairs(entries) do
    if entry.enable ~= false and entry.bw_id and entry.localpath and vim.fn.filereadable(entry.localpath) == 0 then
      to_fetch[name] = entry
    elseif entry.enable ~= false and entry.localpath and vim.fn.filereadable(entry.localpath) ~= 0 then
      cached[name] = entry
    end
  end
  local final = {}
  if next(to_fetch) ~= nil then
    local session, ok = M.authTerminal()
    if session and ok then
      for name, entry in pairs(to_fetch) do
        local handle = io.popen("bw get --nointeraction --session " .. session .. " " .. entry.bw_id, "r")
        local key
        if handle then
          key = handle:read("*l")
          handle:close()
        end
        if entry.cache and key then
          local handle2 = io.open(entry.localpath, "w")
          if handle2 then
            handle2:write(key)
            handle2:close()
            vim.loop.fs_chmod(entry.localpath, 384, function(err, success)
              if err then
                print("Failed to set file permissions: " .. err)
              end
            end)
          end
        end
        final[name] = handle and key or nil
      end
    end
  end
  for name, entry in pairs(cached) do
    local handle = io.open(entry.localpath, "r")
    local key
    if handle then
      key = handle:read("*l")
      handle:close()
    end
    final[name] = handle and key or nil
  end
  for name, key in pairs(final) do
    if entries[name].action then
      entries[name].action(key)
    end
  end
end

---@type fun(moduleName: string): any
function M.lazy_require_funcs(moduleName)
  return setmetatable({}, {
    __call = function (_, ...)
        return require(moduleName)(...)
    end,
    __index = function(_, key)
      return function(...)
        local module = require(moduleName)
        return module[key](...)
      end
    end,
  })
end

function M.nix_table()
  local allow_createfn = true
  local createfn
  createfn = function(key)
      return allow_createfn and vim.defaulttable(createfn) or nil
  end
  return setmetatable({}, {
    __index = function(tbl, key)
      if allow_createfn and key == "resolve" then
        return function()
          allow_createfn = false
          return tbl
        end
      end
      rawset(tbl, key, createfn(key))
      return rawget(tbl, key)
    end,
  })
end

function M.lsp_ft_fallback(name)
  local nvimlspcfg = nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) or nixCats.pawsible({ "allPlugins", "start", "nvim-lspconfig" })
  if not nvimlspcfg then
    local matches = vim.api.nvim_get_runtime_file("pack/*/*/nvim-lspconfig", false)
    nvimlspcfg = assert(matches[1], "nvim-lspconfig not found!")
  end
  vim.api.nvim_create_user_command("LspGetFiletypesToClipboard",function(opts)
    local lspname = assert(opts.fargs[1] or vim.fn.getreg("+") or name, "no name to search for provided or in clipboard")
    local ok, lspcfg = pcall(dofile, nvimlspcfg .. "/lsp/" .. lspname .. ".lua")
    if not ok or not lspcfg then error("failed to get config for lsp: " .. lspname) end
    vim.fn.setreg("+",
      "filetypes = "
      .. vim.inspect(lspcfg.filetypes or {})
      .. ","
    )
  end, { nargs = '?' })
  vim.schedule(function() vim.notify((name or "lsp") .. " not provided filetype", vim.log.levels.WARN) end)
  return name and dofile(nvimlspcfg .. "/lsp/" .. name .. ".lua").filetypes or {}
end

return M
