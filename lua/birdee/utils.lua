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

function M.authTerminal(api_client_secret)
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
      local client_secret = api_client_secret or vim.fn.inputsecret('Enter api key client_secret: ')
      handle = io.popen([[bw login --raw --quiet ]] .. email .. " " .. pass .. ">/dev/null 2>&1", "w")
      if handle then
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
    local match = next(vim.api.nvim_get_runtime_file("pack/*/*/nvim-lspconfig", false))
    nvimlspcfg = assert(match and match[1], "nvim-lspconfig not found!")
  end
  vim.api.nvim_create_user_command("LspGetFiletypesToClipboard",function(opts)
    local lspname = opts.fargs[1] or vim.fn.getreg("+") or name
    local lsppath = "/lsp/" .. lspname .. ".lua"
    local ok, lspcfg = pcall(dofile, nvimlspcfg .. lsppath)
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
