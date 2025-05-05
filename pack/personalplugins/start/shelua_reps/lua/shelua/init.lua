_G.sh = require('sh')
---@type SheluaOpts
local sh_settings = getmetatable(sh)
string.escapeShellArg = sh_settings.repr.posix.escape
-- allows AND and OR.
local concat_cmd = function(opts, cmd, input)
  local function normalize_shell_expr(v, cmd_mod)
    if v.c then return v.c end
    if v.s and cmd_mod and (v.e.__exitcode or 0) ~= 0 then
      return "{ printf '%s' " .. string.escapeShellArg(v.e.__stderr or v.s) .. " 1>&2; false; }"
    end
    return "printf '%s' " .. string.escapeShellArg(v.s)
  end
  if cmd:sub(1, 3) == "AND" then
    local initial = normalize_shell_expr(input[1], "AND")
    local res = {}
    for i = 2, #input do
      table.insert(res, normalize_shell_expr(input[i]))
    end
    if #res == 0 then error("AND requires at least 2 commands") end
    if #res == 1 then return initial .. " && " .. res[1] end
    return initial .. " && { " .. table.concat(res, " ; ") .. " ; }"
  elseif cmd:sub(1, 2) == "OR" then
    local initial = normalize_shell_expr(input[1], "OR")
    local res = {}
    for i = 2, #input do
      table.insert(res, normalize_shell_expr(input[i]))
    end
    if #res == 0 then error("OR requires at least 2 commands") end
    if #res == 1 then return initial .. " || " .. res[1] end
    return initial .. " || { " .. table.concat(res, " ; ") .. " ; }"
  elseif #input == 1 then
    return normalize_shell_expr(input[1]) .. " | " .. cmd
  elseif #input > 1 then
    for i, v in ipairs(input) do
      input[i] = normalize_shell_expr(v)
    end
    return "{ " .. table.concat(input, " ; ") .. " ; } | " .. cmd
  else
    return cmd
  end
end
local function mkToken(n) return setmetatable({}, { __tostring = function() return n end }) end
local AND, OR = mkToken("AND"), mkToken("OR")
-- allow AND, OR, and function type __input, escape_args == false doesnt work
local single_stdin = function(opts, cmd, inputs, codes)
  if cmd[1] == "AND" then
    if not inputs or #inputs < 2 then error("AND requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if (c0.__exitcode or 0) == 0 then
      cf.__input = table.concat(inputs)
      return AND, cf
    else
      c0.__input = inputs[1]
      return AND, c0
    end
  elseif cmd[1] == "OR" then
    if not inputs or #inputs < 2 then error("OR requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if c0.__exitcode == 0 then
      c0.__input = inputs[1]
      return OR, c0
    else
      cf.__input = table.concat(inputs)
      return OR, cf
    end
  else
    local function make_iterator(list)
      local i = 1
      local currfn = nil
      return function()
        if not list then return nil end
        while true do
          if currfn then
            local val = currfn()
            if val ~= nil then
              return val
            else
              currfn = nil
            end
          else
            local v = list[i]
            i = i + 1
            if v == nil then
              return nil
            elseif type(v) == "function" then
              currfn = v
            else
              return v
            end
          end
        end
      end
    end
    local env = {}
    for _, res in ipairs(codes or {}) do
      if res.__env then
        for k, v in pairs(res.__env) do
          env[k] = v
        end
      end
    end
    return cmd, { env = env, f = make_iterator(inputs) }
  end
end
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    result = vim.system({ "bash" }, { stdin = cmd, text = true }):wait()
  elseif cmd == AND or cmd == OR then
    msg.__exitcode = msg.__exitcode or 0
    msg.__signal = msg.__signal or 0
    msg.__stderr = msg.__stderr or ""
    return msg
  else
    result = vim.system(cmd, { env = msg.env, stdin = true, text = true })
    local n = msg.f()
    while n ~= nil do
      result:write(n)
      n = msg.f()
    end
    result:write(nil)
    result = result:wait()
  end
  return {
    __input = result.stdout,
    __stderr = result.stderr,
    __exitcode = result.code,
    __signal = result.signal,
    __env = false
  }
end
---@type Shelua.Repr
sh_settings.repr.nvim = {
  escape = function(s) return s end,
  arg_tbl = function(opts, k, a)
    k = (#k > 1 and '--' or '-') .. k
    if type(a) == 'boolean' and a then return k end
    if type(a) == 'string' then return k .. "=" .. string.escapeShellArg(a) end
    if type(a) == 'number' then return k .. '=' .. tostring(a) end
    return nil
  end,
  concat_cmd = concat_cmd,
  add_args = function(opts, cmd, args)
    if opts.proper_pipes then
      if opts.escape_args then
        for k, v in ipairs(args) do
          args[k] = string.escapeShellArg(v)
        end
      end
      return cmd .. " " .. table.concat(args, " ")
    else
      return setmetatable({ cmd, unpack(args) }, {
        __tostring = function(self) return table.concat(self, " ") end,
      })
    end
  end,
  single_stdin = single_stdin,
  post_5_2_run = run_command,
  pre_5_2_run = run_command,
  extra_cmd_results = function (opts)
    if opts.proper_pipes then
      return { "__stderr"}
    end
    return { "__env", "__stderr" }
  end,
}
sh_settings.shell = "nvim"
