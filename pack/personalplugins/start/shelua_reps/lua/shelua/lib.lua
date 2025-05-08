local uv = vim and (vim.uv or vim.loop) or require("luv")
local M = {}

function M.mkToken(n) return setmetatable({}, { __tostring = function() return n end }) end

function M.str_fun_iterator(list)
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
        if type(v) == "function" then
          currfn = v
        elseif type(v) == "string" then
          return v
        elseif v == nil then
          return nil
        end
      end
    end
  end
end
--- Combine inputs into a writable in order (supports string, table, function, userdata)
---@param input_pipes any[]|any
---@param writeable uv.uv_stream_t|vim.SystemObj
function M.combine_pipes(input_pipes, writeable)
  local inputs = type(input_pipes) == "table" and input_pipes or { input_pipes }

  local function process_next(i)
    local input = inputs[i]
    if not input then
      writeable:write(nil)
      return
    end

    if type(input) == "userdata" then
      local buffer = {}
      input:read_start(function(err, data)
        assert(not err, err)
        if data then
          table.insert(buffer, data)
        else
          input:close()
          for _, chunk in ipairs(buffer) do
            writeable:write(chunk)
          end
          process_next(i + 1)
        end
      end)

    elseif type(input) == "table" then
      for _, v in ipairs(input) do
        writeable:write(v)
      end
      process_next(i + 1)

    elseif type(input) == "string" then
      writeable:write(input)
      process_next(i + 1)

    elseif type(input) == "function" then
      local val = input()
      while val ~= nil do
        writeable:write(val)
        val = input()
      end
      process_next(i + 1)

    else
      process_next(i + 1) -- skip unrecognized
    end
  end

  process_next(1)
end

return M
