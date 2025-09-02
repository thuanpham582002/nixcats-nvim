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
  
  -- Smart-splits.nvim - Smart window navigation with tmux integration
  {
    "smart-splits.nvim",
    for_cat = "other",
    -- Force load immediately for tmux integration (no lazy loading)
    after = function()
      vim.notify("🚀 Loading smart-splits plugin...", vim.log.levels.INFO)
      
      require('smart-splits').setup({
        -- Enable tmux integration for seamless navigation (new API)
        multiplexer_integration = 'tmux',
        
        -- Behavior when hitting edge of screen (wrap for tmux integration)
        at_edge = 'wrap', -- wrap | split | stop
        
        -- Resize amount for continuous resizing
        default_amount = 3,
        
        -- Resize mode configuration
        resize_mode = {
          -- Resize mode keymaps (hjkl for continuous resize)
          keys = { 'h', 'j', 'k', 'l' },
          
          -- Silent mode (no notifications)
          silent = false,
          
          -- Hooks for resize mode
          hooks = {
            on_enter = function()
              vim.notify("🔧 Resize Mode: hjkl to resize, <Esc> to exit", vim.log.levels.INFO)
            end,
            on_leave = function()
              vim.notify("✅ Resize Mode: OFF", vim.log.levels.INFO)
            end,
          },
        },
        
        -- Ignored buffer types (remove 'nofile' for Snacks explorer)
        ignored_buftypes = {
          'quickfix',
          'prompt',
        },
        
        -- Ignored file types (removed snacks for tmux navigation)
        ignored_filetypes = {
          'NvimTree',
          'neo-tree', 
          'oil',
        },
        
        -- Don't wrap when cursor is at edge
        move_cursor_same_row = false,
        
        -- Cursor follows focus
        cursor_follows_swapped_bufs = false,
        
        -- Floating window behavior
        float_win_behavior = 'previous',
        
        -- Log level for debugging
        log_level = 'info',
        
        -- Disable multiplexer nav when zoomed
        disable_multiplexer_nav_when_zoomed = false,
      })
      
      -- Check config safely
      local ok, config = pcall(function() return require('smart-splits').config end)
      if ok and config then
        vim.notify("✅ Smart-splits setup complete! Multiplexer integration: " .. tostring(config.multiplexer_integration), vim.log.levels.INFO)
      else
        vim.notify("✅ Smart-splits setup complete!", vim.log.levels.INFO)
      end
    end,
    
    keys = {
      -- Basic navigation removed - handled by snacks config to avoid conflicts
      -- { "<C-h>", "<C-j>", "<C-k>", "<C-l>" } moved to snacks.lua for unified management
      
      -- Resize Mode (Enter/Exit)
      {
        "<C-w>r",
        function() require('smart-splits').start_resize_mode() end,
        desc = "🔧 Toggle Resize Mode",
        mode = "n"
      },
      
      -- Resize windows with arrow keys
      {
        "<C-Left>",
        function() require('smart-splits').resize_left() end,
        desc = "← Resize Left",
        mode = "n"
      },
      {
        "<C-Down>",
        function() require('smart-splits').resize_down() end,
        desc = "↓ Resize Down", 
        mode = "n"
      },
      {
        "<C-Up>",
        function() require('smart-splits').resize_up() end,
        desc = "↑ Resize Up",
        mode = "n"
      },
      {
        "<C-Right>",
        function() require('smart-splits').resize_right() end,
        desc = "→ Resize Right",
        mode = "n"
      },
      
      -- Resize windows with hjkl (alternative to arrow keys)
      {
        "<C-S-h>", -- Ctrl+Shift+h
        function() require('smart-splits').resize_left() end,
        desc = "← Resize Left (hjkl)",
        mode = "n"
      },
      {
        "<C-S-j>", -- Ctrl+Shift+j
        function() require('smart-splits').resize_down() end,
        desc = "↓ Resize Down (hjkl)", 
        mode = "n"
      },
      {
        "<C-S-k>", -- Ctrl+Shift+k
        function() require('smart-splits').resize_up() end,
        desc = "↑ Resize Up (hjkl)",
        mode = "n"
      },
      {
        "<C-S-l>", -- Ctrl+Shift+l
        function() require('smart-splits').resize_right() end,
        desc = "→ Resize Right (hjkl)",
        mode = "n"
      },
      
      -- Vim-style navigation with Alt (Meta) key
      {
        "<M-h>", -- Alt+h
        function() require('smart-splits').move_cursor_left() end,
        desc = "← Move Left (Alt)",
        mode = "n"
      },
      {
        "<M-j>", -- Alt+j
        function() require('smart-splits').move_cursor_down() end,
        desc = "↓ Move Down (Alt)",
        mode = "n"
      },
      {
        "<M-k>", -- Alt+k
        function() require('smart-splits').move_cursor_up() end,
        desc = "↑ Move Up (Alt)",
        mode = "n"
      },
      {
        "<M-l>", -- Alt+l
        function() require('smart-splits').move_cursor_right() end,
        desc = "→ Move Right (Alt)",
        mode = "n"
      },
      
      -- Alternative navigation with leader
      {
        "<leader>wh",
        function() require('smart-splits').move_cursor_left() end,
        desc = "← Window Left",
        mode = "n"
      },
      {
        "<leader>wj",
        function() require('smart-splits').move_cursor_down() end,
        desc = "↓ Window Down",
        mode = "n"
      },
      {
        "<leader>wk",
        function() require('smart-splits').move_cursor_up() end,
        desc = "↑ Window Up",
        mode = "n"
      },
      {
        "<leader>wl",
        function() require('smart-splits').move_cursor_right() end,
        desc = "→ Window Right",
        mode = "n"
      },
      
      -- Swap buffers between splits
      {
        "<leader><leader>h",
        function() require('smart-splits').swap_buf_left() end,
        desc = "⤆ Swap Buffer Left"
      },
      {
        "<leader><leader>j",
        function() require('smart-splits').swap_buf_down() end,
        desc = "⤓ Swap Buffer Down"
      },
      {
        "<leader><leader>k",
        function() require('smart-splits').swap_buf_up() end,
        desc = "⤒ Swap Buffer Up"
      },
      {
        "<leader><leader>l",
        function() require('smart-splits').swap_buf_right() end,
        desc = "⤇ Swap Buffer Right"
      },
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