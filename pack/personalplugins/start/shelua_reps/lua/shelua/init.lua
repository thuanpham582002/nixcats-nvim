function os.write_file(opts, filename, content)
  local file = io.open(filename, opts.append and "a" or "w")
  if not file then return nil end
  file:write(content .. (opts.newline ~= false and "\n" or ""))
  file:close()
  return filename
end
function os.read_file(filename)
  local file = io.open(filename, "r")
  if not file then return nil end
  local content = file:read("*a")
  file:close()
  return content
end
_G.sh = require('sh')
---@type SheluaOpts
local sh_settings = getmetatable(sh)
string.escapeShellArg = sh_settings.repr.posix.escape
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
local AND = setmetatable({}, { __tostring = function() return "AND" end })
local OR = setmetatable({}, { __tostring = function() return "OR" end })
local single_stdin = function(opts, cmd, inputs, codes)
  if cmd[1] == "AND" then
    if not inputs or #inputs < 2 then error("AND requires at least 2 commands") end
    local c0 = codes[1]
    local cf = codes[#codes]
    if c0.__exitcode == 0 then
      local res = ""
      for _, v in ipairs(inputs) do
        res = res .. v
      end
      cf.__input = res
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
      local res = ""
      for _, v in ipairs(inputs) do
        res = res .. v
      end
      cf.__input = res
      return OR, cf
    end
  else
    return cmd, inputs and table.concat(inputs) or nil
  end
end
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    result = vim.system({ "bash", '-c', cmd }, { text = true }):wait()
    -- local tmp = os.tmpname()
    -- result = vim.system({ "bash", os.write_file({ newline = false }, tmp, cmd) }, { text = true }, function() os.remove(tmp) end):wait()
  elseif cmd == AND or cmd == OR then
    msg.__exitcode = msg.__exitcode or 0
    msg.__signal = msg.__signal or 0
    msg.__stderr = msg.__stderr or ""
    return msg
  else
    result = vim.system(cmd, { stdin = msg, text = true }):wait()
  end
  return {
    __input = result.stdout,
    __stderr = result.stderr,
    __exitcode = result.code,
    __signal = result.signal,
  }
end
---@type Shelua.Repr
sh_settings.repr.vim = {
  escape = function(s) return s end,
  arg_tbl = sh_settings.repr.posix.arg_tbl,
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
  extra_cmd_results = { "__stderr" },
}
sh_settings.shell = "vim"
