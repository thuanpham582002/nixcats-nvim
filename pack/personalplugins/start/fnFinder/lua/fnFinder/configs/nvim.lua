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

    ---@param loader_opts? table
    ---@return fun(modname: string):function|string?
    M.mkFinder = function(loader_opts)
        loader_opts = loader_opts or {}
        loader_opts.search = loader_opts.search or function(modname, opts)
        end
        return MAIN.mkFinder(loader_opts)
    end
    return M
end
