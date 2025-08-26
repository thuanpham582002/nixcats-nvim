-- NOTE: this plugin is "loaded" at startup,
-- but we delay the main setup call until later.
-- also we still need to require bigfile from the main one
-- because it tries to index the Snacks global unsafely...

-- also shut up I dont care
---@diagnostic disable-next-line: invisible
require('snacks').bigfile.setup()
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, o)
  vim.notify = Snacks.notifier.notify
  return Snacks.notifier.notify(msg, level, o)
end
vim.keymap.set({ 'n' }, '<Esc>', function() Snacks.notifier.hide() end, { desc = 'dismiss notify popup' })

local pickpick = function(name, args) return function() Snacks.picker[name](args) end end

return {
  {
    "snacks.nvim",
    for_cat = "general",
    event = { 'DeferredUIEnter' },
    dep_of = { "nvim-aider", "opencode.nvim" },
    load = function()end,
    keys = {
      {'<c-\\>', function() Snacks.terminal() end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>E", function() Snacks.explorer() end, mode = {"n"}, desc = 'File Explorer (Snacks)' },
      {"<leader>_", function() Snacks.lazygit.open() end, mode = {"n"}, desc = 'LazyGit' },
      {"<leader>gc", function() Snacks.lazygit.log() end, mode = {"n"}, desc = 'Lazy[G]it [C]ommit log' },
      {"<leader>gl", function() Snacks.gitbrowse.open() end, mode = {"n"}, desc = '[G]oto git [L]ink' },
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
    },
    after = function(_)
      -- NOTE: It is faster when you comment them out
      -- rather than disabling them.
      -- for some reason, they are still required
      -- when you do { enabled = false }
      Snacks.setup({
        -- dashboard = { enabled = false }, -- Disabled to avoid lazy.stats conflicts
        debug = { enabled = true },
        bufdelete = { enabled = true },
        dim = { enabled = true },
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
        },
        quickfile = { enabled = true },
        bigfile = { enabled = true },
        input = { enabled = true },
        scratch = { enabled = true },
        layout = { enabled = true },
        zen = { enabled = true },
        scroll = { 
          enabled = true,
          animate = {
            duration = { step = 15, total = 250 },
            easing = "linear",
          },
        },
        notifier = { 
          enabled = true,
          timeout = 3000,
        },
        notify = { enabled = true },
        win = { enabled = true },
        picker = {
          enabled = true,
          win = {
            input = {
              keys = {
                -- Smart navigation keys
                ["<C-h>"] = function()
                  if vim.env.TMUX then
                    vim.fn.system("tmux select-pane -L")
                  end
                end,
                ["<C-j>"] = "move_down",
                ["<C-k>"] = "move_up", 
                ["<C-l>"] = function()
                  if vim.env.TMUX then
                    vim.fn.system("tmux select-pane -R")
                  end
                end,
              },
            },
          },
        },
        profiler = { enabled = true },
        toggle = { enabled = true },
        rename = { enabled = true },
        words = { 
          enabled = true,
          debounce = 100,
        },
        gitbrowse = { enabled = true },
        lazygit = { 
          enabled = true,
          configure = true,
        },
        git = { enabled = true },
        terminal = {
          enabled = true,
          win = {
            style = "terminal",
            keys = {
              nav_h = "<C-h>",
              nav_j = "<C-j>", 
              nav_k = "<C-k>",
              nav_l = "<C-l>",
            },
          },
        },
        scope = { enabled = true },
        indent = {
          scope = {
            hl = 'Hlargs',
          },
          chunk = {
            -- enabled = true,
            hl = 'Hlargs',
          }
        },
        statuscolumn = {
          left = { "mark", "git" }, -- priority of signs on the left (high to low)
          right = { "sign", "fold" }, -- priority of signs on the right (high to low)
          folds = {
            open = false, -- show open fold icons
            git_hl = false, -- use Git Signs hl for fold icons
          },
          git = {
            -- patterns to match Git signs
            patterns = { "GitSign", "MiniDiffSign" },
          },
          refresh = 50, -- refresh at most every 50ms
        },
      })
    end,
  }
}
