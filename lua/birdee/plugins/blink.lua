return {
  {
    "blink.cmp",
    enabled = nixCats('blink') or false,
    event = "DeferredUIEnter",
    on_require = "blink",
    after = function (plugin)
      require("blink.cmp").setup({
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- See :h blink-cmp-config-keymap for configuring keymaps
        keymap = { preset = 'default' },
        appearance = {
          nerd_font_variant = 'mono'
        },
        signature = {
          enabled = true,
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
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
        },
      })
    end,
  },
}
