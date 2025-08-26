-- lua/birdee/plugins/ui.lua
local MP = ...

return {
  -- Noice.nvim - UI replacement for messages, cmdline and popover
  {
    "noice.nvim",
    for_cat = "other",
    on_require = { "noice" },
    after = function()
      require("noice").setup({
        -- LSP configuration
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        
        -- Message routing and filtering
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
          {
            filter = {
              event = "notify",
              find = "No information available",
            },
            opts = { skip = true },
          },
        },
        
        -- Presets for easier configuration
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
    
    -- Key mappings
    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
      {
        "<leader>snl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice Last Message",
      },
      {
        "<leader>snh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice History",
      },
      {
        "<leader>sna",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice All",
      },
      {
        "<leader>snd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All",
      },
    },
  },
  
  -- Edgy.nvim - Window management
  {
    "edgy.nvim",
    for_cat = "other",
    on_require = { "edgy" },
    after = function()
      -- Set options like original
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
      vim.opt.mouse = "a"
      vim.opt.mousemoveevent = true
      
      require("edgy").setup({
        -- Configuration will be truncated for brevity
        left = {
          title = "Explorer & Files",
          size = 35,
        },
        right = {
          title = "AI & Tools",
        },
        bottom = {
          title = "Terminal & Scratch",
          size = 20,
        },
        animate = {
          enabled = true,
          fps = 100,
          cps = 120,
        },
        close_when_all_hidden = true,
        fix_win_height = vim.fn.has("nvim-0.10.0") == 1,
      })
    end,
    event = "DeferredUIEnter",
    keys = {
      { "<leader>ue", function() require("edgy").toggle() end, desc = "🧩 Toggle Edgy" },
      { "<leader>ul", function() require("edgy").toggle("left") end, desc = "Toggle Explorer" },
      { "<leader>ur", function() require("edgy").toggle("right") end, desc = "Toggle Info Panel" },
      { "<leader>ub", function() require("edgy").toggle("bottom") end, desc = "Toggle Terminal" },
    },
  },
  
  -- Smart-splits.nvim - Smart window navigation
  {
    "smart-splits.nvim",
    for_cat = "other",
    on_require = { "smart-splits" },
    after = function()
      require('smart-splits').setup({
        tmux_integration = true,
        at_edge = 'wrap',
        default_amount = 3,
      })
    end,
    keys = {
      { "<C-h>", function() require('smart-splits').move_cursor_left() end, desc = "← Move Left", mode = "n" },
      { "<C-j>", function() require('smart-splits').move_cursor_down() end, desc = "↓ Move Down", mode = "n" },
      { "<C-k>", function() require('smart-splits').move_cursor_up() end, desc = "↑ Move Up", mode = "n" },
      { "<C-l>", function() require('smart-splits').move_cursor_right() end, desc = "→ Move Right", mode = "n" },
    },
  },
  
  -- Persistence.nvim - Session management
  {
    "persistence.nvim",
    for_cat = "other",
    on_require = { "persistence" },
    after = function()
      require('persistence').setup({
        dir = vim.fn.stdpath("data") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
      })
    end,
    event = "VimEnter",
    keys = {
      { "<leader>qq", function() require("persistence").save(); vim.cmd("qa") end, desc = "💾 Save Session & Quit" },
      { "<leader>qs", function() require("persistence").load() end, desc = "📂 Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "🔄 Restore Last Session" },
    },
  }
}