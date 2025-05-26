-- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
local sep = package.config:sub(1, 1)
local config_dir = nixCats.configDir or vim.fn.stdpath("config") -- or is unnecessary because we called nixCatsUtils.setup but we have it here anyway
local fennel_path = config_dir..sep.."fnl"..sep
local function bootstrap()
    local ok, fennel = pcall(require, 'fennel')
    if not ok then return end
    _G.fennel = fennel
    local new_fpath = ("%s?.fnl;%s?"..sep.."init.fnl;"):format(fennel_path, fennel_path)
    fennel.path = new_fpath..fennel.path
    fennel["macro-path"] = new_fpath..fennel["macro-path"]
    fennel.install()
    return true
end
local function fennel_lazy_bootstrap(name)
    local basename = name:gsub('%.', sep)
    local paths = { basename..".fnl", basename..sep.."init.fnl", }
    for _, path in ipairs(paths) do
        path = fennel_path .. path
        if vim.uv.fs_stat(path) then
            local loaders = package.loaders or package.searchers
            for i = #loaders, 1, -1 do
                if loaders[i] == fennel_lazy_bootstrap then
                    table.remove(loaders, i)
                end
            end
            if not bootstrap() then
                return "cannot require fennel, so cannot load the fennel module '" .. name .. "'"
            end
            return function()
                package.loaded[name] = nil
                return require(name)
            end
        end
    end
end
table.insert(package.loaders or package.searchers, fennel_lazy_bootstrap)
