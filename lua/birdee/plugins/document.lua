-- lua/birdee/plugins/document.lua
local MP = ...

return {
  -- Typst-preview.nvim - Preview typst documents
  {
    "typst-preview.nvim",
    for_cat = "typst",
    ft = "typst",
    after = function()
      require 'typst-preview'.setup {
        -- Setting this true will show the compilation status in the status line
        -- open_cmd = nil -- Command to open the previewed file (nil means using system default)
        -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
        -- debug = false -- Debug mode (reserved for development)
        -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
      }
    end,
    version = '0.3.*',
    build = function()
      require 'typst-preview'.update()
    end,
    cmd = { "TypstPreview", "TypstPreviewToggle" },
    keys = {
      {
        "<leader>tp",
        "<cmd>TypstPreview<cr>",
        desc = "📄 Typst Preview",
        ft = "typst"
      },
      {
        "<leader>tt",
        "<cmd>TypstPreviewToggle<cr>",
        desc = "📄 Toggle Typst Preview",
        ft = "typst"
      },
    },
  },

  -- Markdown-preview.nvim - Preview markdown files in browser
  {
    "markdown-preview.nvim",
    for_cat = "markdown",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreview<cr>",
        desc = "📝 Markdown Preview",
        ft = "markdown"
      },
      {
        "<leader>mt",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "📝 Toggle Markdown Preview",
        ft = "markdown"
      },
      {
        "<leader>ms",
        "<cmd>MarkdownPreviewStop<cr>",
        desc = "📝 Stop Markdown Preview",
        ft = "markdown"
      },
    },
  },

  -- Render-markdown.nvim - Render markdown in buffer
  {
    "render-markdown.nvim",
    for_cat = "markdown",
    ft = { "markdown" },
    on_require = { "render-markdown" },
    after = function()
      require('render-markdown').setup({
        -- Whether Markdown should be rendered by default or not
        enabled = true,
        -- Maximum file size (in MB) that this plugin will attempt to render
        -- Any file larger than this will effectively be ignored
        max_file_size = 1.5,
        -- Capture groups that get pulled from markdown
        markdown_query = [[
          (atx_heading [
              (atx_h1_marker)
              (atx_h2_marker)
              (atx_h3_marker)
              (atx_h4_marker)
              (atx_h5_marker)
              (atx_h6_marker)
          ] @heading)

          (thematic_break) @dash

          (fenced_code_block) @code

          [
              (list_marker_plus)
              (list_marker_minus)
              (list_marker_star)
          ] @list_marker

          (task_list_marker_unchecked) @checkbox_unchecked
          (task_list_marker_checked) @checkbox_checked

          (block_quote_marker) @quote_marker
          (block_quote) @quote

          [
              (link_destination)
              (uri_autolink)
          ] @link_destination

          [
              (link_label)
              (link_text)
              (image_description)
          ] @link_label

          (pipe_table) @table
          (pipe_table_header) @table_head
          (pipe_table_delimiter_row) @table_delim
          (pipe_table_row) @table_row
      ]],
        -- Capture groups that get pulled from inline markdown
        inline_query = [[
          (code_span) @code

          (shortcut_link) @callout

          [
              (emphasis)
              (strong_emphasis)
          ] @emphasis
      ]],
        -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
        -- Only intended to be used for plugin development / debugging
        log_level = 'error',
      })
    end,
    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "📝 Toggle Render Markdown",
        ft = "markdown"
      },
    },
  },

  -- Otter.nvim - Code completion in markdown/quarto
  {
    "otter.nvim",
    for_cat = "otter",
    ft = { "quarto", "markdown" },
    on_require = { "otter" },
    after = function()
      local otter = require 'otter'
      otter.setup {
        lsp = {
          hover = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
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
          -- the lsp will be executed.
          set_filetype = false,
          -- write <path>.otter.<embedded language extension> files
          -- to disk on save of main buffer.
          -- usefull for some linters that require actual files
          -- otter files are deleted on quit or main buffer close
          write_to_disk = false,
        },
        strip_wrapping_quote_characters = { '"', "'", "`" },
        -- otter may not work the way you expect when entire code blocks are indented (eg. in Org files)
        -- When true, otter handles these cases fully.
        handle_leading_whitespace = false,
        -- warning: experimental
        -- when true, otter will attempt to provide autocompletion
        -- this works by creating a separate buffer for each code chunk,
        -- code chunks with the same language will be put in the same buffer
        -- it should handle variables and function definitions, but there may be bugs
        -- sometimes the first completion attempt will not work
        completion = true,
      }
    end,
    keys = {
      {
        "<leader>oa",
        function() require("otter").activate() end,
        desc = "🦦 Activate Otter",
        ft = { "quarto", "markdown" }
      },
      {
        "<leader>od",
        function() require("otter").deactivate() end,
        desc = "🦦 Deactivate Otter", 
        ft = { "quarto", "markdown" }
      },
    },
  },

  -- Obsidian.nvim - Note management system
  {
    "obsidian-nvim",
    for_cat = "obsidian",
    ft = "markdown",
    cmd = {
      "ObsidianOpen",
      "ObsidianNew", 
      "ObsidianQuickSwitch",
      "ObsidianFollowLink",
      "ObsidianBacklinks",
      "ObsidianTags",
      "ObsidianToday",
      "ObsidianYesterday",
      "ObsidianTomorrow",
      "ObsidianDailies",
      "ObsidianTemplate",
      "ObsidianSearch",
      "ObsidianLink",
      "ObsidianLinkNew",
      "ObsidianLinks",
      "ObsidianExtractNote",
      "ObsidianWorkspace",
      "ObsidianPasteImg",
      "ObsidianRename",
      "ObsidianToggleCheckbox",
      "ObsidianNewFromTemplate",
    },
    keys = {
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>", desc = "🔍 Open/Switch Note", ft = "markdown" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "📝 New Note", ft = "markdown" },
      { "<leader>oN", "<cmd>ObsidianNewFromTemplate<cr>", desc = "📋 New Note from Template", ft = "markdown" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "🔎 Search Notes", ft = "markdown" },
      { "<leader>oS", "<cmd>ObsidianLinks<cr>", desc = "📎 Show All Links", ft = "markdown" },
      { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "📅 Today's Note", ft = "markdown" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "⏮️ Yesterday's Note", ft = "markdown" },
      { "<leader>oT", "<cmd>ObsidianTomorrow<cr>", desc = "⏭️ Tomorrow's Note", ft = "markdown" },
      { "<leader>od", "<cmd>ObsidianDailies<cr>", desc = "📆 Daily Notes", ft = "markdown" },
      { "<leader>ol", "<cmd>ObsidianLink<cr>", desc = "🔗 Insert Link", mode = {"n", "v"}, ft = "markdown" },
      { "<leader>oL", "<cmd>ObsidianLinkNew<cr>", desc = "📝 Link to New Note", mode = {"n", "v"}, ft = "markdown" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "🔗 Show Backlinks", ft = "markdown" },
      { "<leader>og", "<cmd>ObsidianTags<cr>", desc = "🏷️ Browse Tags", ft = "markdown" },
      { "<leader>oT", "<cmd>ObsidianTemplate<cr>", desc = "📄 Insert Template", ft = "markdown" },
      { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "✏️ Rename Note", ft = "markdown" },
      { "<leader>ox", "<cmd>ObsidianToggleCheckbox<cr>", desc = "☑️ Toggle Checkbox", ft = "markdown" },
      { "<leader>oe", "<cmd>ObsidianExtractNote<cr>", desc = "📤 Extract to New Note", mode = "v", ft = "markdown" },
      { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "🖼️ Paste Image", ft = "markdown" },
      { "<leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "🏢 Switch Workspace", ft = "markdown" },
      { "gf", "<cmd>ObsidianFollowLink<cr>", desc = "➡️ Follow Link", ft = "markdown" },
      { "<bs>", "<cmd>ObsidianBacklinks<cr>", desc = "⬅️ Show Backlinks", ft = "markdown" },
    },
    after = function()
      require("obsidian").setup({
        workspaces = {
          {
            name = "personal",
            path = vim.fn.expand("~/Documents/Obsidian/Personal"),
          },
          {
            name = "work", 
            path = vim.fn.expand("~/Documents/Obsidian/Work"),
          },
          {
            name = "notes",
            path = vim.fn.expand("~/Documents/Obsidian/Notes"),
          },
          {
            name = "vault",
            path = vim.fn.expand("~/vault"), -- Generic vault location
          },
        },

        -- Completion configuration for blink.cmp
        completion = {
          nvim_cmp = false, -- Disable nvim-cmp since we use blink.cmp
          min_chars = 1,
        },

        -- Picker configuration - use snacks.pick
        picker = {
          name = "snacks.pick",
          note_mappings = {
            new = "<C-n>",
            insert_link = "<C-l>",
          },
          tag_mappings = {
            tag_note = "<C-t>",
            insert_tag = "<C-g>",
          },
        },

        -- Daily notes configuration
        daily_notes = {
          folder = "dailies",
          date_format = "%Y-%m-%d",
          alias_format = "%B %-d, %Y",
          template = "daily-template.md",
        },

        -- Templates configuration  
        templates = {
          subdir = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          substitutions = {
            yesterday = function()
              return os.date("%Y-%m-%d", os.time() - 86400)
            end,
            today = function()
              return os.date("%Y-%m-%d")
            end,
            tomorrow = function()
              return os.date("%Y-%m-%d", os.time() + 86400)
            end,
            time24 = function()
              return os.date("%H:%M:%S")
            end,
            datetime = function()
              return os.date("%Y-%m-%d %H:%M:%S")
            end,
            year = function()
              return os.date("%Y")
            end,
            month = function()
              return os.date("%B")
            end,
            week = function()
              return os.date("%U")
            end,
            isoweek = function()
              return os.date("%V")
            end,
            title = function()
              return vim.fn.input("Title: ")
            end,
          },
        },

        -- Note ID generation
        note_id_func = function(title)
          -- Create note IDs from title
          if title ~= nil then
            return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            -- If no title, use timestamp
            return tostring(os.time())
          end
        end,

        -- Wiki links configuration
        wiki_link_func = "use_alias_only",

        -- Markdown link configuration
        markdown_link_func = function(opts)
          return string.format("[%s](%s)", opts.label, opts.path)
        end,

        -- Note frontmatter configuration
        note_frontmatter_func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,

        -- Checkbox configuration
        checkbox = {
          order = { " ", "x", ">", "~", "!" },
          char = {
            [" "] = "󰄱",
            ["x"] = "",
            [">"] = "",
            ["~"] = "󰰱",
            ["!"] = "",
          },
          color = {
            [" "] = "#f78c6c",
            ["x"] = "#89ddff",
            [">"] = "#f78c6c",
            ["~"] = "#ff5370",
            ["!"] = "#d73128",
          },
        },

        -- UI settings
        ui = {
          enable = true,
          update_debounce = 200,
          bullets = { char = "•", hl_group = "ObsidianBullet" },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          block_ids = { hl_group = "ObsidianBlockID" },
          hl_groups = {
            ObsidianTodo = { bold = true, fg = "#f78c6c" },
            ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianImportant = { bold = true, fg = "#d73128" },
            ObsidianBullet = { bold = true, fg = "#89ddff" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, fg = "#89ddff" },
            ObsidianBlockID = { italic = true, fg = "#89ddff" },
            ObsidianHighlightText = { bg = "#75662e" },
          },
        },

        -- Image handling
        attachments = {
          img_folder = "assets/imgs",
          img_text_func = function(client, path)
            path = client:vault_relative_path(path) or path
            return string.format("![%s](%s)", path.name, path)
          end,
        },

        -- Search configuration
        finder = "snacks.nvim",
        finder_mappings = {
          new = "<C-n>",
          insert_link = "<C-l>",
        },

        -- Sorting
        sort_by = "modified",
        sort_reversed = true,

        -- Open strategy
        open_notes_in = "current",

        -- Follow URL configuration  
        follow_url_func = function(url)
          vim.fn.jobstart({"open", url})
        end,
      })
      
      -- Auto-conceal settings for markdown files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.md",
        callback = function()
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc" -- Visual mode navigation friendly
        end,
      })
    end,
  },
}