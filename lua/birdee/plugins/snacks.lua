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
    enabled = true,
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
    show_hidden = false,
    follow_symlinks = true,
    icons = { enabled = true },
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
    filters = {
      dotfiles = false,
      gitignored = false,
    },
  },
  
  -- Picker with disabled C-j/C-k keys for global navigation
  picker = {
    enabled = true,
    win = {
      list = {
        keys = {
          ["<c-j>"] = false,
          ["<c-k>"] = false,
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
  
  dashboard = { enabled = false },
})

-- Setup notification override first
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, o)
  vim.notify = snacks.notifier.notify
  return snacks.notifier.notify(msg, level, o)
end

-- Success notification
vim.notify("✅ Snacks configuration loaded", vim.log.levels.INFO)
vim.keymap.set({ 'n' }, '<Esc>', function() snacks.notifier.hide() end, { desc = 'dismiss notify popup' })

-- Helper function for picker shortcuts
local pickpick = function(name, args) return function() snacks.picker[name](args) end end

-- Override vim.ui.select to use snacks picker as default
vim.ui.select = function(items, opts, on_choice)
  opts = opts or {}
  opts.prompt = opts.prompt or "Select:"
  
  local picker_items = {}
  for i, item in ipairs(items) do
    table.insert(picker_items, {
      text = tostring(item),
      item = item,
      idx = i,
    })
  end
  
  require('snacks').picker({
    items = picker_items,
    prompt = opts.prompt,
    format = function(item)
      return item.text
    end,
  }, function(selected)
    if selected and on_choice then
      on_choice(selected.item, selected.idx)
    elseif on_choice then
      on_choice(nil, nil)
    end
  end)
end

-- Override vim.ui.input to use snacks input
vim.ui.input = function(opts, on_confirm)
  opts = opts or {}
  require('snacks').input(opts, on_confirm)
end

return {
  {
    "snacks.nvim",
    for_cat = "general",
    -- Keys for lazy loading
    keys = {
      {'<c-\\>', function() snacks.terminal() end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>E", function() snacks.explorer() end, mode = {"n"}, desc = 'File Explorer (Snacks)' },
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
      { "<leader>fr", pickpick("recent"), desc = "Recent" },
      -- git
      { "<leader>gL", pickpick("git_log_line"), desc = "Git Log Line" },
      { "<leader>gd", pickpick("git_diff"), desc = "Git Diff (Hunks)" },
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
    },
    -- Setup handled at top of file
  }
}