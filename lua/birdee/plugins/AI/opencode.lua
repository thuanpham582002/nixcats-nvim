local MP = ...

return {
  {
    'opencode-nvim',
    for_cat = { cat = 'AI.opencode', default = false },
    cmd = { 'Opencode' },
    on_require = { 'opencode' },
    keys = {
      { '<leader>Ot', function() require('opencode').toggle() end, mode = { 'n', 't' }, desc = 'Toggle opencode' },
      { '<leader>Oa', function() require('opencode').ask() end, mode = { 'n', 'v' }, desc = 'Ask opencode' },
      { '<leader>OA', function() require('opencode').ask('@this: ', { submit = true }) end, mode = { 'n', 'v' }, desc = 'Ask about this' },
      { '<leader>Os', function() require('opencode').select() end, desc = 'Select opencode action' },
      { '<leader>On', function() require('opencode').command('session.new') end, desc = 'New session' },
      { '<leader>Or', function() require('opencode').prompt('review') end, desc = 'Review code' },
      { '<leader>Oe', function() require('opencode').prompt('explain') end, desc = 'Explain code' },
      { '<leader>Of', function() require('opencode').prompt('fix') end, desc = 'Fix diagnostics' },
      { '<leader>Od', function() require('opencode').prompt('document') end, desc = 'Document code' },
      { '<leader>Ox', function() require('opencode').prompt('test') end, desc = 'Add tests' },
      { '<leader>Op', function() require('opencode').prompt('optimize') end, desc = 'Optimize code' },
    },
    after = function()
      vim.g.opencode_opts = {}

      -- Blank statuscolumn in opencode ask and terminal windows
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "opencode_ask",
        callback = function()
          vim.opt_local.statuscolumn = ""
        end,
      })
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.schedule(function()
            vim.opt_local.statuscolumn = ""
          end)
        end,
      })
    end,
  },
}
