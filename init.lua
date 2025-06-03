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

if not table.pack then
  table.pack = function(...)
    return { n = select("#", ...), ... }
  end
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.loader.enable()
vim.o.exrc = true
require('nixCatsUtils').setup { non_nix_value = true }
if vim.g.vscode == nil then
    if nixCats('fennel') then
        -- trivia: <c-k>*l is λ
        require("fn_finder").fnl.install { nixCats.packageBinPath, search_opts = { nvim = true }, }
    end
    require('birdee')
end
