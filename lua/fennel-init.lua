-- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
local cfg = string.gmatch(package.config, "([^\n]+)")
local sep, psep, phold = cfg() or '/', cfg() or ';', cfg() or '?'
local cfg_dir = nixCats.configDir or vim.fn.stdpath("config")
local forms = {
    "%s"..sep.."%s"..sep..phold..".%s",
    "%s"..sep.."%s"..sep..phold..sep.."init.%s",
}
local FF = require("fnFinder")
local function getpath(base, ext, n, ep)
    local paths = {}
    for _, form in ipairs(forms) do
        table.insert(paths, form:format(base, ext, ext))
    end
    if ep and ep ~= "" then
        table.insert(paths, ep)
    end
    return FF.searchModule(n, table.concat(paths, psep))
end
FF.installFennel(nil, {
    search_opts = {
        path = function(n, ep) return getpath(cfg_dir, "fnl", n, ep) end,
        -- set_global = true
    }
})
-- local function bootstrap()
-- end
-- local function fennel_lazy_bootstrap(name)
--     local basename = name:gsub('%.', sep)
--     local paths = { basename..".fnl", basename..sep.."init.fnl", }
--     for _, path in ipairs(paths) do
--         path = fennel_path .. path
--         if vim.uv.fs_stat(path) then
--             local loaders = package.loaders or package.searchers
--             for i = #loaders, 1, -1 do
--                 if loaders[i] == fennel_lazy_bootstrap then
--                     table.remove(loaders, i)
--                 end
--             end
--             if not bootstrap() then
--                 return "cannot require fennel, so cannot load the fennel module '" .. name .. "'"
--             end
--             return function()
--                 package.loaded[name] = nil
--                 return require(name)
--             end
--         end
--     end
-- end
-- table.insert(package.loaders or package.searchers, fennel_lazy_bootstrap)
