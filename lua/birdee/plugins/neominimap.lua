local MP = ...

return {
  {
    'neominimap-nvim',
    for_cat = "other",
    event = "DeferredUIEnter",
    cmd = { "Neominimap" },
    before = function()
      -- Đẩy text khỏi mép phải, tạo khoảng trống cho minimap float
      vim.opt.sidescrolloff = 24
      vim.opt.wrap = false
      vim.g.neominimap = {
        auto_enable = true,
        layout = "float",
        x_multiplier = 8,
        float = {
          minimap_width = 16,
          max_minimap_height = nil,
          margin = { right = 0, top = 0, bottom = 0 },
          z_index = 1,
          window_border = "none",
          persist = true,
        },
        winopt = function(opt, winid)
          opt.winhighlight = table.concat({
            "Normal:NeominimapBackground",
            "FloatBorder:NeominimapBorder",
            "CursorLine:NeominimapCursorLine",
            "CursorLineNr:NeominimapCursorLineNr",
            "CursorLineSign:NeominimapCursorLineSign",
            "CursorLineFold:NeominimapCursorLineFold",
          }, ",")
          opt.wrap = false
          opt.foldcolumn = "0"
          opt.signcolumn = "no"
          opt.statuscolumn = ""
          opt.number = false
          opt.relativenumber = false
          opt.scrolloff = 99999
          opt.sidescrolloff = 0
          opt.winblend = 0
          opt.cursorline = true
          opt.spell = false
          opt.list = false
          opt.fillchars = "eob: "
          opt.winfixwidth = true
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
      vim.api.nvim_set_hl(0, "NeominimapCursorLine", {
        bg = "#4a5263",
      })

      local state_file = vim.fn.stdpath("data") .. "/neominimap_state"

      local file = io.open(state_file, "r")
      if file then
        local state = file:read("*l")
        file:close()
        if state == "disabled" then
          vim.defer_fn(function()
            pcall(vim.cmd, "Neominimap Disable")
          end, 100)
        end
      end

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          local ok, api = pcall(require, "neominimap.api")
          if ok and not api.enabled() then
            local f = io.open(state_file, "w")
            if f then
              f:write("disabled")
              f:close()
            end
          else
            pcall(os.remove, state_file)
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
