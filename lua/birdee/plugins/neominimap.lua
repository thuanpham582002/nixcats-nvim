local MP = ...

return {
  {
    'neominimap-nvim',
    for_cat = "other",
    event = "DeferredUIEnter",
    cmd = { "Neominimap" },
    before = function()
      vim.g.neominimap = {
        auto_enable = true,
        layout = "float",
        winopt = function(opt, _)
          opt.number = false
          opt.relativenumber = false
          opt.signcolumn = "no"
        end,
        exclude_filetypes = {
          "help", "bigfile", "neo-tree", "NvimTree",
          "snacks_explorer", "noice", "edgy", "qf",
          "Trouble", "terminal", "undotree", "lazy", "claudecode",
        },
        exclude_buftypes = {
          "nofile", "nowrite", "quickfix", "terminal", "prompt",
        },
      }
    end,
    after = function()
      local map = vim.keymap.set
      map("n", "<leader>nm", "<cmd>Neominimap Toggle<cr>", { desc = "Toggle minimap" })
      map("n", "<leader>no", "<cmd>Neominimap Enable<cr>", { desc = "Enable minimap" })
      map("n", "<leader>nc", "<cmd>Neominimap Disable<cr>", { desc = "Disable minimap" })
      map("n", "<leader>nr", "<cmd>Neominimap Refresh<cr>", { desc = "Refresh minimap" })
      map("n", "<leader>nf", "<cmd>Neominimap Focus<cr>", { desc = "Focus minimap" })
      map("n", "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", { desc = "Toggle minimap focus" })
      map("n", "<leader>nu", "<cmd>Neominimap Unfocus<cr>", { desc = "Unfocus minimap" })
    end,
  },
}
