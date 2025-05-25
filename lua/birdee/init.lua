-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

string.relpath = function(str, sub, n)
    local result = {}
    n = type(sub) == "string" and n or sub
    if type(n) == "number" and n > 0 then
        for match in (str .. "."):gmatch("(.-)%.") do
            table.insert(result, match)
        end
        while n > 0 do
            table.remove(result)
            n = n - 1
        end
    else
        table.insert(result, str)
    end
    if type(sub) == "string" then
        table.insert(result, sub)
    end
    return #result == 1 and result[1] or table.concat(result, ".")
end
-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
local modname = ...
if nixCats('fennel') then
    require(modname:relpath 'fennel-init')
end
require('lze').register_handlers {
    require("nixCatsUtils.lzUtils").for_cat,
    require('lzextras').lsp,
}
require('lze').h.lsp.set_ft_fallback(require(modname:relpath 'utils').lsp_ft_fallback)
require('lze').load {
    { import = modname:relpath "plugins" },
    { import = modname:relpath "LSPs" },
    { import = modname:relpath "debug" },
    { import = modname:relpath "format" },
    { import = modname:relpath "lint" },
}
if nixCats('fennel') then
    require('fnlcfg')
end
