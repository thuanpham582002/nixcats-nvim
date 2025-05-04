_G.sh = require('sh')
---@type SheluaOpts
local sh_settings = getmetatable(sh)

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
  escape = sh_settings.repr.posix.escape,
  arg_tbl = sh_settings.repr.posix.arg_tbl,
  concat_cmd = sh_settings.repr.posix.concat_cmd,
  add_args = function(opts, cmd, args)
    if opts.proper_pipes then
        return cmd .. " " .. table.concat(args, " ")
    else
      return setmetatable({ cmd, unpack(args) }, {
        __tostring = function(self)
          return vim.inspect(self)
        end,
      })
    end
  end,
  single_stdin = function (opts, cmd, input)
    return cmd, input
  end,
  post_5_2_run = run_command,
  pre_5_2_run = run_command,
  extra_cmd_results = { "__stderr" },
}
sh_settings.shell = "vim"
