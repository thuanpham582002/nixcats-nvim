---@type Shelua
local sh = require('sh')
---@type Shelua.Opts
local sh_settings = getmetatable(sh)
local shelib = require('shelua.lib')
local sherun = require("shelua.system").run
---@type Shelua.Repr
sh_settings.repr.nvim = {
  escape = function(s) return s end,
  arg_tbl = function(opts, k, a)
    k = (#k > 1 and '--' or '-') .. k
    if type(a) == 'boolean' and a then return k end
    if type(a) == 'string' then return { k, tostring(a) } end
    if type(a) == 'number' then return { k, tostring(a) } end
    return nil
  end,
  add_args = function(opts, cmd, args)
    return setmetatable({ cmd, unpack(args) }, {
      __tostring = function(self) return table.concat(self, " ") end,
    })
  end,
  extra_cmd_results = { "__env", "__stderr" },
}
sh_settings.shell = "nvim"
local AND, OR = shelib.mkToken("AND"), shelib.mkToken("OR")
-- supports __env (not yet AND or OR)
function sh_settings.repr.nvim.concat_cmd(opts, cmd, input)
  if cmd[1] == "AND" then
    local v0 = input[1]
    if v0.c then
      v0 = v0.c():wait()
    elseif v0.s then
      local c0 = v0.e or {}
      v0 = {
        stdout = v0.s,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
      }
    else
      error("NOT ENOUGH ARGS")
    end
    if (v0.code or 0) ~= 0 then
      return function()
        return {
          wait = function ()
            return v0
          end
        }
      end, AND
    else
      local full_out, full_err = {}, {}
      if v0.stdout then table.insert(full_out, v0.stdout) end
      if v0.stderr then table.insert(full_err, v0.stderr) end

      local last_code, last_signal
      for i = 2, #input do
        local v = input[i]
        local result
        if v.c then
          result = v.c():wait()
        else
          local ce = v.e or {}
          result = {
            stdout = v.s,
            code = ce.__exitcode or 0,
            signal = ce.__signal or 0,
            stderr = ce.__stderr,
          }
        end
        if result.stdout then table.insert(full_out, result.stdout) end
        if result.stderr then table.insert(full_err, result.stderr) end
        last_code, last_signal = result.code, result.signal
      end

      return function()
        return {
          wait = function ()
            return {
              stdout = table.concat(full_out),
              stderr = table.concat(full_err),
              code = last_code or 0,
              signal = last_signal,
            }
          end,
        }
      end, AND
    end
  elseif cmd[1] == "OR" then
    local v0 = input[1]
    if v0.c then
      v0 = v0.c():wait()
    elseif v0.s then
      local c0 = v0.e or {}
      v0 = {
        stdout = v0.s,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
      }
    else
      error("NOT ENOUGH ARGS")
    end
    if (v0.code or 0) == 0 then
      return function()
        return {
          wait = function ()
            return v0
          end
        }
      end, OR
    else
      local full_out, full_err = {}, {}
      if v0.stdout then table.insert(full_out, v0.stdout) end
      if v0.stderr then table.insert(full_err, v0.stderr) end

      local last_code, last_signal
      for i = 2, #input do
        local v = input[i]
        local result
        if v.c then
          result = v.c():wait()
        else
          local ce = v.e or {}
          result = {
            stdout = v.s,
            code = ce.__exitcode or 0,
            signal = ce.__signal or 0,
            stderr = ce.__stderr,
          }
        end
        if result.stdout then table.insert(full_out, result.stdout) end
        if result.stderr then table.insert(full_err, result.stderr) end
        last_code, last_signal = result.code, result.signal
      end

      return function()
        return {
          wait = function ()
            return {
              stdout = table.concat(full_out),
              stderr = table.concat(full_err),
              code = last_code,
              signal = last_signal,
            }
          end,
        }
      end, OR
    end
  elseif #input == 1 then
    local v = input[1] or {}
    if v.m == AND or v.m == OR then
      local result = sherun(cmd, {
        stdin = true,
        text = true,
      })
      shelib.combine_pipes(v.c():wait().stdout, result)
      return result
    elseif v.c then
      return function()
        local result = sherun(cmd, {
          stdin = true,
          text = true,
        })
        shelib.combine_pipes(v.c()._state.stdout, result)
        return result
      end
    else
      return function()
        return sherun(cmd, {
          stdin = v.s,
          env = (v.e or {}).__env,
          text = true,
        })
      end
    end
  elseif #input > 1 then
    return function ()
      local env = {}
      for _, v in ipairs(input) do
        for k, val in pairs((v.e or {}).__env or {}) do
          env[k] = val
        end
      end
      local result = sherun(cmd, {
        stdin = true,
        env = env,
        text = true,
      })
      local towrite = {}
      for _, v in ipairs(input) do
        if v.m == AND or v.m == OR then
          table.insert(towrite, v.c():wait().stdout)
        elseif v.c then
          table.insert(towrite, v.c()._state.stdout)
        else
          table.insert(towrite, v.s)
        end
      end
      shelib.combine_pipes(towrite, result)
      return result
    end
  else
    return function()
      return sherun(cmd, { text = true })
    end
  end
end
-- allow AND, OR, and __env. Allows function type __input, escape_args == false doesnt work
function sh_settings.repr.nvim.single_stdin(opts, cmd, inputs, codes)
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
    local env = {}
    for _, res in ipairs(codes or {}) do
      if res.__env then
        for k, v in pairs(res.__env) do
          env[k] = v
        end
      end
    end
    return cmd, { env = env, f = shelib.str_fun_iterator(inputs) }
  end
end
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    result = cmd():wait()
  elseif cmd == AND or cmd == OR then
    msg.__exitcode = msg.__exitcode or 0
    msg.__signal = msg.__signal or 0
    msg.__stderr = msg.__stderr or ""
    return msg
  else
    result = sherun(cmd, { env = msg.env, stdin = msg.f, text = true }):wait()
  end
  return {
    __input = result.stdout,
    __stderr = result.stderr,
    __exitcode = result.code,
    __signal = result.signal,
    __env = false
  }
end
sh_settings.repr.nvim.post_5_2_run = run_command
sh_settings.repr.nvim.pre_5_2_run = run_command
return sh
