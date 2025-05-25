-- TODO: this in another file and require here.
-- require('birdee.non_nix_download').setup({ your plugins })

-- vim.g.lze = {
--   load = vim.cmd.packadd,
--   verbose = true,
--   default_priority = 50,
--   without_default_handlers = false,
-- }
if nixCats('fennel') then
    -- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
    local ok, fennel = pcall(require, 'fennel')
    if ok then
        _G.fennel = fennel
        fennel.install()
        table.insert(package.loaders or package.searchers, function(name)
            local sep = package.config:sub(1, 1)
            local basename = name:gsub('%.', sep)
            local paths = {
                "fnl" .. sep .. basename .. ".fnl",
                "fnl" .. sep .. basename .. sep .. "init.fnl",
            }
            for _, path in ipairs(paths) do
                local found = vim.api.nvim_get_runtime_file(path, false)
                if #found > 0 then
                    return function()
                        return fennel.dofile(found[1])
                    end
                end
            end
        end)
    end
end
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
if fennel then
    require('fnlcfg')
end
