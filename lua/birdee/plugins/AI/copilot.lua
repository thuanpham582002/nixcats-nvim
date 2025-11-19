local MP = ...

return {
  -- GitHub Copilot.lua - AI pair programmer (Lua version)
  {
    "copilot.lua",
    for_cat = "AI.copilot",
    event = "InsertEnter",
    after = function()
      require('copilot').setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,       -- Enable auto-trigger for suggestions
          hide_during_completion = false, -- Don't hide when blink.cmp is open
          debounce = 75,
          keymap = {
            accept = "<M-l>",        -- Ergonomic accept key
            accept_word = "<M-j>",   -- Accept single word
            accept_line = "<M-i>",   -- Accept full line with Alt+i
            next = "<M-]>",          -- Next suggestion
            prev = "<M-[>",          -- Previous suggestion
            dismiss = "<M-k>",       -- Dismiss suggestion
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js v24.10.0 available
      })

      -- Don't hide copilot suggestions when blink.cmp menu is open
      -- Remove auto hiding to allow both systems to work together

      -- Leader commands for copilot control
      vim.keymap.set('n', '<leader>cc', function()
        require('copilot.suggestion').toggle_auto_trigger()
      end, { desc = "🤖 Toggle Copilot" })

      vim.keymap.set('n', '<leader>ce', function()
        vim.cmd('Copilot enable')
      end, { desc = "🤖 Enable Copilot" })

      vim.keymap.set('n', '<leader>cd', function()
        vim.cmd('Copilot disable')
      end, { desc = "🤖 Disable Copilot" })

      vim.keymap.set('n', '<leader>cs', '<cmd>Copilot status<cr>',
        { desc = "🤖 Copilot Status" })

      vim.keymap.set('n', '<leader>cp', function()
        require('copilot.panel').toggle()
      end, { desc = "🤖 Open Copilot Panel" })
    end,
    keys = {
      { "<leader>cc", desc = "🤖 Toggle Copilot" },
      { "<leader>ce", desc = "🤖 Enable Copilot" },
      { "<leader>cd", desc = "🤖 Disable Copilot" },
      { "<leader>cs", desc = "🤖 Copilot Status" },
      { "<leader>cp", desc = "🤖 Open Copilot Panel" },
      -- Insert mode keybindings
      { "<M-l>", desc = "🤖 Accept Copilot Suggestion", mode = "i" },
      { "<M-j>", desc = "🤖 Accept Copilot Word", mode = "i" },
      { "<M-k>", desc = "🤖 Dismiss Copilot Suggestion", mode = "i" },
      { "<M-]>", desc = "🤖 Next Copilot Suggestion", mode = "i" },
      { "<M-[>", desc = "🤖 Previous Copilot Suggestion", mode = "i" },
    },
  },
}