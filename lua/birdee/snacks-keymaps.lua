-- Custom keymaps for snacks picker navigation
-- Provides vim window navigation from snacks picker to adjacent buffers

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list", 
  group = vim.api.nvim_create_augroup("SnacksSmartNavigation", { clear = true }),
  callback = function(event)
    -- Override <C-l> navigation in picker list
    vim.keymap.set('n', '<C-l>', function()
      local current_win = vim.fn.winnr()
      local total_wins = vim.fn.winnr('$')
      
      -- Navigate to next window (right or wrap around)
      if current_win < total_wins then
        vim.cmd('wincmd l')  -- Move right
      else
        vim.cmd('wincmd w')  -- Next window (wrap around)
      end
      
    end, { buffer = event.buf, desc = "Navigate right from picker" })
  end,
})