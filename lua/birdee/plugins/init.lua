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
  -- Set custom WinSeparator color for onedark
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6272a4" })
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
      sidebars = 'dark', -- style for sidebars, see below
      floats = 'dark', -- style for floating windows
    },
    sidebars = { 'qf', 'help' }, -- Set a darker background on sidebar-like windows
    day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false, -- dims inactive windows
    lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    ---@param colors ColorScheme
    on_colors = function(colors) end,

    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors)
      -- Set custom WinSeparator color
      highlights.WinSeparator = { fg = '#6272a4' }
    end,
  }
  require('tokyonight').load()
elseif colorschemer == 'catppuccin' then
  require('catppuccin').setup {
    flavour = 'mocha', -- latte, frappe, macchiato, mocha
    background = { -- :h background
      light = 'latte',
      dark = 'mocha',
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
      enabled = false, -- dims the background color of inactive window
      shade = 'dark',
      percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { 'italic' }, -- Change the style of comments
      conditionals = { 'italic' },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {},
    custom_highlights = {
      WinSeparator = { fg = '#6272a4' },
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = '',
      },
      -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
  }
  require('catppuccin').load()
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
  { import = MP:relpath "lsp", },
  { import = MP:relpath "editing", },
  { import = MP:relpath "visual", },
  { import = MP:relpath "document", },
  
  -- Additional utility plugins not categorized yet
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
    keys = {
      { "<leader>db", "<cmd>DBUI<cr>", desc = "🗃️  Database UI" },
    },
  }}