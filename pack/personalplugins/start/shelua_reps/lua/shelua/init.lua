_G.sh = require('sh')
---@type SheluaOpts
local sh_settings = getmetatable(sh)
local escapeShellArg = sh_settings.repr.posix.escape

local concat_cmd = function(opts, cmd, input)
    if #input == 1 then
        local v = input[1]
        if v.s then
            return "echo " .. escapeShellArg(v.s) .. " | " .. cmd
        else
            return v.c .. " | " .. cmd
        end
    elseif #input > 1 then
        for i = 1, #input do
            local v = input[i]
            if v.s then
                input[i] = "echo " .. escapeShellArg(v.s)
            elseif v.c then
                ---@diagnostic disable-next-line: assign-type-mismatch
                input[i] = v.c
            end
        end
        return "{ " .. table.concat(input, " ; ") .. " ; } | " .. cmd
    else
        return cmd
    end
end
local function run_command(opts, cmd, msg)
  local result
  if opts.proper_pipes then
    result = vim.system({ "bash", "-c", cmd }, { text = true }):wait()
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
  escape = function (s) return s end,
  arg_tbl = sh_settings.repr.posix.arg_tbl,
  concat_cmd = concat_cmd,
  add_args = function(opts, cmd, args)
    if opts.proper_pipes then
        if opts.escape_args then
          for k, v in ipairs(args) do
            args[k] = escapeShellArg(v)
          end
        end
        return cmd .. " " .. table.concat(args, " ")
    else
      return setmetatable({ cmd, unpack(args) }, {
        __tostring = function(self)
          return table.concat(self, " ")
        end,
      })
    end
  end,
  single_stdin = function (opts, cmd, inputs, codes)
    return cmd, inputs
  end,
  post_5_2_run = run_command,
  pre_5_2_run = run_command,
  extra_cmd_results = { "__stderr" },
}
sh_settings.shell = "vim"
