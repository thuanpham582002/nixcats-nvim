---@type table<string, Shelua.Special>
local M = {}

---@alias Shelua.Special.resolved any|Shelua.SystemObj

---@class Shelua.Special
---@field name? string
---@field single fun(opts, cmd, inputs, codes): any[]|fun():Shelua.SystemCompleted, { env: table<string, string|number>, towrite: any[] }
---@field resolve fun(opts, cmd, inputs): fun(close?: boolean):Shelua.Special.resolved
---@field recieve? fun(opts, res: Shelua.Special.resolved): nil|fun(og: Shelua.SystemOpts):Shelua.SystemOpts, any[]

M.AND = {
  single = function (opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("AND requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if (c0.__exitcode or 0) == 0 then
      cf.__input = table.concat(inputs)
      return function() return cf end
    else
      c0.__input = inputs[1]
      return function() return c0 end
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
      end
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
              signal = last_signal or 0,
            }
          end,
        }
      end
    end
  end,
}
M.OR = {
  single = function(opts, cmd, inputs, codes)
    if not inputs or #inputs < 2 then error("OR requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if c0.__exitcode == 0 then
      c0.__input = inputs[1]
      return function() return c0 end
    else
      cf.__input = table.concat(inputs)
      return function() return cf end
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
      end
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
              signal = last_signal or 0,
            }
          end,
        }
      end
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
