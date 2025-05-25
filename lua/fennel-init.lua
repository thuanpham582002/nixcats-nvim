-- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
local sep = package.config:sub(1, 1)
local fennel_path = nixCats.configDir .. sep .. "fnl" .. sep
local form = "%s?.fnl;%s?" .. sep .. "init.fnl;%s"
local function _fennel_runtime_searcher(name)
    local basename = name:gsub('%.', sep)
    local paths = { basename..".fnl", basename..sep.."init.fnl", }
    for _, path in ipairs(paths) do
        path = fennel_path .. path
        if vim.fn.filereadable(path) == 1 then
            local ok, fennel = pcall(require, 'fennel')
            local loaders = package.loaders or package.searchers
            for i = #loaders, 1, -1 do
                if loaders[i] == _fennel_runtime_searcher then
                    table.remove(loaders, i)
                end
            end
            if not ok then return end
            _G.fennel = fennel
            fennel.path = form:format(fennel_path, fennel_path, fennel.path)
            fennel["macro-path"] = form:format(fennel_path, fennel_path, fennel["macro-path"])
            fennel.install()
            return function()
                package.loaded[name] = nil
                return require(name)
            end
        end
    end
end
table.insert(package.loaders or package.searchers, _fennel_runtime_searcher)
