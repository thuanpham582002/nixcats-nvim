local MP = ...

return {
  -- GitHub Copilot.vim - AI pair programmer
  {
    "copilot.vim",
    for_cat = "AI.copilot",
    event = "InsertEnter",
    after = function()
      -- Copilot configuration
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""

      -- Setup keybindings for copilot (using Alt+ keys to avoid navigation conflicts)
      vim.keymap.set('i', '<M-j>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "🤖 Copilot Accept Suggestion"
      })
      vim.keymap.set('i', '<M-l>', 'copilot#AcceptWord("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "🤖 Copilot Accept Word"
      })
      vim.keymap.set('i', '<M-k>', 'copilot#Dismiss("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "🤖 Copilot Dismiss Suggestion"
      })
      vim.keymap.set('i', '<M-n>', 'copilot#Next("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "🤖 Copilot Next Suggestion"
      })
      vim.keymap.set('i', '<M-p>', 'copilot#Previous("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "🤖 Copilot Previous Suggestion"
      })
    end,
    keys = {
      { "<leader>cc", "<cmd>Copilot toggle<cr>", desc = "🤖 Toggle Copilot" },
      { "<leader>ce", "<cmd>Copilot enable<cr>", desc = "🤖 Enable Copilot" },
      { "<leader>cd", "<cmd>Copilot disable<cr>", desc = "🤖 Disable Copilot" },
      { "<leader>cs", "<cmd>Copilot status<cr>", desc = "🤖 Copilot Status" },
      { "<leader>cp", "<cmd>Copilot panel<cr>", desc = "🤖 Open Copilot Panel" },
    },
  },
}