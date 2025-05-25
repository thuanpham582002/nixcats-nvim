-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
if nixCats('fennel') then
    require(... .. '.fennel-init')
end
require('lze').register_handlers {
    require("nixCatsUtils.lzUtils").for_cat,
    require('lzextras').lsp,
}
require('lze').h.lsp.set_ft_fallback(require(... .. '.utils').lsp_ft_fallback)
require('lze').load {
  { import = ... .. ".plugins" },
  { import = ... .. ".LSPs" },
  { import = ... .. ".debug" },
  { import = ... .. ".format" },
  { import = ... .. ".lint" },
}
if nixCats('fennel') then
    require('fnlcfg')
end
