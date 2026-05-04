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
        winopt = function(opt, winid)
          vim.api.nvim_set_option_value("number", false, { win = winid })
          vim.api.nvim_set_option_value("relativenumber", false, { win = winid })
          vim.api.nvim_set_option_value("signcolumn", "no", { win = winid })
          vim.api.nvim_set_option_value("statuscolumn", "", { win = winid })
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
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
          if vim.bo.filetype == "neominimap" then
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
            vim.opt_local.statuscolumn = ""
          end
        end,
      })

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
