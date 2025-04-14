return {
  {
    "luasnip",
    dep_of = { "blink.cmp" },
    after = function (_)
      require('birdee.snippets')
    end,
  },
  {
    "blink.cmp",
    event = "DeferredUIEnter",
    on_require = "blink",
    after = function (plugin)
      require("blink.cmp").setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = nixCats('tabCompletionKeys') and { preset = 'super-tab' } or {
          preset = 'none',
          ['<M-c>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<M-h>'] = { 'hide' },
          ['<M-l>'] = { 'select_and_accept' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<M-k>'] = { 'select_prev', 'fallback_to_mappings' },
          ['<M-j>'] = { 'select_next', 'fallback_to_mappings' },
          ['<C-p>'] = { 'scroll_documentation_up', 'fallback' },
          ['<C-n>'] = { 'scroll_documentation_down', 'fallback' },
          ['<Tab>'] = { 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
          ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          keymap = {
            preset = nixCats('tabCompletionKeys') and 'cmdline' or 'inherit'
          },
        },
        term = {
          enabled = true,
          keymap = { preset = 'inherit' },
        },
        fuzzy = {
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        appearance = {
          nerd_font_variant = 'mono'
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              columns = {
                { "label", "label_description", gap = 1 }, { "kind" }
              },
              treesitter = { 'lsp' },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        snippets = {
          preset = 'luasnip',
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            snippets = {
              score_offset = 40,
            },
            minuet = {
              name = 'minuet',
              module = 'minuet.blink',
              async = true,
              -- Should match minuet.config.request_timeout * 1000,
              -- since minuet.config.request_timeout is in seconds
              timeout_ms = 3000,
              score_offset = 50, -- Gives minuet higher priority among suggestions
            },
          },
        },
      })
    end,
  },
}
