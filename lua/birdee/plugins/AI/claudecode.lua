local MP = ...

return {
  -- Claude Code integration
  {
    'claudecode-nvim',
    for_cat = { cat = 'AI.claudecode', default = false },
    cmd = { 'ClaudeCode', 'ClaudeCodeSend', 'ClaudeCodeFocus', 'ClaudeCodeOpen', 'ClaudeCodeClose' },
    on_require = { 'claudecode' },
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code terminal' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = { 'n', 'v' }, desc = 'Send to Claude Code' },
    },
    after = function()
      require('claudecode').setup({
        terminal = {
          snacks_win_opts = {
            bo = {
              filetype = "claudecode",
            },
          },
        },
      })
    end,
  },
}