local repr = getmetatable(require('sh')).repr
local function run_command(_, cmd, tmp)
  local result = vim.system({ "bash", "-c", cmd }, { text = true }):wait()
  pcall(os.remove, tmp)
  return {
    __input = result.stdout,
    __stderr = result.stderr,
    __exitcode = result.code,
    __signal = result.signal,
  }
end
repr.posix.post_5_2_run = run_command
repr.posix.pre_5_2_run = run_command
repr.posix.extra_cmd_results = { "__stderr" }
