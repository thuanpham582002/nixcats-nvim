-- Force setup Snacks configuration immediately
local snacks = require('snacks')
snacks.setup({
  -- Main modules
  debug = { enabled = true },
  bufdelete = { enabled = true },
  dim = { enabled = true },
  quickfile = { enabled = true },
  bigfile = { enabled = true },
  input = { enabled = true },
  scratch = { enabled = true },
  layout = { enabled = true },
  zen = { enabled = true },
  
  -- Scroll animation
  scroll = { 
    enabled = false,
    animate = {
      duration = { step = 15, total = 250 },
      easing = "linear",
    },
  },
  
  -- Notifier
  notifier = { 
    enabled = true,
    timeout = 3000,
  },
  notify = { enabled = true },
  win = { enabled = true },
  
  -- Explorer configuration
  explorer = {
    enabled = true,
    show_hidden = true,
    follow_symlinks = true,
    icons = { enabled = true },
    replace_netrw = true,
    keys = {
      close = "q",
      edit = "<cr>",
      split = "s",
      vsplit = "v",
      tab = "t",
      parent = "h",
      expand = "l",
      toggle_hidden = ".",
      toggle_gitignore = "g",
      refresh = "R",
      help = "?",
    },
  },
  
  -- Picker with disabled C-j/C-k keys for global navigation
  picker = {
    enabled = true,
    sources = {
      explorer = { hidden = true, ignored = true },
      files = { hidden = true, ignored = true },
    },
    layouts = {
      popup = {
        layout = {
          backdrop = 60,
          width = 0.8,
          height = 0.7,
          border = "rounded",
          box = "horizontal",
          {
            box = "vertical",
            { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
            { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
          },
          {
            win = "preview",
            title = "{preview:Preview}",
            width = 0.4,
            border = "rounded",
            title_pos = "center",
          },
        },
      },
    },
    layout = "popup", -- Use the custom popup layout
    sources = {
      explorer = {
        layout = {
          preview = false,   -- No preview for tree view
          layout = {
            backdrop = 60,
            width = 0.8,     -- 60% width for tree view
            height = 0.8,    -- 80% height
            position = "float", -- IMPORTANT: Must be "float" for popup
            border = "rounded",
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = "rounded",
              title = "📁 File Explorer",
              title_pos = "center",
            },
            {
              win = "list",
              border = "rounded",
            },
          },
        },
        actions = {
          edit_and_close = function(picker, item)
            if item and item.file and item.type == "file" then
              -- Open file and close explorer
              vim.cmd("edit " .. vim.fn.fnameescape(item.file))
              picker:close()
            else
              -- For directories, use default expand action
              picker:action("confirm")
            end
          end,
          explorer_copy = function(picker, item)
            if not item then
              return
            end
            local snacks = require("snacks")
            snacks.input({
              prompt = "Copy to",
              completion = "file",
            }, function(value)
              if not value or value:find("^%s$") then
                return
              end
              local dir = vim.fs.dirname(item.file)
              local to = vim.fs.normalize(dir .. "/" .. value)
              if vim.uv.fs_stat(to) then
                snacks.notify.warn("File already exists:\n- `" .. to .. "`")
                return
              end
              require("snacks.picker.util").copy_path(item.file, to)
              require("snacks.explorer.tree").refresh(vim.fs.dirname(to))
              require("snacks.explorer.actions").update(picker, { target = to })
            end)
          end,
        },
        win = {
          list = {
            keys = {
              ["<cr>"] = "edit_and_close", -- Enter to open file and close
              ["l"] = "edit_and_close",    -- 'l' to open file and close (or expand folder)
            },
          },
        },
      },
    },
    win = {
      list = {
        keys = {
          ["<c-j>"] = false,
          ["<c-k>"] = false,
          ["<M-h>"] = false,
        },
      },
    },
  },
  
  -- Git integration
  git = { enabled = true },
  gitbrowse = { enabled = true },
  lazygit = { 
    enabled = true,
    configure = true,
  },
  
  -- Terminal
  terminal = {
    enabled = true,
    win = {
      style = "terminal",
    },
  },
  
  -- Toggle keymaps with which-key integration
  toggle = {
    enabled = true,
    which_key = true,
    notify = true,
    icon = {
      enabled = " ",
      disabled = " ",
    },
    color = {
      enabled = "green", 
      disabled = "yellow",
    },
  },
  
  -- 1. Auto-highlight LSP references
  words = {
    enabled = true,
    debounce = 200,
  },
  
  -- 2. Pretty git signs + line numbers 
  statuscolumn = {
    enabled = true,
    left = { "mark", "sign" }, -- left side
    right = { "fold", "git" }, -- right side  
    folds = {
      open = true, -- show open fold icons
      git_hl = false, -- use git sign hl for folds
    },
    git = {
      -- patterns to match git signs
      patterns = { "GitSign", "MiniDiffSign" },
    },
    refresh = 50, -- refresh every 50ms
  },
  
  -- 3. Modern indent guides
  indent = {
    enabled = true,
    indent = {
      enabled = true,
      char = "│",
    },
    scope = {
      enabled = true,
      char = "│",
      underline = true, -- underline the scope
      only_current = false, -- only show scope of current line
    },
    chunk = {
      -- chunk highlighting
      enabled = true,
      -- only show chunk scopes after this level
      only_current = false,
      priority = 200,
      style = {
        { fg = "#806d9c" },
        { fg = "#c18a56", bold = true },
      },
      chars = {
        corner_top = "╭",
        corner_bottom = "╰", 
        horizontal = "─",
        vertical = "│",
        arrow = ">",
      },
    },
    blank = {
      enabled = false,
    },
  },
  
  -- 4. Beautiful startup dashboard (LZE compatible)
  dashboard = { 
    enabled = true,
    preset = {
      pick = nil, -- set to `nil` to disable the pick section
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.smart()" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.picker.files({cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", action = function() require('persistence').load() end },
        { icon = "󰒲 ", key = "L", desc = "LZE", action = ":help lze" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
      header = [[
⠀⠀⠀⠀⢀⣠⡴⠶⠟⠛⠛⠛⠶⠶⠤⣤⣀⠀⠀⠀⠀⣀⡤⠶⠶⠶⠶⢤⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢠⣶⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣦⣤⠞⠋⠀⠀⠀⠀⠀⠀⠈⠙⠻⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡼⠃⠀⠀⠀⠀⠀⠀⢀⣠⣤⣴⠶⠦⠶⠶⣦⣤⣤⣽⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢷⣤⣤⠤⠶⠞⠛⠛⠛⠛⠳⢦⣤⣘⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠘⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⢶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⠶⠶⠶⠶⠶⠶⠶⠾⠿⣿⣿⣛⠻⠶⣦⣝⣆⠀⠀⠀⠀⠀⠀⣀⣀⣀⣠⣤⣤⣽⣧⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣠⡾⣋⣤⠶⠖⠚⠛⠛⠛⠛⠛⠓⠶⣦⣌⠙⠻⣦⡈⠛⢿⡄⠀⠀⠀⠀⣀⡭⠿⢒⣛⣛⣛⣙⡛⢿⣷⣦⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⡾⠋⣾⠋⠁⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣙⣻⣶⣬⣟⢶⣄⢻⡄⠀⢰⠞⣫⡴⠟⠉⠉⠉⠉⠉⠙⢧⡙⡟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠘⠛⠛⠛⠾⢿⣍⡉⠉⣽⣿⣻⣿⣿⣿⠿⣿⣏⠉⠉⠉⠹⣯⠻⣎⣷⠀⢀⣼⣿⡿⣿⣿⠿⣿⣽⠳⠦⣤⣻⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⡈⠛⢿⣿⣿⣿⣿⣿⣧⣀⣼⣿⠀⠀⠀⠀⢹⡄⠹⡇⢰⡟⣿⣿⣷⣿⣧⣀⣼⣿⠄⠀⠀⣹⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠈⠙⠛⠿⢿⣿⣿⣿⠏⠀⠀⡀⣠⣤⣿⣤⠁⠾⣧⣿⣿⣷⣿⣿⣿⣿⣏⣤⣤⠾⢣⡇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠳⠶⠶⣤⣤⣄⣈⣉⣉⡉⠛⠛⢉⣁⣠⡾⠀⢠⣄⣈⡉⠉⠉⠉⠉⠉⣀⣈⣠⣶⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⣀⣀⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⣩⣿⠋⠀⠀⠀⠀⠈⠛⢿⣿⡓⠃⠀⢠⣭⣭⡿⠙⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠐⠛⠛⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡼⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⠀⠀⠘⣧⡀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⣴⣟⣛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡤⠶⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⢀⡟⢳⡀⠀⠀⠀⠀⠀⠀
⠀⠈⢱⡏⡏⢹⣟⠷⢶⣤⣄⣀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⣼⠃⠀⠀⠀⠀⠀⠀
⠀⠀⠈⠛⢶⣌⡙⠻⢶⣄⣈⠉⠉⠛⠛⠒⠶⠦⣤⣤⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡾⣡⡞⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠙⠶⣤⣈⠉⠛⠻⠶⢶⣤⣤⣄⣀⣀⣀⣉⠉⠉⠙⠛⠓⠚⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⣡⡾⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⣤⣀⠀⠀⠀⠈⠉⠉⠉⠉⠛⠛⠳⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠖⠛⠋⠀⣼⠃⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⠶⣤⣀⣀⢤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠶⠖⠛⠉⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⢶⣤⡀⠀⣼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡾⠟⠁⠀⠀⠘⠻⣾⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⡀⢀⣴⣿⡁⠀⠀⠀⠀⣀⠀⠀⠀⠉⠛⠶⣤⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡟⠀⠈⢻⡟⠁⣸⡇⠀⣠⡶⢛⡿⢻⡗⣠⡾⠀⠀⠈⠷⣦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣄⡀⠈⠛⠲⣿⠒⠛⢁⣴⢟⣠⡿⠟⠁⠀⠀⠀⠀⠀⠈⢷⣄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⡀⠀⠀⢸⣴⠞⢻⡷⠟⠉⠀⠀⠀⢀⡄⠀⠀⠀⠀⠀⠙⣷⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣇⠀⠀⠘⢷⣤⣟⠀⠀⠀⠀⢀⡾⠋⠀⠀⠀⢀⡄⠀⠀⠻⣦⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠉⠛⠳⣶⡄⢠⡿⠁⠀⠀⢀⡶⠛⠁⠀⣰⠀⢹⣇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⢻⡄⠀⠀⠀⠀⠀⠀⠈⠙⠛⣧⠀⠀⣴⡟⠁⠀⢀⣴⠏⠀⠀⢻⡄
      ]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
  },
  
  -- 5. Smart text objects based on treesitter/indent
  scope = {
    enabled = true,
    -- what to do when treesitter is not available
    fallback = "indent", 
    cursor = true, -- enhance cursor movement
    treesitter = {
      -- blocks to consider for scope detection  
      blocks = {
        "function_item",
        "function_definition", 
        "method_definition",
        "class_definition",
        "do_block",
        "if_statement",
        "for_statement",
        "while_statement",
        "with_statement",
        "try_statement",
        "match_statement",
        "block",
      },
    },
  },
})

-- Setup notification override first
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, o)
  vim.notify = snacks.notifier.notify
  return snacks.notifier.notify(msg, level, o)
end

-- Success notification (removed for cleaner startup)
vim.keymap.set({ 'n' }, '<Esc>', function() snacks.notifier.hide() end, { desc = 'dismiss notify popup' })

-- Helper function for picker shortcuts
local pickpick = function(name, args) return function() snacks.picker[name](args) end end

return {
  {
    "snacks.nvim",
    for_cat = "general",
    -- Keys for lazy loading
    keys = {
      {'<c-\\>', function() snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>1", function() require('snacks').picker.explorer({ hidden = true, ignored = true, dotfiles = true }) end, mode = {"n"}, desc = 'File Explorer (Snacks)' },
      {"<leader>_", function() snacks.lazygit.open() end, mode = {"n"}, desc = 'LazyGit' },
      {"<leader>gc", function() snacks.lazygit.log() end, mode = {"n"}, desc = 'Lazy[G]it [C]ommit log' },
      {"<leader>gl", function() snacks.gitbrowse.open() end, mode = {"n"}, desc = '[G]oto git [L]ink' },
      { "<leader>sf", pickpick("smart"), desc = "Smart Find Files" },
      { "<leader><leader>s", pickpick("buffers"), desc = "Buffers" },
      { "<leader>/", pickpick("grep"), desc = "Grep" },
      { "<leader>:", pickpick("command_history"), desc = "Command History" },
      { "<leader>sn", pickpick("notifications"), desc = "Notification History" },
      -- find
      { "<leader>fb", pickpick("buffers"), desc = "Buffers" },
      { "<leader>fc", pickpick("files", { cwd = nixCats.settings.unwrappedCfgPath or nixCats.configDir }), desc = "Find Config File" },
      { "<leader>ff", pickpick("files"), desc = "Find Files" },
      { "<leader>fg", pickpick("git_files"), desc = "Find Git Files" },
      { "<leader>fp", pickpick("projects"), desc = "Projects" },
      { "<leader>e", function()
        require('snacks').picker.recent()
        vim.defer_fn(function()
          vim.cmd("stopinsert")
        end, 50)
      end,
      mode = {"n"},
      desc = "Recent Files"
    },
      -- git
      { "<leader>gb", pickpick("git_branches"), desc = "Git Branches" },
      { "<leader>gs", pickpick("git_status"), desc = "Git Status" },
      { "<leader>gl", pickpick("git_log"), desc = "Git Log" },
      { "<leader>gL", pickpick("git_log_line"), desc = "Git Log Line" },
      { "<leader>gF", pickpick("git_log_file"), desc = "Git Log File" },
      { "<leader>gd", pickpick("git_diff"), desc = "Git Diff (Hunks)" },
      { "<leader>gS", pickpick("git_stash"), desc = "Git Stash" },
      { "<leader>gG", pickpick("git_grep"), desc = "Git Grep" },
      -- Grep
      { "<leader>sb", pickpick("lines"), desc = "Buffer Lines" },
      { "<leader>sB", pickpick("grep_buffers"), desc = "Grep Open Buffers" },
      { "<leader>sg", pickpick("grep"), desc = "Grep" },
      { "<leader>sw", pickpick("grep_word"), desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"', pickpick("registers"), desc = "Registers" },
      { '<leader>s/', pickpick("search_history"), desc = "Search History" },
      { "<leader>sa", pickpick("autocmds"), desc = "Autocmds" },
      { "<leader>sb", pickpick("lines"), desc = "Buffer Lines" },
      { "<leader>sc", pickpick("command_history"), desc = "Command History" },
      { "<leader>sC", pickpick("commands"), desc = "Commands" },
      { "<leader>sd", pickpick("diagnostics"), desc = "Diagnostics" },
      { "<leader>sD", pickpick("diagnostics_buffer"), desc = "Buffer Diagnostics" },
      { "<leader>sh", pickpick("help"), desc = "Help Pages" },
      { "<leader>sH", pickpick("highlights"), desc = "Highlights" },
      { "<leader>si", pickpick("icons"), desc = "Icons" },
      { "<leader>sj", pickpick("jumps"), desc = "Jumps" },
      { "<leader>sk", pickpick("keymaps"), desc = "Keymaps" },
      { "<leader>sl", pickpick("loclist"), desc = "Location List" },
      { "<leader>sm", pickpick("marks"), desc = "Marks" },
      { "<leader>sM", pickpick("man"), desc = "Man Pages" },
      { "<leader>sq", pickpick("qflist"), desc = "Quickfix List" },
      { "<leader>sr", pickpick("resume"), desc = "Resume" },
      { "<leader>su", pickpick("undo"), desc = "Undo History" },
      -- LSP
      { "gd", pickpick("lsp_definitions"), desc = "Goto Definition" },
      { "gD", pickpick("lsp_declarations"), desc = "Goto Declaration" },
      { "gr", pickpick("lsp_references"), nowait = true, desc = "References" },
      { "gI", pickpick("lsp_implementations"), desc = "Goto Implementation" },
      { "gy", pickpick("lsp_type_definitions"), desc = "Goto T[y]pe Definition" },
      { "<leader>ds", pickpick("lsp_symbols"), desc = "LSP Symbols" },
      { "<leader>ws", pickpick("lsp_workspace_symbols"), desc = "LSP Workspace Symbols" },
      
      -- Make snacks picker default for common operations  
      { "<C-p>", pickpick("files"), desc = "Find Files (Ctrl+P)" },
      { "<C-f>", pickpick("grep"), desc = "Live Grep (Ctrl+F)" },
      { "<C-b>", pickpick("buffers"), desc = "Switch Buffer (Ctrl+B)" },
      
      -- Toggle keymaps with which-key integration
      { "<leader>ud", function() snacks.toggle.diagnostics() end, desc = "Toggle Diagnostics" },
      { "<leader>uh", function() snacks.toggle.inlay_hints() end, desc = "Toggle Inlay Hints" },
      { "<leader>un", function() snacks.toggle.line_number() end, desc = "Toggle Line Numbers" },
      { "<leader>us", function() snacks.toggle.spell() end, desc = "Toggle Spell Check" },
      { "<leader>uw", function() snacks.toggle.wrap() end, desc = "Toggle Word Wrap" },
      { "<leader>ua", function() snacks.toggle.animate() end, desc = "Toggle Animations" },
      { "<leader>uD", function() snacks.toggle.dim() end, desc = "Toggle Dim Inactive" },
      { "<leader>uW", function() snacks.toggle.words() end, desc = "Toggle LSP Word Highlights" },
      { "<leader>ui", function() snacks.toggle.indent() end, desc = "Toggle Indent Guides" },
      
      -- Scope navigation keymaps  
      { "]]", function() snacks.scope.next() end, desc = "Next Scope" },
      { "[[", function() snacks.scope.prev() end, desc = "Previous Scope" },
    },
    -- Setup handled at top of file
  }
}
