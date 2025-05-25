-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
local modname = ...
local function relp(stub)
  return modname .. "." .. stub
end
if nixCats('fennel') then
    require(relp 'fennel-init')
end
require('lze').register_handlers {
    require("nixCatsUtils.lzUtils").for_cat,
    require('lzextras').lsp,
}
require('lze').h.lsp.set_ft_fallback(require(relp 'utils').lsp_ft_fallback)
require('lze').load {
  { import = relp "plugins" },
  { import = relp "LSPs" },
  { import = relp "debug" },
  { import = relp "format" },
  { import = relp "lint" },
}
if nixCats('fennel') then
    require('fnlcfg')
end
