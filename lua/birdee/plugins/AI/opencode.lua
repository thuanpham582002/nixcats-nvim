local MP = ...

return {
  {
    'opencode-nvim',
    for_cat = { cat = 'AI.opencode', default = false },
    cmd = { 'Opencode' },
    on_require = { 'opencode' },
    keys = {
      { '<leader>Ot', function() require('opencode.api').toggle() end, desc = 'Toggle opencode' },
      { '<leader>Oq', function() require('opencode.api').close() end, desc = 'Close opencode' },
      { '<leader>OT', function() require('opencode.api').toggle_focus() end, desc = 'Toggle focus opencode / last window' },
      { '<leader>Oi', function() require('opencode.api').open_input() end, desc = 'Open opencode input' },
      { '<leader>OI', function() require('opencode.api').open_input_new_session() end, desc = 'Open opencode input (new session)' },
      { '<leader>Oo', function() require('opencode.api').open_output() end, desc = 'Open opencode output' },
      { '<leader>Oz', function() require('opencode.api').toggle_zoom() end, desc = 'Toggle zoom opencode' },
      { '<leader>Ox', function() require('opencode.api').swap_position() end, desc = 'Swap opencode pane left/right' },
      { '<leader>Os', function() require('opencode.api').select_session() end, desc = 'Select opencode session' },
      { '<leader>OR', function() require('opencode.api').rename_session() end, desc = 'Rename opencode session' },
      { '<leader>Ol', function() require('opencode.api').timeline() end, desc = 'Opencode timeline' },
      { '<leader>Op', function() require('opencode.api').configure_provider() end, desc = 'Configure opencode provider' },
      { '<leader>OV', function() require('opencode.api').configure_variant() end, desc = 'Configure opencode variant' },
      { '<leader>Oy', function() require('opencode.api').add_visual_selection() end, desc = 'Add visual selection to context', mode = 'v' },
      { '<leader>OY', function() require('opencode.api').add_visual_selection_inline() end, desc = 'Add visual selection inline', mode = 'v' },
      { '<leader>Ov', function() require('opencode.api').paste_image() end, desc = 'Paste image into opencode' },
      { '<leader>Od', function() require('opencode.api').diff_open() end, desc = 'Open diff view' },
      { '<leader>O]', function() require('opencode.api').diff_next() end, desc = 'Next diff' },
      { '<leader>O[', function() require('opencode.api').diff_prev() end, desc = 'Previous diff' },
      { '<leader>Oc', function() require('opencode.api').diff_close() end, desc = 'Close diff view' },
      { '<leader>Ora', function() require('opencode.api').diff_revert_all_last_prompt() end, desc = 'Revert all since last prompt' },
      { '<leader>Ort', function() require('opencode.api').diff_revert_this_last_prompt() end, desc = 'Revert this file since last prompt' },
      { '<leader>OrA', function() require('opencode.api').diff_revert_all() end, desc = 'Revert all since session' },
      { '<leader>OrT', function() require('opencode.api').diff_revert_this() end, desc = 'Revert this file since session' },
      { '<leader>Orr', function() require('opencode.api').diff_restore_snapshot_file() end, desc = 'Restore snapshot file' },
      { '<leader>OrR', function() require('opencode.api').diff_restore_snapshot_all() end, desc = 'Restore snapshot all' },
      { '<leader>Ott', function() require('opencode.api').toggle_tool_output() end, desc = 'Toggle tool output' },
      { '<leader>Otr', function() require('opencode.api').toggle_reasoning_output() end, desc = 'Toggle reasoning output' },
      { '<leader>O/', function() require('opencode.api').quick_chat() end, desc = 'Quick chat', mode = { 'n', 'v' } },
    },
    after = function()
      require('opencode').setup({
        default_global_keymaps = false,
        ui = {
          position = 'right',
          window_width = 0.35,
        },
      })
    end,
  },
}
