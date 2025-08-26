-- lua/birdee/plugins/editing.lua
local MP = ...

return {
  -- TreeSJ - Split/join code structures
  {
    "treesj",
    for_cat = "general.core",
    cmd = { "TSJToggle" },
    keys = { { "<leader>Ft", ":TSJToggle<CR>", mode = { "n" }, desc = "treesj split/join" }, },
    after = function(_)
      local tsj = require('treesj')

      -- local langs = {--[[ configuration for languages ]]}

      tsj.setup({
        ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
        use_default_keymaps = false,
        ---@type boolean Node with syntax error will not be formatted
        check_syntax_error = true,
        ---If line after join will be longer than max value,
        ---@type number If line after join will be longer than max value, node will not be formatted
        max_join_length = 120,
        ---Cursor behavior:
        ---hold - cursor follows the node/place on which it was called
        ---start - cursor jumps to the first symbol of the node being formatted
        ---end - cursor jumps to the last symbol of the node being formatted
        ---@type 'hold'|'start'|'end'
        cursor_behavior = 'hold',
        ---@type boolean Notify about possible problems or not
        notify = true,
        ---@type boolean Use `dot` for repeat action
        dot_repeat = true,
        ---@type nil|function Callback for treesj error handler. func (err_text, level, ...other_text)
        on_error = nil,
        ---@type table Presets for languages
        -- langs = langs, -- See the default presets in lua/treesj/langs
      })
    end,
  },

  -- Dial.nvim - Enhanced increment/decrement
  {
    "dial.nvim",
    for_cat = "general.core",
    on_require = { "dial" },
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, desc = "Decrement" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, desc = "Decrement" },
      { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "v", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "v", desc = "Decrement" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "Decrement" },
    },
    after = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.integer.alias.decimal,   -- nonnegative decimal number (0, 1, 2, 3, ...)
          augend.integer.alias.hex,       -- nonnegative hex number  (0x01, 0x1a1f, etc.)
          augend.date.alias["%Y/%m/%d"],  -- date (2022/02/19, etc.)
        },
        typescript = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.constant.alias.bool,    -- boolean value (true <-> false)
          augend.constant.new{
            elements = {"let", "const"},
          },
        },
        visual = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
        },
      }
    end,
  },

  -- Undotree - Visualize undo history
  {
    "undotree",
    for_cat = "general.core",
    cmd = { "UndotreeToggle", "UndotreeFocus" },
    after = function()
      -- Configuration variables
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_DiffpanelHeight = 8
      vim.g.undotree_DiffAutoOpen = 1
    end,
    keys = {
      {
        "<leader>uu",
        "<cmd>UndotreeToggle<CR>",
        desc = "🌲 Toggle Undotree"
      },
      {
        "<leader>uf",
        "<cmd>UndotreeFocus<CR>",
        desc = "🎯 Focus Undotree"
      },
    },
  },

  -- nvim-surround - Surround selections and motions
  {
    "nvim-surround",
    for_cat = "general.core",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "DeferredUIEnter",
    after = function()
      require('nvim-surround').setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },
        aliases = {
          ["a"] = ">",
          ["b"] = ")",
          ["B"] = "}",
          ["r"] = "]",
          ["q"] = { '"', "'", "`" },
          ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
        highlight = {
          duration = 0,
        },
        move_cursor = "begin",
        indent_lines = function(start, stop)
          local b = vim.bo
          -- Only re-indent the selection if a formatter is set up
          if start < stop and (b.equalprg ~= "" or b.indentexpr ~= "" or b.cindent or b.smartindent or b.lisp) then
            vim.cmd(string.format("silent normal! %dG=%dG", start, stop))
          end
        end,
      })
    end,
  },

  -- vim-sleuth - Automatic indentation detection
  {
    "vim-sleuth",
    for_cat = "general.core",
    event = { "BufReadPre", "BufNewFile" },
    -- No configuration needed - works automatically
  },
}