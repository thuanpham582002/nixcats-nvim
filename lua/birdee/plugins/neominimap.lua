-- lua/birdee/plugins/neominimap.lua
local MP = ...

return {
  -- Neominimap - Code structure minimap
  {
    "neominimap.nvim",
    for_cat = "other",
    event = "DeferredUIEnter",
    before = function()
      vim.g.neominimap = {
        auto_enable = true,
        layout = "float",
        exclude_filetypes = {
          "help",
          "bigfile",
          "neo-tree",
          "NvimTree",
          "snacks_explorer",
          "noice",
          "edgy",
          "qf",
          "Trouble",
          "terminal",
          "undotree",
          "lazy",
          "claudecode",
        },
        exclude_buftypes = {
          "nofile",
          "nowrite",
          "quickfix",
          "terminal",
          "prompt",
        },
      }
    end,
    after = function()
      -- Key mappings for minimap controls
      local map = vim.keymap.set

      -- Global minimap controls
      map("n", "<leader>nm", "<cmd>Neominimap Toggle<cr>", { desc = "Toggle minimap" })
      map("n", "<leader>no", "<cmd>Neominimap Enable<cr>", { desc = "Enable minimap" })
      map("n", "<leader>nc", "<cmd>Neominimap Disable<cr>", { desc = "Disable minimap" })
      map("n", "<leader>nr", "<cmd>Neominimap Refresh<cr>", { desc = "Refresh minimap" })

      -- Focus controls
      map("n", "<leader>nf", "<cmd>Neominimap Focus<cr>", { desc = "Focus minimap" })
      map("n", "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", { desc = "Toggle minimap focus" })
      map("n", "<leader>nu", "<cmd>Neominimap Unfocus<cr>", { desc = "Unfocus minimap" })
    end,
  },
}
