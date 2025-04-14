local load_w_after = require("lzextras").loaders.with_after
return {
  {
    "cmp-cmdline",
    on_plugin = { "blink.cmp" },
    load = load_w_after,
  },
  {
    "blink.compat",
    dep_of = { "cmp-cmdline" },
  },
  {
    "luasnip",
    dep_of = { "blink.cmp" },
    after = function (_)
      require('birdee.snippets')
    end,
  },
  {
    "colorful-menu.nvim",
    on_plugin = { "blink.cmp" },
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
          sources = function()
            local type = vim.fn.getcmdtype()
            -- Search forward and backward
            if type == '/' or type == '?' then return { 'buffer' } end
            -- Commands
            if type == ':' or type == '@' then return { 'cmdline', 'cmp_cmdline' } end
            return {}
          end,
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
                { "label", "label_description", gap = 1 }, { "kind", "source_id" }
              },
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end,
                },
              },
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
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
          },
        },
      })
    end,
  },
}
