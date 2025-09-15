-- lua/birdee/plugins/visual.lua
local MP = ...

return {
  -- Todo-comments.nvim - Highlight TODO, FIXME, etc. comments
  {
    "todo-comments.nvim",
    for_cat = "other",
    dependencies = { "nvim-lua/plenary.nvim" },
    after = function()
      require("todo-comments").setup({ signs = false })
    end,
    event = "BufReadPost",
    keys = {
      {
        "]t",
        function() require("todo-comments").jump_next() end,
        desc = "Next todo comment"
      },
      {
        "[t",
        function() require("todo-comments").jump_prev() end,
        desc = "Previous todo comment"
      },
    },
  },

  -- Visual-whitespace.nvim - Visualize whitespace characters
  {
    "visual-whitespace",
    for_cat = "other",
    on_require = { "visual-whitespace" },
    after = function()
      require('visual-whitespace').setup({
        highlight = { link = 'Visual' },
        space_char = '·',
        tab_char = '→',
        nl_char = '↲',
        cr_char = '←'
      })
    end,
    event = "BufReadPost",
  },

  -- Eyeliner.nvim - Move faster with unique f/F indicators
  {
    "eyeliner.nvim",
    for_cat = "other",
    keys = { "f", "F", "t", "T" },
    after = function()
      require('eyeliner').setup {
        highlight_on_key = true, -- show highlights only after keypress
        dim = false,             -- don't dim other characters
        max_length = 9999,       -- maximum line length to scan
        disabled_filetypes = {   -- don't activate in these filetypes
          'nerdtree',
          'TelescopePrompt',
          'TelescopeResults',
          'neo-tree',
          'snacks_explorer',
          'snacks_picker',
          'snacks_picker_list',
        },
        disabled_buftypes = {    -- don't activate in these buffer types
          'nofile',
          'terminal',
          'help',
          'quickfix',
          'prompt',
        },
        default_keymaps = true,  -- set default keymaps (f, F, t, T)
      }
    end,
  },

  -- Hlargs.nvim - Highlight function arguments
  {
    "hlargs",
    for_cat = "other",
    on_require = { "hlargs" },
    after = function()
      require('hlargs').setup({
        color = '#ef9062',
        excluded_argnames = {
          declarations = {},
          usages = {
            python = { 'self', 'cls' },
            lua = { 'self' }
          }
        },
        paint_arg_declarations = true,
        paint_arg_usages = true,
        paint_catch_blocks = {
          declarations = false,
          usages = false
        },
        extras = {
          named_parameters = false,
        },
        hl_priority = 10000,
        excluded_filetypes = {},
        disable = function(_, bufnr)
          if vim.b.semantic_tokens then
            return true
          end
          local clients = vim.lsp.get_clients { bufnr = bufnr }
          for _, c in pairs(clients) do
            local caps = c.server_capabilities
            if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
              vim.b.semantic_tokens = true
              return vim.b.semantic_tokens
            end
          end
        end
      })
    end,
    event = "LspAttach",
  },

  -- nvim-highlight-colors - Highlight color codes
  {
    "nvim-highlight-colors",
    for_cat = "other",
    on_require = { "nvim-highlight-colors" },
    after = function()
      require("nvim-highlight-colors").setup {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = true,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = false,

        ---Set custom colors
        ---Label must be properly escaped with '%' to adhere to `string.gmatch`
        --- :help string.gmatch
        custom_colors = {
          { label = '%-%-theme%-primary%-color', color = '#0f1419' },
          { label = '%-%-theme%-secondary%-color', color = '#5c6370' },
        },

        -- Exclude parsing certain filetypes
        -- NOTE: `exclude_buftypes` option is not available
        exclude_filetypes = { 'lazy' }
      }
    end,
    cmd = { "HighlightColors" },
    keys = {
      {
        "<leader>hl",
        "<cmd>HighlightColors On<cr>",
        desc = "🎨 Highlight Colors On"
      },
      {
        "<leader>hL",
        "<cmd>HighlightColors Off<cr>",
        desc = "🎨 Highlight Colors Off"
      },
      {
        "<leader>ht",
        "<cmd>HighlightColors Toggle<cr>",
        desc = "🎨 Toggle Highlight Colors"
      },
    },
  },
}