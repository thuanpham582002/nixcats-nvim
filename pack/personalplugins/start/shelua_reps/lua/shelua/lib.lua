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

---@param pipe uv.uv_stream_t 
---@param data string[]|string|fun()|nil
function M.write(pipe, data)
  if not pipe then
    error(debug.traceback('pipe has not been opened'))
  end

  if type(data) == 'table' then
    for _, v in ipairs(data) do
      pipe:write(v)
      pipe:write('\n')
    end
  elseif type(data) == 'string' then
    pipe:write(data)
  elseif type(data) == 'function' then
    local new = data()
    while new ~= nil do
      pipe:write(new)
      new = data()
    end
  elseif data == nil then
    -- Shutdown the write side of the duplex stream and then close the pipe.
    -- Note shutdown will wait for all the pending write requests to complete
    -- TODO(lewis6991): apparently shutdown doesn't behave this way.
    -- (https://github.com/neovim/neovim/pull/17620#discussion_r820775616)
    pipe:write('', function()
      pipe:shutdown(function()
        if pipe and not pipe:is_closing() then
          pipe:close()
        end
      end)
    end)
  end
end

--- Combine inputs into a writable in order (supports string, table, function, userdata)
---@param input_pipes any[]|any
---@param target_pipe uv.uv_stream_t
---@param close? boolean
function M.write_many(input_pipes, target_pipe, close)
  local inputs = type(input_pipes) == "table" and input_pipes or { input_pipes }
  local function process_next(i)
    local input = inputs[i]
    if not input then
      if close ~= false then
        M.write(target_pipe, nil)
      end
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
            M.write(target_pipe, chunk)
          end
          process_next(i + 1)
        end
      end)
    else
      M.write(target_pipe, input)
      process_next(i + 1)
    end
  end

  process_next(1)
end

return M
