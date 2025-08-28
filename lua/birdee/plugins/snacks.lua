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
    -- Force immediate loading for config application
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
      vim.notify("🔧 Snacks after function called!", vim.log.levels.WARN)
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
        -- Image viewing support for obsidian.nvim
        image = {
          enabled = true,
          resolve = function(path, src)
            -- Check if we're in an obsidian vault
            local has_obsidian, obsidian = pcall(require, "obsidian.api")
            if has_obsidian and obsidian.path_is_note(path) then
              return obsidian.resolve_image_path(src)
            end
            return src
          end,
        },
        
        -- ===============================================
        -- SNACKS EXPLORER CONFIGURATION
        -- ===============================================
        explorer = {
          enabled = true,
          show_hidden = false,        -- Hidden files không hiển thị mặc định
          follow_symlinks = true,     -- Follow symbolic links
          icons = {
            enabled = true,           -- Enable file icons
          },
          keys = {
            close = "q",
            edit = "<cr>",
            split = "s", 
            vsplit = "v",
            tab = "t",
            parent = "h",
            expand = "l",
            toggle_hidden = ".",      -- Toggle hidden files với dấu chấm
            toggle_gitignore = "g",   -- Toggle gitignore files
            refresh = "R",
            help = "?",
          },
          -- File filters
          filters = {
            dotfiles = false,         -- Don't filter dotfiles by default
            gitignored = false,       -- Don't filter gitignored files by default
          },
        },
        
        picker = {
          enabled = true,
          win = {
            input = {
              keys = {
                -- Override Alt+hjkl for smart-splits resize in input window too
                ["<M-h>"] = function()
                  vim.notify("🔧 Picker Input <M-h> resize left!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_left()
                end,
                ["<M-j>"] = function()
                  vim.notify("🔧 Picker Input <M-j> resize down!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_down()
                end,
                ["<M-k>"] = function()
                  vim.notify("🔧 Picker Input <M-k> resize up!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_up()
                end,
                ["<M-l>"] = function()
                  vim.notify("🔧 Picker Input <M-l> resize right!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_right()
                end,
              },
            },
            list = {
              keys = {
                -- Smart passthrough: try internal navigation first, then tmux if at boundary
                ["<C-h>"] = function()
                  vim.notify("🔍 List Override <C-h> triggered!", vim.log.levels.WARN)
                  
                  -- Default behavior: move panel/pane (tmux or smart-splits)
                  -- Workaround for smart-splits tmux issue #342
                  if vim.env.TMUX then
                    vim.notify("📺 TMUX detected, switching pane left", vim.log.levels.INFO)
                    vim.fn.system("tmux select-pane -L")
                  else
                    vim.notify("❌ Not in TMUX, trying smart-splits", vim.log.levels.INFO)
                    require('smart-splits').move_cursor_left()
                  end
                end,
                
                ["<C-j>"] = function()
                  vim.notify("🔍 List Override <C-j> triggered!", vim.log.levels.DEBUG)
                  local picker = require("snacks.picker").current
                  if not picker then
                    require('smart-splits').move_cursor_down()
                    return
                  end
                  
                  local list = picker.list
                  if list and list:can_move(1) then
                    -- Can move down in list
                    vim.api.nvim_input('<Down>')
                  else
                    -- At bottom boundary, pass to smart-splits
                    vim.notify("📍 At bottom boundary, using smart-splits down", vim.log.levels.DEBUG)
                    require('smart-splits').move_cursor_down()
                  end
                end,
                
                ["<C-k>"] = function()
                  vim.notify("🔍 List Override <C-k> triggered!", vim.log.levels.DEBUG)
                  local picker = require("snacks.picker").current
                  if not picker then
                    require('smart-splits').move_cursor_up()
                    return
                  end
                  
                  local list = picker.list  
                  if list and list:can_move(-1) then
                    -- Can move up in list
                    vim.api.nvim_input('<Up>')
                  else
                    -- At top boundary, pass to smart-splits
                    vim.notify("📍 At top boundary, using smart-splits up", vim.log.levels.DEBUG)
                    require('smart-splits').move_cursor_up()
                  end
                end,
                
                ["<C-l>"] = function()
                  vim.notify("🔍 List Override <C-l> triggered!", vim.log.levels.WARN)
                  
                  -- Check if we have multiple windows first
                  local current_win = vim.fn.winnr()
                  local total_wins = vim.fn.winnr('$')
                  
                  if total_wins > 1 then
                    -- Multiple windows: try vim window navigation
                    if current_win < total_wins then
                      vim.notify("🪟 Moving to next window (right)", vim.log.levels.INFO)
                      vim.cmd('wincmd l')  -- Move right
                    else
                      vim.notify("🔄 Wrapping to first window", vim.log.levels.INFO)  
                      vim.cmd('wincmd w')  -- Next window (wrap around)
                    end
                  else
                    -- Single window: check for directory entry or use tmux/smart-splits
                    local picker = require("snacks.picker").current
                    if picker and picker.list then
                      local current_item = picker.list:get_cursor_item()
                      if current_item and current_item.kind == "dir" then
                        -- Enter directory
                        vim.notify("📂 Entering directory: " .. (current_item.text or ""), vim.log.levels.INFO)
                        vim.api.nvim_input('<CR>')
                        return
                      end
                    end
                    
                    -- No directory to enter, use tmux/smart-splits
                    if vim.env.TMUX then
                      vim.notify("📺 Single window + TMUX: switching pane right", vim.log.levels.INFO)
                      vim.fn.system("tmux select-pane -R")
                    else
                      vim.notify("❌ Single window, no TMUX: trying smart-splits", vim.log.levels.INFO)
                      require('smart-splits').move_cursor_right()
                    end
                  end
                end,

                -- Override Alt+hjkl for smart-splits resize (Snacks defaults to toggle_hidden/etc)
                ["<M-h>"] = function()
                  vim.notify("🔧 List <M-h> resize left!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_left()
                end,
                ["<M-j>"] = function()
                  vim.notify("🔧 List <M-j> resize down!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_down()
                end,
                ["<M-k>"] = function()
                  vim.notify("🔧 List <M-k> resize up!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_up()
                end,
                ["<M-l>"] = function()
                  vim.notify("🔧 List <M-l> resize right!", vim.log.levels.DEBUG)
                  require('smart-splits').resize_right()
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
            -- Navigation handled by context-aware global keymaps
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
      
      -- Set up simple global navigation (snacks picker has its own config above)
      vim.notify("🗺️ Setting up global smart-splits navigation...", vim.log.levels.INFO)
      
      vim.keymap.set({ 'n', 't' }, '<C-h>', function() 
        vim.notify("🌍 Global <C-h> triggered!", vim.log.levels.DEBUG)
        require('smart-splits').move_cursor_left() 
      end, { desc = "← Move Left (Global)" })
      
      vim.keymap.set({ 'n', 't' }, '<C-j>', function() 
        vim.notify("🌍 Global <C-j> triggered!", vim.log.levels.DEBUG)
        require('smart-splits').move_cursor_down() 
      end, { desc = "↓ Move Down (Global)" })
      
      vim.keymap.set({ 'n', 't' }, '<C-k>', function() 
        vim.notify("🌍 Global <C-k> triggered!", vim.log.levels.DEBUG)
        require('smart-splits').move_cursor_up() 
      end, { desc = "↑ Move Up (Global)" })
      
      vim.keymap.set({ 'n', 't' }, '<C-l>', function() 
        vim.notify("🌍 Global <C-l> triggered!", vim.log.levels.DEBUG)
        require('smart-splits').move_cursor_right() 
      end, { desc = "→ Move Right (Global)" })
      
      -- Old override logic removed - now handled by context-aware navigation
    end,
    
    -- Add cursor persistence logic from dotfiles
    init = function()
      -- Simple cursor position persistence for project-scoped state  
      local function get_state_file()
        local cwd = vim.fn.getcwd()
        local hash = vim.fn.sha256(cwd)
        return vim.fn.stdpath("cache") .. "/snacks-cursor-" .. hash:sub(1, 8) .. ".json"
      end
      
      -- State tracking (no debounce)
      local restore_completed = false
      local initial_cursor_pos = nil
      
      local function save_cursor()
        -- Only save if restore has completed
        if not restore_completed then
          return -- Don't save until restore is done
        end
        
        local cursor_pos = vim.fn.getcurpos()
        
        -- Don't save if position hasn't changed from restored position
        if initial_cursor_pos and cursor_pos[2] and initial_cursor_pos[2] and
           cursor_pos[2] == initial_cursor_pos[2] then
          return -- Same as restored, no need to save
        end
        
        local state_file = get_state_file()
        local state = { cursor = cursor_pos, timestamp = os.time() }
        
        local ok, json = pcall(vim.json.encode, state)
        if ok then
          local file = io.open(state_file, "w")
          if file then
            file:write(json)
            file:close()
          end
        end
      end
      
      local function restore_cursor()
        restore_completed = false -- Reset state
        
        local state_file = get_state_file()
        local file = io.open(state_file, "r")
        if file then
          local content = file:read("*a")
          file:close()
          
          local ok, state = pcall(vim.json.decode, content)
          if ok and state and state.cursor then
            vim.schedule(function()
              vim.defer_fn(function()
                if vim.bo.filetype:match("^snacks_picker") then
                  vim.fn.setpos(".", state.cursor)
                  initial_cursor_pos = state.cursor -- Remember restored position
                  
                  -- Mark restore as completed after restore is done
                  vim.defer_fn(function()
                    restore_completed = true
                  end, 50) -- Short delay to let restore settle
                end
              end, 100)
            end)
          else
            -- No saved state, allow saving immediately
            restore_completed = true
          end
        else
          -- No state file, allow saving immediately  
          restore_completed = true
        end
      end
      
      local group = vim.api.nvim_create_augroup("SnacksExplorerCursor", { clear = true })
      
      -- Restore cursor when opening Snacks picker  
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "snacks_picker_list", "snacks_picker_input" },
        group = group,
        callback = function()
          restore_cursor()
          
          -- Save cursor periodically during use
          local save_timer = nil
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = function()
              if save_timer then
                vim.fn.timer_stop(save_timer)
              end
              save_timer = vim.fn.timer_start(500, save_cursor)
            end,
          })
        end,
      })
      
      -- Save on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = save_cursor,
      })
      
      -- Debug command
      vim.api.nvim_create_user_command("SnacksDebug", function()
        local state_file = get_state_file()
        print("📁 Project: " .. vim.fn.getcwd())
        print("💾 State file: " .. state_file)
        print("📊 Built-in history: ~/.local/share/nvim/snacks/picker_explorer.history")
        
        -- Show current state
        local file = io.open(state_file, "r")
        if file then
          local content = file:read("*a")
          file:close()
          print("✅ Cursor state: " .. content)
        else
          print("❌ No cursor state found")
        end
      end, {})
    end,
  }
}
