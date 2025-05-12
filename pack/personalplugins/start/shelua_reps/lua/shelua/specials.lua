---@type table<string, Shelua.Special>
local M = {}

---@alias Shelua.Special.resolved any|Shelua.SystemObj

---@class Shelua.Special
---@field name? string
---@field single fun(opts, cmd, inputs, codes): string[]|fun():Shelua.SystemCompleted, { env: table<string, string|number>, towrite: any[] }
---@field resolve fun(opts, cmd, inputs): fun(close?: boolean):Shelua.Special.resolved
---@field recieve? fun(opts, res: Shelua.Special.resolved): nil|(fun(og: Shelua.SystemOpts):Shelua.SystemOpts), any[]?

local function concat_inputs(v0, input, cwd_override)
  return function()
    local full_out, full_err = {}, {}
    if type(v0.stdout) == "string" then table.insert(full_out, v0.stdout) end
    if type(v0.stderr) == "string" then table.insert(full_err, v0.stderr) end
    local last_code, last_signal
    local last_cwd = v0.cwd

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
          cwd = ce.__cwd or nil,
        }
      end
      if type(result.stdout) == "string" then table.insert(full_out, result.stdout) end
      if type(result.stderr) == "string" then table.insert(full_err, result.stderr) end
      last_code, last_signal, last_cwd = result.code, result.signal, result.cwd or last_cwd
    end
    return {
      wait = function ()
        return {
          stdout = table.concat(full_out),
          stderr = table.concat(full_err),
          code = last_code or 0,
          signal = last_signal or 0,
          cwd = cwd_override or last_cwd or nil,
        }
      end,
    }
  end
end

M.CD = {
  single = function(opts, cmd, inputs, codes)
    return function()
      local result = {
        __exitcode = 0,
        __signal = 0,
        __cwd = cmd[2] or error("cd requires a target directory"),
      }
      for i, v in ipairs(inputs) do
        local c = codes[i] or {}
        if v then
          result.__input = (result.__input or "") .. v
        end
        if c.__stderr then
          result.__stderr = (result.__stderr or "") .. c.__stderr
        end
        result.__exitcode = c.__exitcode or result.__exitcode
        result.__signal = c.__signal or result.__signal
      end
      return result
    end
  end,
  resolve = function (opts, cmd, input)
    local cwd = cmd[2] or error("cd requires a target directory")
    local v0 = input[1]
    if v0.c then
      return concat_inputs(v0.c():wait(), input, cwd)
    elseif v0.s then
      local c0 = v0.e or {}
      return concat_inputs({
        stdout = v0.s,
        code = c0.__exitcode or 0,
        signal = c0.__signal or 0,
        stderr = c0.__stderr,
      }, input, cwd)
    else
      return function(close)
        return {
          wait = function ()
            return {
              stdout = false,
              code = 0,
              signal = 0,
              stderr = "",
              cwd = cwd,
            }
          end
        }
      end
    end
  end,
  recieve = function (opts, res)
    local c = res()
    return function(prev)
      prev.cwd = c.cwd or prev.cwd
      return prev
    end, c:wait().stdout
  end,
}
M.cd = M.CD

M.AND = {
  single = function (opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("AND requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if (c0.__exitcode or 0) == 0 then
      return function()
        cf.__input = table.concat(inputs)
        for _, v in ipairs(codes) do
          if type(v) == "table" then
            cf.__cwd = v.__cwd
          end
        end
        return cf
      end
    else
      return function()
        c0.__input = inputs[1]
        return c0
      end
    end
  end,
  resolve = function (opts, cmd, input)
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
        cwd = c0.__cwd or opts.cwd or nil,
      }
    else
      error("NOT ENOUGH ARGS for AND")
    end
    if (v0.code or 0) ~= 0 then
      return function()
        return {
          wait = function ()
            return v0
          end
        }
      end
    else
      return concat_inputs(v0, input)
    end
  end,
}
M.OR = {
  single = function(opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("OR requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if c0.__exitcode == 0 then
      return function()
        c0.__input = inputs[1]
        return c0
      end
    else
      return function()
        cf.__input = table.concat(inputs)
        for _, v in ipairs(codes) do
          if type(v) == "table" then
            cf.__cwd = v.__cwd
          end
        end
        return cf
      end
    end
  end,
  resolve = function(opts, cmd, input)
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
        cwd = c0.__cwd or opts.cwd or nil,
      }
    else
      error("NOT ENOUGH ARGS for OR")
    end
    if (v0.code or 0) == 0 then
      return function()
        return {
          wait = function ()
            return v0
          end
        }
      end
    else
      return concat_inputs(v0, input)
    end
  end,
}

---@param spec Shelua.Special
local function mkSpecial(spec) return setmetatable({
  name = spec.name,
  resolve = spec.resolve,
  single = spec.single,
  recieve = spec.recieve or function (c) return nil, c():wait().stdout end,
}, { __tostring = function() return spec.name end }) end
for key, value in pairs(M) do
  value.name = key
  M[key] = mkSpecial(value)
end
return M
