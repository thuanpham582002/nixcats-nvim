_G.sh = require('sh')
---@type SheluaOpts
local sh_settings = getmetatable(sh)
string.escapeShellArg = sh_settings.repr.posix.escape
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
local concat_cmd = function(opts, cmd, input)
  local function normalize_shell_expr(v)
    if v.c then return v.c end
    if v.s and (v.e.__exitcode or 0) == 0 then
      return "echo " .. string.escapeShellArg(v.s)
    end
    return "{ echo " .. string.escapeShellArg(v.e.__stderr or v.s) .. " 1>&2; false; }"
  end
  if cmd:sub(1, 3) == "AND" then
    for i, v in ipairs(input) do
      input[i] = normalize_shell_expr(v)
    end
    return table.concat(input, " && ")
  elseif cmd:sub(1, 2) == "OR" then
    for i, v in ipairs(input) do
      input[i] = normalize_shell_expr(v)
    end
    return table.concat(input, " || ")
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
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    -- result = vim.system({ "bash", '-c', cmd }, { text = true }):wait()
    local tmp = os.tmpname()
    result = vim.system({ "bash", os.write_file({ newline = false }, tmp, cmd) }, { text = true }, function() os.remove(tmp) end):wait()
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
  single_stdin = function(opts, cmd, inputs, codes)
    return cmd, inputs
  end,
  post_5_2_run = run_command,
  pre_5_2_run = run_command,
  extra_cmd_results = { "__stderr" },
}
sh_settings.shell = "vim"
