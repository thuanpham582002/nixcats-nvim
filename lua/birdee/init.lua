-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
local MP = ...
require('lze').register_handlers {
    require("nixCatsUtils.lzUtils").for_cat,
    require('lzextras').lsp,
}
require('lze').h.lsp.set_ft_fallback(require(MP:relpath 'utils').lsp_ft_fallback)
require('lze').load {
    { import = MP:relpath "plugins" },
    { import = MP:relpath "LSPs" },
    { import = MP:relpath "debug" },
    { import = MP:relpath "format" },
    { import = MP:relpath "lint" },
}


-- Disable netrw to prevent conflicts
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Clipboard system integration
vim.opt.clipboard = "unnamedplus" -- Auto sync y/p with system clipboard

-- Load snacks keymaps after plugins
-- require('birdee.snacks-keymaps') -- Removed - keymaps now managed in snacks.lua
