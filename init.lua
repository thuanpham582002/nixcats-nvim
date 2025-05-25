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
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.loader.enable()
vim.o.exrc = true
require('nixCatsUtils').setup { non_nix_value = true }
if vim.g.vscode == nil then
    if nixCats('fennel') then
        -- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
        local ok, fennel = pcall(require, 'fennel')
        if ok then
            _G.fennel = fennel
            fennel.install()
            local sep = package.config:sub(1, 1)
            local fennel_path = nixCats.configDir .. sep .. "fnl" .. sep
            local form = "%s?.fnl;%s?" .. sep .. "init.fnl;%s"
            fennel.path = form:format(fennel_path, fennel_path, fennel.path)
            fennel["macro-path"] = form:format(fennel_path, fennel_path, fennel["macro-path"])
        end
    end
    require('birdee')
end
