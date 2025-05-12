---@type Shelua
local sh = require('sh')
---@type Shelua.Opts
local sh_settings = getmetatable(sh)
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
local SPECIAL = require('shelua.specials')
-- allow AND, OR, and __env. Allows function type __input, escape_args == false doesnt work
function sh_settings.repr.nvim.concat_cmd(opts, cmd, input)
  local special
  for k, def in pairs(SPECIAL) do
    if cmd[1] == k then
      special = def
    end
  end
  if special then
    return special.resolve(opts, cmd, input), special
  elseif #input == 1 then
    local v = input[1] or {}
    return function(close)
      local runargs, towrite
      if v.m then
        runargs, towrite = v.m.recieve(v.c)
      elseif v.c then
        towrite = v.c()._state.stdout
      else
        runargs = {
          stdin = close == false and true or v.s,
          env = (v.e or {}).__env,
          text = true,
        }
        if close == false and v.s then
          towrite = { v.s }
        end
      end
      runargs = runargs or {
        stdin = true,
        text = true,
      }
      local result = sherun(cmd, runargs)
      if towrite then
        result:write_many(towrite, close)
      end
      return result
    end
  elseif #input > 1 then
    return function (close)
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
        if v.m then
          table.insert(towrite, v.m.recieve(v.c))
        elseif v.c then
          table.insert(towrite, v.c()._state.stdout)
        else
          table.insert(towrite, v.s)
        end
      end
      result:write_many(towrite, close)
      return result
    end
  else
    return function(close)
      return sherun(cmd, { stdin = close == false, text = true })
    end
  end
end
-- allow AND, OR, and __env. Allows function type __input, escape_args == false doesnt work
function sh_settings.repr.nvim.single_stdin(opts, cmd, inputs, codes)
  local special
  for k, def in pairs(SPECIAL) do
    if cmd[1] == k then
      special = def
      break
    end
  end
  if special then
    return special.single(opts, cmd, inputs, codes)
  else
    local env = {}
    local towrite = {}
    for i, res in ipairs(codes or {}) do
      local newin = inputs[i]
      if newin then
        table.insert(towrite, newin)
      end
      if res.__env then
        for k, v in pairs(res.__env) do
          env[k] = v
        end
      end
    end
    return cmd, { env = env, towrite = towrite }
  end
end
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    result = cmd():wait()
  elseif type(cmd) == "function" then
    result = cmd()
    result.__exitcode = result.__exitcode or 0
    result.__signal = result.__signal or 0
    result.__stderr = result.__stderr or ""
    return result
  else
    result = sherun(cmd, { env = msg.env, stdin = true, text = true })
    result:write_many(msg.towrite)
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
sh_settings.repr.nvim.post_5_2_run = run_command
sh_settings.repr.nvim.pre_5_2_run = run_command
return sh
