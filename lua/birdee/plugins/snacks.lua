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

return {
  {
    "snacks.nvim",
    for_cat = "general",
    keys = {
      {'<c-\\>', function() Snacks.terminal() end, mode = {'n'}, desc = 'open snacks terminal' },
      {"<leader>_", function() Snacks.lazygit.open() end, mode = {"n"}, desc = 'LazyGit' },
      {"<leader>gc", function() Snacks.lazygit.log() end, mode = {"n"}, desc = 'Lazy[G]it [C]ommit log' },
      {"<leader>gl", function() Snacks.gitbrowse.open() end, mode = {"n"}, desc = '[G]oto git [L]ink' },
      { "<leader>sf", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader><leader>s", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notification History" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = nixCats.settings.unwrappedCfgPath or nixCats.configDir }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      -- git
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "<leader>ds", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>ws", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    },
    event = { 'DeferredUIEnter' },
    after = function(_)
      -- NOTE: It is faster when you comment them out
      -- rather than disabling them.
      -- for some reason, they are still required
      -- when you do { enabled = false }
      Snacks.setup({
        -- dashboard = {},
        -- debug = {},
        -- bufdelete = {},
        -- dim = {},
        -- explorer = {},
        -- quickfile = {},
        -- bigfile = {},
        -- input = {},
        -- scratch = {},
        -- layout = {},
        -- zen = {},
        -- scroll = {},
        -- notifier = {},
        -- notify = {},
        -- win = {},
        -- picker = {},
        -- profiler = {},
        -- toggle = {},
        -- rename = {},
        -- words = {},

        picker = {},
        gitbrowse = {},
        lazygit = {},
        git = {},
        terminal = {},
        scope = {},
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
