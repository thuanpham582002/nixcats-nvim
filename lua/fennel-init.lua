local FF = require("fn_finder")
local sep, psep, phold = FF.pkgConfig.dirsep, FF.pkgConfig.pathsep, FF.pkgConfig.pathmark
local cfg_dir = nixCats.configDir or vim.fn.stdpath("config")
FF.fnl.install({
    search_opts = {
        path = function(n, ep)
            local paths = {
                cfg_dir..sep.."fnl"..sep..phold..".fnl",
                cfg_dir..sep.."fnl"..sep..phold..sep.."init.fnl",
            }
            if ep and ep ~= "" then
                table.insert(paths, ep)
            end
            return FF.searchModule(n, table.concat(paths, psep))
        end,
        macro_path = function(ep)
            local macro_paths = {
                cfg_dir..sep.."fnl"..sep..phold..".fnl",
                cfg_dir..sep.."fnl"..sep..phold..sep.."init.fnl",
                cfg_dir..sep.."fnl"..sep..phold..sep.."init-macros.fnl",
            }
            if ep and ep ~= "" then
                table.insert(macro_paths, ep)
            end
            return table.concat(macro_paths, psep)
        end,
        -- set_global = true
    },
    cache_opts = {
        cache_dir = vim.fn.stdpath("cache")..sep.."fnFinderCache",
    },
})
-- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
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
