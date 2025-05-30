return function(MAIN)
    local M = {}

    local function read_file(filename)
        local ok, file = pcall(io.open, filename, "r")
        if ok and file then
            local content = file:read("*a")
            file:close()
            return content
        end
        return nil, file
    end

    local function search_path(modname, opts)
        local ok, fennel = pcall(require, "fennel")
        opts = opts or {}
        if opts.set_global then
            _G.fennel = fennel
        end
        if ok and fennel then
            local pt = type(opts.path)
            local modpath
            if pt == "function" then modpath = opts.path(modname, fennel.path)
            elseif pt == "string" then modpath = MAIN.searchModule(modname, opts.path)
            else modpath = MAIN.searchModule(modname, fennel.path) end
            opts.filename = modpath
            local lua_code
            ok, lua_code = pcall(fennel.compileString, read_file(modpath), opts)
            if ok then
                return lua_code, modpath, nil
            else
                return nil, nil,
                    "\n\tfnlFinder could not find a valid fennel file for '" ..
                    modname .. "': " .. tostring(lua_code or modpath)
            end
        end
        return nil, nil, "\n\tfnlFinder cannot require('fennel')"
    end

    ---@param loader_opts? fnFinder.LoaderOpts
    ---@return fun(modname: string):function|string?
    M.finder = function(loader_opts)
        loader_opts = loader_opts or {}
        loader_opts.search_path = loader_opts.search_path or search_path
        return MAIN.mkFinder(loader_opts)
    end

    ---@overload fun(opts: fnFinder.LoaderOpts)
    ---@overload fun(pos: number, opts: fnFinder.LoaderOpts)
    M.install = function(pos, opts)
        if type(pos) == "number" then
            table.insert(package.loaders or package.searchers, pos, M.finder(opts or {}))
        else
            table.insert(package.loaders or package.searchers, M.finder(pos or opts or {}))
        end
    end

    return M
end
