local MP = ...
local catUtils = require('nixCatsUtils')
local colorschemer = nixCats.extra('colorscheme') -- also schemes lualine
if not catUtils.isNixCats then
  colorschemer = 'onedark'
end
if colorschemer == 'onedark' then
  require('onedark').setup {
    -- Set a style preset. 'dark' is default.
    style = 'darker', -- dark, darker, cool, deep, warm, warmer, light
  }
  require('onedark').load()
elseif colorschemer == 'tokyonight' or colorschemer == 'tokyonight-day' then
  require('tokyonight').setup {
    -- Available styles: storm, moon, night, day
    style = colorschemer == 'tokyonight-day' and 'day' or 'storm',
    light_style = 'day', -- The theme is used when the background is set to light
    transparent = false, -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "dark", -- style for sidebars, see below
      floats = "dark", -- style for floating windows
    },
    sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows
    day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines
    dim_inactive = false, -- dims inactive windows
    lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
  }
end
if colorschemer ~= "" then
  vim.cmd.colorscheme(colorschemer)
end

if nixCats('other') then
  vim.keymap.set('n', '<leader>rs', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
  })
  vim.keymap.set('n', '<leader>rw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('v', '<leader>rw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
  })
  vim.keymap.set('n', '<leader>rf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
  })
end
-- NOTE: This is already lazy. It doesnt require it until you use the keybinding
vim.keymap.set({ 'n', }, "<leader>cpc", function() require("color_picker").rgbPicker() end, { desc = "color_picker rgb" })
vim.keymap.set({ 'n', }, "<leader>cph", function() require("color_picker").hsvPicker() end, { desc = "color_picker hsv" })
vim.keymap.set({ 'n', }, "<leader>cps", function() require("color_picker").hslPicker() end, { desc = "color_picker hsl" })
vim.keymap.set({ 'n', }, "<leader>cpg", function() require("color_picker").rgbGradientPicker() end, { desc = "color_picker rgb gradient" })
vim.keymap.set({ 'n', }, "<leader>cpd", function() require("color_picker").hsvGradientPicker() end, { desc = "color_picker hsv gradient" })
vim.keymap.set({ 'n', }, "<leader>cpb", function() require("color_picker").hslGradientPicker() end, { desc = "color_picker hsl gradient"})

if nixCats('general') then
  -- No need to copy this inside `setup()`. Will be used automatically.
  require("mini.sessions").setup {
    -- Whether to read default session if Neovim opened without file arguments
    autoread = true,

    -- Whether to write currently read session before leaving it
    autowrite = true,

    -- Directory where global sessions are stored (use `''` to disable)
    directory = vim.fn.stdpath('data') .. "/sessions",

    -- File for local session (use `''` to disable)
    file = 'Session.vim',

    -- Whether to force possibly harmful actions (meaning depends on function)
    force = { read = false, write = true, delete = false },

    -- Hook functions for actions. Default `nil` means 'do nothing'.
    hooks = {
      -- Before successful action
      pre = { read = nil, write = nil, delete = nil },
      -- After successful action
      post = { read = nil, write = nil, delete = nil },
    },

    -- Whether to print session path after action
    verbose = { read = false, write = true, delete = true },
  }
  -- require(MP:relpath 'oil') -- Removed - using Snacks Explorer instead
end

return {
  { import = MP:relpath "snacks", },
  { import = MP:relpath "nestsitter", },
  { import = MP:relpath "blink", },
  { import = MP:relpath "conjure", },
  { import = MP:relpath "grapple", },
  { import = MP:relpath "lualine", },
  { import = MP:relpath "git", },
  { import = MP:relpath "image", },
  { import = MP:relpath "which-key", },
  { import = MP:relpath "AI", },
  { import = MP:relpath "ui", },
  -- Claude Code integration
  {
    'claudecode.nvim',
    for_cat = { cat = 'AI.claudecode', default = false },
    keys = {
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude Code terminal' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = { 'n', 'v' }, desc = 'Send to Claude Code' },
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept Claude Code diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny Claude Code diff' },
    },
    cmd = {
      'ClaudeCode',
      'ClaudeCodeSend', 
      'ClaudeCodeDiffAccept',
      'ClaudeCodeDiffDeny'
    },
    after = function()
      vim.defer_fn(function()
        local ok, claudecode = pcall(require, 'claudecode')
        if ok then
          claudecode.setup({
            -- Plugin configuration options
            terminal = {
              snacks_win_opts = {
                bo = {
                  filetype = "claudecode", -- Custom filetype instead of snacks_terminal
                },
              },
            },
          })
        else
          vim.notify("Claude Code plugin loaded but setup failed", vim.log.levels.WARN)
        end
      end, 100)
    end,
  },
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
  {
    "typst-preview.nvim",
    ft = "typst",
    after = function()
      require 'typst-preview'.setup {
        -- Setting this true will enable logging debug information to
        -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
        debug = false,
        -- Custom format string to open the output link provided with %s
        -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
        open_cmd = nil,
        -- Custom port to open the preview server. Default is random.
        -- Example: port = 8000
        port = nil,
        -- Setting this to 'always' will invert black and white in the preview
        -- Setting this to 'auto' will invert depending if the browser has enable
        -- dark mode
        -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
        -- your choice of color inversion to images and everything else
        -- separately.
        invert_colors = 'never',
        -- Whether the preview will follow the cursor in the source file
        follow_cursor = true,
        -- Provide the path to binaries for dependencies.
        -- Setting this will skip the download of the binary by the plugin.
        -- Warning: Be aware that your version might be older than the one
        -- required.
        dependencies_bin = {
          tinymist = 'tinymist',
          websocat = 'websocat'
        },
        -- A list of extra arguments (or nil) to be passed to previewer.
        -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
        extra_args = nil,
        -- This function will be called to determine the root of the typst project
        get_root = function(path_of_main_file)
          local root = os.getenv 'TYPST_ROOT'
          if root then
            return root
          end
          return vim.fn.fnamemodify(path_of_main_file, ':p:h')
        end,
        -- This function will be called to determine the main file of the typst
        -- project.
        get_main_file = function(path_of_buffer)
          return path_of_buffer
        end,
      }
    end,
  },
  {
    "markdown-preview.nvim",
    for_cat = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(_)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "render-markdown.nvim",
    for_cat = "markdown",
    ft = "markdown",
    after = function(_)
      require('render-markdown').setup({})
    end,
  },
  {
    "otter.nvim",
    for_cat = "otter",
    -- event = "DeferredUIEnter",
    on_require = { "otter" },
    -- ft = { "markdown", "norg", "templ", "nix", "javascript", "html", "typescript", },
    after = function(_)
      local otter = require 'otter'
      otter.setup {
        lsp = {
          -- `:h events` that cause the diagnostics to update. Set to:
          -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
          -- but more instant diagnostic updates
          diagnostic_update_events = { "BufWritePost" },
          -- function to find the root dir where the otter-ls is started
          root_dir = function(_, bufnr)
            return vim.fs.root(bufnr or 0, {
              ".git",
              "_quarto.yml",
              "package.json",
            }) or vim.fn.getcwd(0)
          end,
        },
        buffers = {
          -- if set to true, the filetype of the otterbuffers will be set.
          -- otherwise only the autocommand of lspconfig that attaches
          -- the language server will be executed without setting the filetype
          set_filetype = false,
          -- write <path>.otter.<embedded language extension> files
          -- to disk on save of main buffer.
          -- usefule for some linters that require actual files
          -- otter files are deleted on quit or main buffer close
          write_to_disk = false,
        },
        verbose = {          -- set to false to disable all verbose messages
          no_code_found = false, -- warn if otter.activate is called, but no injected code was found
        },
        strip_wrapping_quote_characters = { "'", '"', "`" },
        -- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
        -- When true, otter handles these cases fully.
        handle_leading_whitespace = false,
      }
    end,
  },
  {
    "dial.nvim",
    for_cat = "general.core",
    keys = {
      { "<C-a>", function() require("dial.map").manipulate("increment", "normal") end, mode = "n", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n", desc = "Decrement" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end, mode = "n", desc = "Decrement" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end, mode = "n", desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end, mode = "n", desc = "Decrement" },
      { "<C-a>", function() require("dial.map").manipulate("increment", "visual") end, mode = "v", desc = "Increment" },
      { "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end, mode = "v", desc = "Increment" },
      { "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end, mode = "v", desc = "Increment" },
      { "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end, mode = "v", desc = "Increment" },
    },
    after = function(_)
      local augend = require("dial.augend")
      require("dial.config").augends:register_group{
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%H:%M"],
          augend.constant.alias.ja_weekday_full,
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      }
    end
  },
  {
    "undotree",
    for_cat = "general.core",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "todo-comments.nvim",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require("todo-comments").setup({ signs = false })
    end,
  },
  {
    "visual-whitespace",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require('visual-whitespace').setup({
        highlight = { link = 'Visual' },
        space_char = '·',
        tab_char = '→',
        nl_char = '↲'
      })
    end,
  },
  {
    "vim-startuptime",
    for_cat = "other",
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    "nvim-surround",
    for_cat = "general.core",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      require('nvim-surround').setup()
    end,
  },
  {
    "eyeliner.nvim",
    for_cat = "other",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      -- Highlights unique characters for f/F and t/T motions
      require('eyeliner').setup {
        highlight_on_key = true, -- show highlights only after key press
        dim = true,          -- dim all other characters
      }
    end,
  },
  {
    "vim-dadbod",
    for_cat = "SQL",
    cmd = { "DB", "DBUI", "DBUIAddConnection", "DBUIClose",
      "DBUIToggle", "DBUIFindBuffer", "DBUILastQueryInfo", "DBUIRenameBuffer", },
    load = function(name)
      require("lzextras").loaders.multi {
        name,
        "vim-dadbod-ui",
      }
      require("lzextras").loaders.with_after("vim-dadbod-completion")
    end,
    after = function(_)
    end,
  },
  {
    "hlargs",
    for_cat = "other",
    event = "DeferredUIEnter",
    after = function(_)
      require('hlargs').setup({
        color = '#32a88f',
      })
      vim.cmd([[hi clear @lsp.type.parameter]])
      vim.cmd([[hi link @lsp.type.parameter Hlargs]])
    end,
  },
  {
    "vim-sleuth",
    for_cat = "general.core",
    event = "DeferredUIEnter",
  },
  {
    "nvim-highlight-colors",
    for_cat = "other",
    event = "DeferredUIEnter",
    -- ft = "",
    after = function(_)
      require("nvim-highlight-colors").setup {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = true,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = true,

        ---Set custom colors
        ---Label must be properly escaped with '%' to adhere to `string.gmatch`
        --- :help string.gmatch
        custom_colors = {
          { label = '%-%-theme%-primary%-color',   color = '#0f1219' },
          { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
        }
      }
    end,
  },
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
        -- 🗂️ LEFT ZONE: File Explorer & Project Navigation
        left = {
          title = "Explorer & Files",
          size = 35,
          {
            title = "Explorer",
            ft = "snacks_explorer",
            size = { width = 0.7 },
            pinned = true,
            open = function()
              require("snacks").explorer()
            end,
          },
          {
            title = "Neo-Tree",
            ft = "neo-tree",
            size = { width = 0.3 },
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
          },
        },

        -- 🔍 RIGHT ZONE: Claude Code & Info Panel (Stacked)
        right = {
          title = "AI & Tools",
          {
            title = "Claude Code",
            ft = "claudecode", -- Custom filetype we set earlier
            size = { height = 0.6 }, -- 60% of right zone
            open = function()
              vim.cmd("ClaudeCode")
            end,
            filter = function(buf, win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              local buftype = vim.bo[buf].buftype
              local filetype = vim.bo[buf].filetype

              -- Accept Claude Code terminals
              if filetype == "claudecode" or bufname:match("term://.*claude") then
                return true
              end

              return false
            end,
            wo = {
              -- winfixheight = true, -- Disabled for resize
              winfixwidth = false,
            },
          },
          {
            title = "Outline & Debug Info",
            ft = { "sagaoutline", "dapui_scopes", "dapui_watches" },
            size = { height = 0.4 }, -- 40% of right zone
            filter = function(buf, win)
              local filetype = vim.bo[buf].filetype

              -- Accept outline, debug scopes, and watches
              local accepted_types = { "sagaoutline", "Outline", "dapui_scopes", "dapui_watches" }
              
              for _, ft in ipairs(accepted_types) do
                if filetype == ft then
                  return true
                end
              end

              return false
            end,
            wo = {
              -- winfixheight = true, -- Disabled for resize
            },
          },
        },

        -- ⬇️ BOTTOM ZONE: Terminal & Scratch Buffers
        bottom = {
          title = "Terminal & Scratch",
          size = 20,
          {
            title = "Terminal",
            ft = "snacks_terminal",
            size = { height = 0.4 }, -- 40% of bottom
            open = function()
              require("snacks").terminal()
            end,
            filter = function(buf, win)
              local buftype = vim.bo[buf].buftype
              local filetype = vim.bo[buf].filetype

              -- Accept native terminals only
              if buftype == "terminal" and filetype ~= "claudecode" then
                return true
              end

              return false
            end,
            wo = { -- winfixheight = true -- Disabled for resize
            },
          },
          {
            title = "Problems & Diagnostics",
            ft = "trouble",
            size = { height = 0.2 }, -- 20% of bottom
            open = "Trouble diagnostics toggle",
            filter = function(buf, win)
              return vim.w[win].trouble ~= nil
            end,
            wo = { -- winfixheight = true -- Disabled for resize
            },
          },
          {
            title = "Debug Console & REPL",
            ft = { "dap-repl", "dapui_console", "dapui_stacks", "dapui_breakpoints" },
            size = { height = 0.4 }, -- 40% of bottom for debugging
            filter = function(buf, win)
              local filetype = vim.bo[buf].filetype
              local dap_filetypes = { "dap-repl", "dapui_console", "dapui_stacks", "dapui_breakpoints" }
              
              for _, ft in ipairs(dap_filetypes) do
                if filetype == ft then
                  return true
                end
              end
              return false
            end,
            wo = { -- winfixheight = true -- Disabled for resize
            },
          },
          {
            title = "Scratch & Temporary",
            ft = { "help", "qf", "nofile", "scratch" },
            size = { height = 0.3 }, -- 30% of bottom
            filter = function(buf, win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              local buftype = vim.bo[buf].buftype
              local filetype = vim.bo[buf].filetype
              local modified = vim.bo[buf].modified

              -- EXCLUDE: File pickers and interactive tools that need to stay in center
              local exclude_filetypes = {
                "snacks_picker_input",
                "snacks_picker_list", -- Snacks file picker
                "TelescopePrompt",
                "TelescopeResults", -- Telescope
                "neo-tree",
                "oil", -- File managers
                "dap-repl",
                "dapui_console", -- Debug UIs
                "noice", -- Noice popups
              }

              -- Don't route these to bottom - they need to stay interactive
              for _, ft in ipairs(exclude_filetypes) do
                if filetype == ft then
                  return false
                end
              end

              -- Force these buffer types to bottom
              local bottom_buftypes = { "nofile", "nowrite", "quickfix", "help", "acwrite" }
              local bottom_filetypes = {
                "help",
                "qf",
                "man",
                "lspinfo",
                "checkhealth",
                "lazy",
                "mason",
                "null-ls-info",
                "scratch",
                "startify",
              }

              -- Check buffer types
              for _, bt in ipairs(bottom_buftypes) do
                if buftype == bt then
                  return true
                end
              end

              -- Check filetypes
              for _, ft in ipairs(bottom_filetypes) do
                if filetype == ft then
                  return true
                end
              end

              -- Unnamed/scratch buffers
              local is_scratch = (bufname == "" and not modified) or bufname:match("^%s*$") or bufname:match("^scratch://")

              return is_scratch
            end,
            wo = { -- winfixheight = true -- Disabled for resize
            },
          },
        },

        -- Animation settings
        animate = {
          enabled = true,
          fps = 100,
          cps = 120,
          on_begin = function()
            vim.g.minianimate_disable = true
          end,
          on_end = function()
            vim.g.minianimate_disable = false
          end,
        },

        -- Close empty edgy windows automatically
        close_when_all_hidden = true,

        -- Fix terminals
        fix_win_height = vim.fn.has("nvim-0.10.0") == 1,
      })
    end,
    
    -- Event-based loading like original
    event = "DeferredUIEnter",
    
    keys = {
      -- Zone toggles
      {
        "<leader>ue",
        function()
          require("edgy").toggle()
        end,
        desc = "🧩 Toggle Edgy",
      },
      {
        "<leader>ul",
        function()
          require("edgy").toggle("left")
        end,
        desc = "Toggle Explorer",
      },
      {
        "<leader>ur",
        function()
          require("edgy").toggle("right")
        end,
        desc = "Toggle Info Panel",
      },
      {
        "<leader>ub",
        function()
          require("edgy").toggle("bottom")
        end,
        desc = "Toggle Terminal",
      },

      -- Focus zones (Alt + numbers)
      {
        "<A-1>",
        function()
          require("edgy").goto_main("left")
        end,
        desc = "Focus Explorer",
      },
      {
        "<A-2>",
        function()
          require("edgy").goto_main("bottom")
        end,
        desc = "Focus Terminal",
      },
      {
        "<A-3>",
        function()
          require("edgy").goto_main("right")
        end,
        desc = "Focus Info Panel",
      },

      -- Layout presets from original
      {
        "<leader>up",
        function()
          -- Preset: Programming (wider left, normal right, small bottom)
          require("edgy").resize("left", 45)
          require("edgy").resize("right", 35)
          require("edgy").resize("bottom", 15)
          vim.notify("📐 Programming layout applied", vim.log.levels.INFO)
        end,
        desc = "Programming Layout",
      },

      {
        "<leader>ud",
        function()
          -- Preset: Debugging (wider bottom, normal sides)
          require("edgy").resize("left", 30)
          require("edgy").resize("right", 40)
          require("edgy").resize("bottom", 25)
          vim.notify("🐛 Debugging layout applied", vim.log.levels.INFO)
        end,
        desc = "Debugging Layout",
      },

      {
        "<leader>uf",
        function()
          -- Preset: Focus (minimal sides, small bottom)
          require("edgy").resize("left", 25)
          require("edgy").resize("right", 25)
          require("edgy").resize("bottom", 10)
          vim.notify("🎯 Focus layout applied", vim.log.levels.INFO)
        end,
        desc = "Focus Layout",
      },

      -- Open panels directly
      { "<leader>tc", "<cmd>ClaudeCode<cr>", desc = "Open Claude Code" },
      { "<leader>to", "<cmd>Lspsaga outline<cr>", desc = "Open Outline" },
      { "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Open Trouble" },
      { "<leader>td", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },

      -- Scratch buffer management
      {
        "<leader>bs",
        function()
          -- Clean up scratch/unnamed buffers
          local scratch_count = 0
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local bufname = vim.api.nvim_buf_get_name(buf)
              local buftype = vim.bo[buf].buftype
              local modified = vim.bo[buf].modified

              -- Delete unmodified scratch buffers
              local is_scratch = (bufname == "" and not modified) or buftype == "nofile" or buftype == "nowrite"

              if is_scratch then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                scratch_count = scratch_count + 1
              end
            end
          end
          vim.notify(string.format("🧹 Cleaned %d scratch buffer(s)", scratch_count), vim.log.levels.INFO)
        end,
        desc = "Clean Scratch Buffers",
      },
    },
  },
  {
    "diffview.nvim",
    for_cat = "general.core",
    on_require = { "diffview" },
    after = function()
      require('diffview').setup({
        -- Enhanced diff viewing configuration
        diff_binaries = false,
        enhanced_diff_hl = true,
        git_cmd = { "git" },
        
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
            position = "bottom",
            height = 16,
            win_opts = {}
          }
        },
        
        -- Default arguments
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        
        -- Hooks for custom behavior
        hooks = {
          diff_buf_read = function(bufnr)
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.colorcolumn = "80"
          end,
        },
        
        -- View configuration
        view = {
          default = {
            layout = "diff2_horizontal",
            winbar_info = true,
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
            winbar_info = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = true,
          },
        },
      })
    end,
    
    -- Command-based loading
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
    
    -- Key mappings
    keys = {
      {
        "<leader>gd",
        "<cmd>DiffviewOpen<cr>",
        desc = "Open Diffview",
      },
      {
        "<leader>gD",
        "<cmd>DiffviewClose<cr>",
        desc = "Close Diffview",
      },
      {
        "<leader>gh",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "File History",
      },
      {
        "<leader>gH",
        "<cmd>DiffviewFileHistory %<cr>",
        desc = "Current File History",
      },
      {
        "<leader>gF",
        "<cmd>DiffviewRefresh<cr>",
        desc = "Refresh Diffview",
      },
      {
        "<leader>gC",
        function()
          local branch = vim.fn.input("Compare with branch: ")
          if branch ~= "" then
            vim.cmd("DiffviewOpen " .. branch)
          end
        end,
        desc = "Compare with Branch",
      },
    },
  },
  {
    "lspsaga.nvim",
    for_cat = "general.core",
    on_require = { "lspsaga" },
    after = function()
      require('lspsaga').setup({
        -- UI Configuration
        ui = {
          theme = 'round',
          border = 'rounded',
          winblend = 0,
          expand = '',
          collapse = '',
          code_action = '💡',
          incoming = ' ',
          outgoing = ' ',
          hover = ' ',
          kind = {},
        },
        
        -- Symbol in winbar
        symbol_in_winbar = {
          enable = true,
          separator = ' › ',
          hide_keyword = true,
          show_file = true,
          folder_level = 2,
          respect_root = false,
          color_mode = true,
        },
        
        -- Code action configuration
        code_action = {
          num_shortcut = true,
          show_server_name = false,
          extend_gitsigns = true,
          keys = {
            quit = "q",
            exec = "<CR>",
          },
        },
        
        -- Lightbulb for code actions
        lightbulb = {
          enable = true,
          enable_in_insert = false,
          sign = true,
          sign_priority = 40,
          virtual_text = false,
        },
        
        -- Preview definition
        preview = {
          lines_above = 0,
          lines_below = 10,
        },
        
        -- Scroll in preview
        scroll_preview = {
          scroll_down = '<C-f>',
          scroll_up = '<C-b>',
        },
        
        -- Request timeout
        request_timeout = 2000,
        
        -- Finder configuration
        finder = {
          edit = { 'o', '<CR>' },
          vsplit = 's',
          split = 'i',
          tabe = 't',
          quit = { 'q', '<ESC>' },
        },
        
        -- Definition configuration
        definition = {
          edit = '<C-c>o',
          vsplit = '<C-c>v',
          split = '<C-c>i',
          tabe = '<C-c>t',
          quit = 'q',
        },
        
        -- Rename configuration
        rename = {
          quit = '<C-c>',
          exec = '<CR>',
          mark = 'x',
          confirm = '<CR>',
          in_select = true,
        },
        
        -- Diagnostic configuration
        diagnostic = {
          on_insert = false,
          on_insert_follow = false,
          insert_winblend = 0,
          show_code_action = true,
          show_source = true,
          jump_num_shortcut = true,
          max_width = 0.7,
          custom_fix = nil,
          custom_msg = nil,
          text_hl_follow = false,
          border_follow = true,
          keys = {
            exec_action = 'o',
            quit = 'q',
            go_action = 'g'
          },
        },
        
        -- Hover configuration
        hover = {
          max_width = 0.6,
          open_link = 'gx',
          open_browser = '!chrome',
        },
        
        -- Outline configuration
        outline = {
          win_position = 'right',
          win_with = '',
          win_width = 30,
          show_detail = true,
          auto_preview = true,
          auto_refresh = true,
          auto_close = true,
          custom_sort = nil,
          keys = {
            jump = 'o',
            expand_collapse = 'u',
            quit = 'q',
          },
        },
        
        -- Callhierarchy configuration
        callhierarchy = {
          show_detail = false,
          keys = {
            edit = 'e',
            vsplit = 's',
            split = 'i',
            tabe = 't',
            jump = 'o',
            quit = 'q',
            expand_collapse = 'u',
          },
        },
        
        -- Beacon configuration for jump highlights
        beacon = {
          enable = true,
          frequency = 7,
        },
      })
    end,
    
    -- Event-based loading for LSP-related functionality
    event = "LspAttach",
    
    -- Command-based loading
    cmd = {
      "Lspsaga",
    },
    
    -- Key mappings for enhanced LSP features
    keys = {
      -- LSP finder - find the symbol's definition/references/implementation/type def/declaration
      {
        "gf",
        "<cmd>Lspsaga finder<CR>",
        desc = "LSP Finder",
      },
      -- Code action
      {
        "<leader>ca",
        "<cmd>Lspsaga code_action<CR>",
        desc = "Code Action",
      },
      -- Rename
      {
        "gr", 
        "<cmd>Lspsaga rename<CR>",
        desc = "LSP Rename",
      },
      -- Rename ++project
      {
        "gR",
        "<cmd>Lspsaga rename ++project<CR>",
        desc = "LSP Rename Project",
      },
      -- Peek definition
      {
        "gp",
        "<cmd>Lspsaga peek_definition<CR>",
        desc = "Peek Definition", 
      },
      -- Go to definition
      {
        "gd",
        "<cmd>Lspsaga goto_definition<CR>",
        desc = "Go to Definition",
      },
      -- Peek type definition
      {
        "gt",
        "<cmd>Lspsaga peek_type_definition<CR>",
        desc = "Peek Type Definition",
      },
      -- Go to type definition
      {
        "gT",
        "<cmd>Lspsaga goto_type_definition<CR>",
        desc = "Go to Type Definition",
      },
      -- Show line diagnostics
      {
        "<leader>sl",
        "<cmd>Lspsaga show_line_diagnostics<CR>",
        desc = "Show Line Diagnostics",
      },
      -- Show cursor diagnostics
      {
        "<leader>sc",
        "<cmd>Lspsaga show_cursor_diagnostics<CR>",
        desc = "Show Cursor Diagnostics",
      },
      -- Show buffer diagnostics
      {
        "<leader>sb",
        "<cmd>Lspsaga show_buf_diagnostics<CR>",
        desc = "Show Buffer Diagnostics",
      },
      -- Diagnostic jump
      {
        "[e",
        "<cmd>Lspsaga diagnostic_jump_prev<CR>",
        desc = "Previous Diagnostic",
      },
      {
        "]e", 
        "<cmd>Lspsaga diagnostic_jump_next<CR>",
        desc = "Next Diagnostic",
      },
      -- Diagnostic jump with filters such as only jumping to an error
      {
        "[E",
        function()
          require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Previous Error",
      },
      {
        "]E",
        function()
          require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Next Error", 
      },
      -- Toggle outline
      {
        "<leader>o",
        "<cmd>Lspsaga outline<CR>",
        desc = "LSP Outline",
      },
      -- Hover Doc
      {
        "K",
        "<cmd>Lspsaga hover_doc<CR>",
        desc = "Hover Documentation",
      },
      -- Hover Doc ++keep to keep hover window
      {
        "<leader>K",
        "<cmd>Lspsaga hover_doc ++keep<CR>",
        desc = "Keep Hover Documentation",
      },
      -- Call hierarchy
      {
        "<Leader>ci",
        "<cmd>Lspsaga incoming_calls<CR>",
        desc = "Incoming Calls",
      },
      {
        "<Leader>co",
        "<cmd>Lspsaga outgoing_calls<CR>",
        desc = "Outgoing Calls",
      },
      -- Floating terminal
      {
        "<A-d>",
        "<cmd>Lspsaga term_toggle<CR>",
        mode = { "n", "t" },
        desc = "Toggle Terminal",
      },
    },
  },
  {
    "smart-splits.nvim",
    for_cat = "other",
    -- Don't lazy load for tmux integration
    on_require = { "smart-splits" },
    after = function()
      require('smart-splits').setup({
        -- Enable tmux integration for seamless navigation
        tmux_integration = true,
        
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
        
        -- Ignored file types  
        ignored_filetypes = {
          'NvimTree',
          'neo-tree',
          'oil',
          'snacks_picker_list',
          'snacks_picker',
          'snacks_explorer',  -- Add snacks explorer
        },
        
        -- Don't wrap when cursor is at edge
        move_cursor_same_row = false,
        
        -- Cursor follows focus
        cursor_follows_swapped_bufs = false,
        
        -- Floating window behavior
        float_win_behavior = 'previous',
        
        -- Log level for debugging
        log_level = 'info',
      })
      
      -- Smart resize function with edgy awareness
      local function unified_resize(direction, amount)
        return function()
          -- Check if we're in a tmux session
          local tmux_session = os.getenv("TMUX")
          
          -- Check if edgy is available and we're in an edgy window
          local edgy_ok, edgy = pcall(require, "edgy")
          local is_edgy_window = false
          
          if edgy_ok then
            local win = vim.api.nvim_get_current_win()
            is_edgy_window = edgy.get_win(win) ~= nil
          end
          
          -- Use smart-splits for resizing
          if direction == "left" then
            if amount > 0 then
              require('smart-splits').resize_right(amount)
            else
              require('smart-splits').resize_left(-amount)
            end
          elseif direction == "right" then
            if amount > 0 then
              require('smart-splits').resize_right(amount)
            else
              require('smart-splits').resize_left(-amount)
            end
          elseif direction == "up" then
            if amount > 0 then
              require('smart-splits').resize_up(amount)
            else
              require('smart-splits').resize_down(-amount)
            end
          elseif direction == "down" then
            if amount > 0 then
              require('smart-splits').resize_down(amount)
            else
              require('smart-splits').resize_up(-amount)
            end
          end
        end
      end
      
      -- Set unified keymaps for all modes (Alt+hjkl for resize)
      vim.keymap.set({"n", "t"}, "<M-h>", unified_resize("left", -5), { desc = "Smart Resize Left" })
      vim.keymap.set({"n", "t"}, "<M-j>", unified_resize("down", 5), { desc = "Smart Resize Down" })
      vim.keymap.set({"n", "t"}, "<M-k>", unified_resize("up", -5), { desc = "Smart Resize Up" })
      vim.keymap.set({"n", "t"}, "<M-l>", unified_resize("right", 5), { desc = "Smart Resize Right" })
      
      -- Auto-restore terminal insert mode when returning to terminal
      vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "WinEnter" }, {
        pattern = "*",
        callback = function()
          if vim.bo.buftype == "terminal" then
            if vim.b.was_terminal_insert then
              vim.schedule(function()
                vim.cmd("startinsert")
              end)
            elseif vim.b.terminal_mode_set == nil then
              -- Default terminal state is insert mode
              vim.schedule(function()
                vim.cmd("startinsert")
              end)
            end
          end
        end,
      })
    end,
    
    -- Key mappings for smart window management
    keys = {
      -- 40% keyboard friendly resize keymaps (using <leader>z for resize)
      {
        "<leader>zs",
        function() require('smart-splits').start_resize_mode() end,
        desc = "🔧 Start Resize Mode"
      },
      
      -- Direct resize (for quick adjustments)
      {
        "<leader>zh",
        function() require('smart-splits').resize_left() end,
        desc = "← Resize Left"
      },
      {
        "<leader>zj", 
        function() require('smart-splits').resize_down() end,
        desc = "↓ Resize Down"
      },
      {
        "<leader>zk",
        function() require('smart-splits').resize_up() end,
        desc = "↑ Resize Up"
      },
      {
        "<leader>zl",
        function() require('smart-splits').resize_right() end,
        desc = "→ Resize Right"
      },
      
      -- Window navigation for NORMAL mode
      {
        "<C-h>",
        function() require('smart-splits').move_cursor_left() end,
        desc = "← Move Left",
        mode = "n"
      },
      {
        "<C-j>",
        function() require('smart-splits').move_cursor_down() end,
        desc = "↓ Move Down",
        mode = "n"
      },
      {
        "<C-k>",
        function() require('smart-splits').move_cursor_up() end,
        desc = "↑ Move Up",
        mode = "n"
      },
      {
        "<C-l>",
        function() require('smart-splits').move_cursor_right() end,
        desc = "→ Move Right",
        mode = "n"
      },
      
      -- Window navigation for INSERT mode
      {
        "<C-h>",
        function() require('smart-splits').move_cursor_left() end,
        desc = "← Move Left",
        mode = "i"
      },
      {
        "<C-j>",
        function() require('smart-splits').move_cursor_down() end,
        desc = "↓ Move Down",
        mode = "i"
      },
      {
        "<C-k>",
        function() require('smart-splits').move_cursor_up() end,
        desc = "↑ Move Up",
        mode = "i"
      },
      {
        "<C-l>",
        function() require('smart-splits').move_cursor_right() end,
        desc = "→ Move Right",
        mode = "i"
      },
      
      -- Window navigation for VISUAL mode
      {
        "<C-h>",
        function() require('smart-splits').move_cursor_left() end,
        desc = "← Move Left",
        mode = "v"
      },
      {
        "<C-j>",
        function() require('smart-splits').move_cursor_down() end,
        desc = "↓ Move Down",
        mode = "v"
      },
      {
        "<C-k>",
        function() require('smart-splits').move_cursor_up() end,
        desc = "↑ Move Up",
        mode = "v"
      },
      {
        "<C-l>",
        function() require('smart-splits').move_cursor_right() end,
        desc = "→ Move Right",
        mode = "v"
      },
      
      -- Swapping windows (advanced) - use <leader>zw for window swap
      {
        "<leader>zwh",
        function() require('smart-splits').swap_buf_left() end,
        desc = "⟵ Swap Left"
      },
      {
        "<leader>zwj",
        function() require('smart-splits').swap_buf_down() end,
        desc = "⟱ Swap Down"
      },
      {
        "<leader>zwk",
        function() require('smart-splits').swap_buf_up() end,
        desc = "⟰ Swap Up"
      },
      {
        "<leader>zwl",
        function() require('smart-splits').swap_buf_right() end,
        desc = "⟶ Swap Right"
      },
    },
  },
  {
    "persistence.nvim",
    for_cat = "other",
    on_require = { "persistence" },
    after = function()
      require('persistence').setup({
        -- Session file directory
        dir = vim.fn.stdpath("data") .. "/sessions/",
        
        -- Session options
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" },
        
        -- Pre-save hook to clean up before saving session
        pre_save = function()
          -- Close all floating windows before saving session
          for _, win in pairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
              vim.api.nvim_win_close(win, false)
            end
          end
          
          -- Close any noice message windows
          if pcall(require, "noice") then
            require("noice").cmd("dismiss")
          end
        end,
      })
    end,
    
    -- Event-based loading
    event = "VimEnter",
    
    -- Key mappings for session management
    keys = {
      -- Quit and save session (the one you remember!)
      {
        "<leader>qq",
        function() 
          require("persistence").save()
          vim.cmd("qa")
        end,
        desc = "💾 Save Session & Quit"
      },
      -- Restore session for current directory
      {
        "<leader>qs",
        function() require("persistence").load() end,
        desc = "📂 Restore Session"
      },
      -- Restore last session
      {
        "<leader>ql",
        function() require("persistence").load({ last = true }) end,
        desc = "🔄 Restore Last Session"
      },
      -- Save current session
      {
        "<leader>qS",
        function() require("persistence").save() end,
        desc = "💾 Save Session"
      },
      -- Don't save current session on exit
      {
        "<leader>qd",
        function() require("persistence").stop() end,
        desc = "🚫 Don't Save Session"
      },
    },
  },
}
