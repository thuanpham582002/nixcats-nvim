local MP = ...

return {
  -- Claude Code integration
  {
    'claudecode.nvim',
    for_cat = { cat = 'AI.claudecode', default = false },
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code terminal' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = { 'n', 'v' }, desc = 'Send to Claude Code' },
    },
    after = function()
      -- Configure the terminal settings for Claude Code
      vim.defer_fn(function()
        if pcall(require, 'claudecode') then
          require('claudecode').setup({
            -- Customize the terminal if needed
            terminal = {
              snacks_win_opts = {
                bo = {
                  filetype = "claudecode", -- Custom filetype instead of snacks_terminal
                },
              },
            },
          })
        else
          vim.notify("Claude Code plugin loaded but setup failed", vim.log.levels.WARN)
        end
      end, 100)
    end,
  },
}