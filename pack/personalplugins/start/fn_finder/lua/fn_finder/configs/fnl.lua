return function(MAIN)
    local M = {}

    local function read_file(filename)
        local ok, file = pcall(io.open, filename, "r")
        if ok and file then
            local content = file:read("*a")
            file:close()
            return content
        end
        return nil, "Could not read file '" .. tostring(filename) .. "'"
    end

    ---@class fn_finder.FennelSearchOpts
    ---@field path? string|fun(modname: string, existing: string):(modpath: string)
    ---@field on_first_search? fun(fennel: table, opts: fn_finder.FennelSearchOpts)
    ---@field compiler? table -- fennel compiler options

    ---@class fn_finder.FennelOpts : fn_finder.LoaderOpts
    ---@field search_opts? fn_finder.FennelSearchOpts

    ---@param loader_opts? fn_finder.FennelOpts
    ---@return fun(modname: string):function|string?
    M.mkFinder = function(loader_opts)
        loader_opts = loader_opts or {}
        local triggered = false
        local fennel = package.loaded["fennel"] or nil
        loader_opts.search = loader_opts.search
            or function(modname, opts)
                opts = opts or {}
                local pt = type(opts.path)
                local p = (fennel or {}).path or "./?.fnl;./?/init.fnl"
                local modpath
                if pt == "function" then
                    modpath = opts.path(modname, p)
                elseif pt == "string" then
                    modpath = MAIN.searchModule(modname, opts.path)
                else
                    modpath = MAIN.searchModule(modname, p)
                end
                if not triggered and modpath then
                    triggered = true
                    if type(fennel) == "table" and opts.on_first_search then
                        opts.on_first_search(fennel, opts)
                    else
                        local ok
                        ok, fennel = pcall(require, "fennel")
                        if not ok then
                            fennel = nil
                        elseif opts.on_first_search then
                            opts.on_first_search(fennel, opts)
                        end
                    end
                end
                if not modpath then
                    return nil, nil, "\n\tfn_finder fennel searcher could not find a fennel file for '" .. tostring(modname) .. "'"
                elseif not fennel then
                    return nil, nil, "\n\tfn_finder fennel searcher cannot require('fennel')"
                end
                opts.compiler = opts.compiler or {}
                opts.compiler.filename = modpath
                local ok, lua_code = pcall(fennel.compileString, read_file(modpath), opts.compiler)
                if ok and lua_code then
                    return lua_code, modpath, nil
                else
                    return nil,
                        nil,
                        "\n\tfn_finder fennel search function could not find a valid fennel file for '"
                            .. tostring(modname)
                            .. "': "
                            .. tostring(lua_code or modpath)
                end
            end
        return MAIN.mkFinder(loader_opts)
    end

    ---@overload fun(opts: fn_finder.FennelOpts)
    ---@overload fun(pos: number, opts: fn_finder.FennelOpts)
    M.install = function(pos, opts)
        if type(pos) == "number" then
            table.insert(package.loaders or package.searchers, pos, M.mkFinder(opts or {}))
        else
            table.insert(package.loaders or package.searchers, M.mkFinder(pos or opts or {}))
        end
    end

    return M
end
