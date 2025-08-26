-- lua/birdee/plugins/lsp.lua
local MP = ...

return {
  -- Diffview.nvim - Git diff viewer
  {
    "diffview.nvim",
    for_cat = "general.core",
    on_require = { "diffview" },
    after = function()
      require('diffview').setup({
        -- Diff view configuration
        diff_binaries = false,
        enhanced_diff_hl = false,
        git_cmd = { "git" },
        use_icons = true,
        
        -- File panel configuration
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
            win_opts = {}
          },
        },
        
        -- File history panel
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
            win_opts = {}
          },
        },
        
        -- Commit log panel
        commit_log_panel = {
          win_config = {
            win_opts = {},
          }
        },
        
        -- Key mappings for diffview
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        
        -- Hooks
        hooks = {},
        
        -- Key mappings
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "<tab>", ":DiffviewToggleFiles<CR>", { desc = "Toggle file panel" } },
            { "n", "gf", ":DiffviewFocusFiles<CR>", { desc = "Focus file panel" } },
            { "n", "gh", "<Cmd>DiffviewFileHistory<CR>", { desc = "Open file history" } },
          },
          diff1 = {
            { "n", "g?", ":h diffview-maps-diff1<CR>", { desc = "Show help" } },
          },
          diff2 = {
            { "n", "g?", ":h diffview-maps-diff2<CR>", { desc = "Show help" } },
          },
          file_panel = {
            { "n", "j", "<Plug>(DiffviewNext)", { desc = "Next entry" } },
            { "n", "k", "<Plug>(DiffviewPrev)", { desc = "Previous entry" } },
            { "n", "<cr>", "<Plug>(DiffviewOpen)", { desc = "Open diff" } },
            { "n", "o", "<Plug>(DiffviewOpen)", { desc = "Open diff" } },
            { "n", "<2-LeftMouse>", "<Plug>(DiffviewOpen)", { desc = "Open diff" } },
            { "n", "-", "<Plug>(DiffviewToggleStage)", { desc = "Toggle stage" } },
            { "n", "S", "<Plug>(DiffviewStageAll)", { desc = "Stage all" } },
            { "n", "U", "<Plug>(DiffviewUnstageAll)", { desc = "Unstage all" } },
            { "n", "X", "<Plug>(DiffviewRefresh)", { desc = "Refresh" } },
            { "n", "R", "<Plug>(DiffviewRefresh)", { desc = "Refresh" } },
            { "n", "L", "<Plug>(DiffviewOpenCommitLog)", { desc = "Open commit log" } },
            { "n", "zR", "<Plug>(DiffviewExpandAll)", { desc = "Expand all" } },
            { "n", "zM", "<Plug>(DiffviewCollapseAll)", { desc = "Collapse all" } },
            { "n", "<tab>", "<Plug>(DiffviewToggleFiles)", { desc = "Toggle files" } },
            { "n", "gf", "<Plug>(DiffviewFocusFiles)", { desc = "Focus files" } },
            { "n", "g<C-x>", "<Plug>(DiffviewOpenInDiffTool)", { desc = "Open in diff tool" } },
            { "n", "g?", ":h diffview-maps-file-panel<CR>", { desc = "Show help" } },
          },
          file_history_panel = {
            { "n", "g!", "<Cmd>DiffviewOptionsToggle<CR>", { desc = "Toggle options" } },
            { "n", "<C-A-d>", "<Plug>(DiffviewOpenInDiffTool)", { desc = "Open in diff tool" } },
            { "n", "g?", ":h diffview-maps-file-history-panel<CR>", { desc = "Show help" } },
          },
          option_panel = {
            { "n", "<tab>", "<Plug>(DiffviewToggleOption)", { desc = "Toggle option" } },
            { "n", "q", "<Plug>(DiffviewClose)", { desc = "Close diffview" } },
            { "n", "g?", ":h diffview-maps-option-panel<CR>", { desc = "Show help" } },
          },
          help_panel = {
            { "n", "q", "<Plug>(DiffviewClose)", { desc = "Close diffview" } },
          },
        },
      })
    end,
    
    -- Commands for git operations
    cmd = {
      "DiffviewOpen",
      "DiffviewClose", 
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory"
    },
    
    -- Key mappings
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<cr>",
        desc = "🔄 Open Diffview"
      },
      {
        "<leader>gc",
        "<cmd>DiffviewClose<cr>",
        desc = "❌ Close Diffview"
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "📜 File History"
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "📜 Current File History"
      },
    },
  },

  -- Lspsaga.nvim - Enhanced LSP UI
  {
    "lspsaga.nvim",
    for_cat = "general.core",
    on_require = { "lspsaga" },
    after = function()
      require('lspsaga').setup({
        -- UI configuration
        ui = {
          theme = "round",
          border = "rounded",
          winblend = 0,
          expand = "",
          collapse = "",
          preview = " ",
          code_action = "💡",
          diagnostic = "🐛",
          incoming = " ",
          outgoing = " ",
          colors = {
            normal_bg = "#002b36",
            title_bg = "#afd700",
            red = "#e95678",
            magenta = "#b33076",
            orange = "#FF8700",
            yellow = "#f7bb3b",
            green = "#afd700",
            cyan = "#36d0e0",
            blue = "#61afef",
            purple = "#CBA6F7",
            white = "#d1d4d5",
            black = "#1c1c19",
          },
        },
        
        -- Scroll preview configuration
        scroll_preview = {
          scroll_down = "<C-f>",
          scroll_up = "<C-b>",
        },
        
        -- Request timeout
        request_timeout = 2000,
        
        -- Finder configuration
        finder = {
          edit = { "o", "<CR>" },
          vsplit = "s",
          split = "i",
          tabe = "t",
          quit = { "q", "<ESC>" },
        },
        
        -- Definition configuration
        definition = {
          edit = "<C-c>o",
          vsplit = "<C-c>v",
          split = "<C-c>i",
          tabe = "<C-c>t",
          quit = "q",
        },
        
        -- Code action configuration
        code_action = {
          num_shortcut = true,
          keys = {
            quit = "q",
            exec = "<CR>",
          },
        },
        
        -- Lightbulb configuration
        lightbulb = {
          enable = true,
          enable_in_insert = true,
          sign = true,
          sign_priority = 40,
          virtual_text = true,
        },
        
        -- Diagnostic configuration
        diagnostic = {
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          keys = {
            exec_action = "o",
            quit = "q",
          },
        },
        
        -- Rename configuration
        rename = {
          quit = "<C-c>",
          exec = "<CR>",
          mark = "x",
          confirm = "<CR>",
          in_select = true,
        },
        
        -- Outline configuration
        outline = {
          win_position = "right",
          win_with = "",
          win_width = 30,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            jump = "o",
            expand_collapse = "u",
            quit = "q",
          },
        },
        
        -- Callhierarchy configuration
        callhierarchy = {
          show_detail = false,
          keys = {
            edit = "e",
            vsplit = "s",
            split = "i",
            tabe = "t",
            jump = "o",
            quit = "q",
            expand_collapse = "u",
          },
        },
        
        -- Symbol in winbar
        symbol_in_winbar = {
          enable = true,
          separator = "  ",
          hide_keyword = true,
          show_file = true,
          folder_level = 2,
          respect_root = false,
          color_mode = true,
        },
        
        -- Beacon configuration
        beacon = {
          enable = true,
          frequency = 7,
        },
      })
    end,
    
    -- Event-based loading
    event = "LspAttach",
    
    -- Key mappings
    keys = {
      -- LSP finder
      {
        "gf",
        "<cmd>Lspsaga lsp_finder<CR>",
        desc = "🔍 LSP Finder"
      },
      
      -- Code action
      {
        "<leader>ca",
        "<cmd>Lspsaga code_action<CR>",
        desc = "💡 Code Action"
      },
      
      -- Rename
      {
        "gr",
        "<cmd>Lspsaga rename<CR>",
        desc = "✏️  Rename"
      },
      {
        "gr",
        "<cmd>Lspsaga rename ++project<CR>",
        desc = "✏️  Rename in Project"
      },
      
      -- Peek definition
      {
        "gd",
        "<cmd>Lspsaga peek_definition<CR>",
        desc = "👁️  Peek Definition"
      },
      {
        "gD",
        "<cmd>Lspsaga goto_definition<CR>",
        desc = "➡️  Go to Definition"
      },
      
      -- Peek type definition
      {
        "gt",
        "<cmd>Lspsaga peek_type_definition<CR>",
        desc = "👁️  Peek Type Definition"
      },
      {
        "gT",
        "<cmd>Lspsaga goto_type_definition<CR>",
        desc = "➡️  Go to Type Definition"
      },
      
      -- Show line diagnostics
      {
        "<leader>sl",
        "<cmd>Lspsaga show_line_diagnostics<CR>",
        desc = "🐛 Show Line Diagnostics"
      },
      
      -- Show buffer diagnostics
      {
        "<leader>sb",
        "<cmd>Lspsaga show_buf_diagnostics<CR>",
        desc = "🐛 Show Buffer Diagnostics"
      },
      
      -- Show workspace diagnostics
      {
        "<leader>sw",
        "<cmd>Lspsaga show_workspace_diagnostics<CR>",
        desc = "🐛 Show Workspace Diagnostics"
      },
      
      -- Show cursor diagnostics
      {
        "<leader>sc",
        "<cmd>Lspsaga show_cursor_diagnostics<CR>",
        desc = "🐛 Show Cursor Diagnostics"
      },
      
      -- Diagnostic navigate
      {
        "[e",
        "<cmd>Lspsaga diagnostic_jump_prev<CR>",
        desc = "⬅️  Previous Diagnostic"
      },
      {
        "]e",
        "<cmd>Lspsaga diagnostic_jump_next<CR>",
        desc = "➡️  Next Diagnostic"
      },
      
      -- Diagnostic navigate with filter
      {
        "[E",
        function()
          require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "⬅️  Previous Error"
      },
      {
        "]E",
        function()
          require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "➡️  Next Error"
      },
      
      -- Toggle outline
      {
        "<leader>o",
        "<cmd>Lspsaga outline<CR>",
        desc = "📋 Toggle Outline"
      },
      
      -- Hover doc
      {
        "K",
        "<cmd>Lspsaga hover_doc<CR>",
        desc = "📖 Hover Documentation"
      },
      
      -- Hover doc with keep
      {
        "<leader>K",
        "<cmd>Lspsaga hover_doc ++keep<CR>",
        desc = "📌 Keep Hover Doc"
      },
      
      -- Call hierarchy
      {
        "<Leader>ci",
        "<cmd>Lspsaga incoming_calls<CR>",
        desc = "📞 Incoming Calls"
      },
      {
        "<Leader>co",
        "<cmd>Lspsaga outgoing_calls<CR>",
        desc = "📞 Outgoing Calls"
      },
      
      -- Float terminal
      {
        "<A-d>",
        "<cmd>Lspsaga term_toggle<CR>",
        mode = { "n", "t" },
        desc = "Toggle Terminal",
      },
    },
  },
}