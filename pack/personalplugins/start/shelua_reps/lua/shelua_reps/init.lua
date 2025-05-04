---@type SheluaOpts
local sh_settings = getmetatable(require('sh'))

local function add_args(opts, cmd, args)
  if opts.proper_pipes then
      return cmd .. " " .. table.concat(args, " ")
  else
    return setmetatable({ cmd = cmd, args = args }, {
      __tostring = function(self)
        return vim.inspect(self)
      end,
    })
  end
end

local function single_stdin(opts, cmd, input)
  cmd.input = input
  return cmd
end

local function run_command(_, cmd, msg)
  local result
  if cmd.cmd then
    result = vim.system({ cmd.cmd, unpack(cmd.args or {}) }, { stdin = cmd.input, text = true }):wait()
  else
    result = vim.system({ "bash", "-c", cmd }, { text = true }):wait()
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
  add_args = add_args,
  single_stdin = single_stdin,
  concat_cmd = sh_settings.repr.posix.concat_cmd,
  post_5_2_run = run_command,
  pre_5_2_run = run_command,
  extra_cmd_results = { "__stderr" },
}
sh_settings.shell = "vim"
