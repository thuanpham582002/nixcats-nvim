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
}