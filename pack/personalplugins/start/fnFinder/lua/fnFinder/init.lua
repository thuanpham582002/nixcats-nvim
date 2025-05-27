local M

if load == nil then -- 5.1 compat
    function load(chunk, chunkname, mode, env)
        local f, err = loadstring(chunk, chunkname)
        if not f then return nil, err end
        if env then setfenv(f, env) end
        return f
    end
end

local function get_file_meta(modpath, meta)
    local uv = (vim or {}).uv or (vim or {}).loop
    if not uv then
        local ok, err = pcall(require, "luv")
        if ok then uv = err end
    end
    local err = nil
    if uv then
        local stat
        stat, err = uv.fs_stat(modpath)
        if stat then
            meta.mtime = stat.mtime.sec
            meta.mtime = stat.ctime.sec
            meta.size = stat.size
        end
    else
        local ok, lfs = pcall(require, "lfs")
        if ok then
            meta.mtime, err = lfs.attributes(modpath, "modification")
            meta.ctime, err = lfs.attributes(modpath, "change")
            meta.ctime, err = lfs.attributes(modpath, "size")
        else
            err = "fnFinder requires uv or lfs"
        end
    end
    return err
end

local function simple_table_hash(input)
    local ok_types = {
        number = true, string = true, boolean = true, ["nil"] = true,
    }
    local visited = {}
    local cerealize -- hehe... ignore the breakfast pun, this hash is only lightly scrambled
    local function valstr(v)
        local t = type(v)
        if ok_types[t] then
            return tostring(v)
        elseif t == "table" then
            if visited[v] then
                return visited[v]
            else
                local val = cerealize(v)
                visited[v] = val
                return val
            end
        else
            return t -- type name if non-deterministic
        end
    end
    cerealize = function(tbl)
        local keys = {}
        for k in pairs(tbl) do table.insert(keys, k) end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        local acc = ""
        for _, k in ipairs(keys) do
            acc = acc .. valstr(k) .. "=" .. valstr(tbl[k]) .. ","
        end
        return acc
    end
    local res = cerealize(input)
    local hash = 0
    for i = 1, #res do
        hash = (hash * 31 + res:byte(i)) % 2 ^ 32
    end
    return hash
end

-- have searchModule use package.config to process package.path (windows compat)
local cfg = string.gmatch(package.config, "([^\n]+)")
local dirsep, pathsep, pathmark = cfg() or '/', cfg() or ';', cfg() or '?'
local pkgConfig = { dirsep = dirsep, pathsep = pathsep, pathmark = pathmark }

-- Escape a string for safe use in a Lua pattern
local function escapepat(str)
    return string.gsub(str, "[^%w]", "%%%1")
end

function M.searchModule(modulename, pathstring)
    local pathsepesc = escapepat(pkgConfig.pathsep)
    local pathsplit = string.format("([^%s]*)%s", pathsepesc, pathsepesc)
    local nodotModule = modulename:gsub("%.", pkgConfig.dirsep)
    for path in string.gmatch(pathstring .. pkgConfig.pathsep, pathsplit) do
        local filename = path:gsub(escapepat(pkgConfig.pathmark), nodotModule)
        local filename2 = path:gsub(escapepat(pkgConfig.pathmark), modulename)
        local file = io.open(filename) or io.open(filename2)
        if file then
            file:close()
            return filename
        end
    end
end

local function read_file(filename)
    local ok, file = pcall(io.open, filename, "r")
    if ok and file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return nil, file
end

---@param modname string
---@param cache_opts table
---@return nil|string|fun():string? chunk
---@return fnFinder.Meta?
local default_fetch = function(modname, cache_opts)
    --TODO: get bytecode and meta from file for default implementation
end

---@param chunk string
---@param meta fnFinder.Meta
---@param cache_opts table
local function cache_chunk(chunk, meta, cache_opts)
    -- TODO: save bytecode, and meta to file for default implementation
end

---@class fnFinder.Meta
---@field modname string
---@field modpath string
---@field mtime number
---@field ctime number
---@field size number
---@field opts_hash number

local function meta_eq(m1, m2)
    return m1.modpath == m2.modpath and m1.modname == m2.modname and m1.mtime == m2.mtime
        and m1.ctime == m2.ctime and m1.size == m2.size
        and m1.opts_hash == m2.opts_hash
end

---@param modname string
---@param opts_hash number
---@param loader_opts fnFinder.LoaderOpts
---@return nil|string|fun():string? chunk
---@return string? modpath
local function fetch_cached(modname, opts_hash, loader_opts)
    local chunk, meta = (loader_opts.get_cached or default_fetch)(modname, loader_opts.cache_opts or {})
    if not chunk or not meta then
        return nil, nil
    end
    if loader_opts.auto_invalidate then
        local m2 = {}
        get_file_meta(meta.modpath, m2)
        if meta_eq(meta, m2) then
            return chunk, meta.modpath
        end
    else
        if opts_hash == meta.opts_hash and meta.modpath then
            return chunk, meta.modpath
        end
    end
    return nil, nil
end

---@class fnFinder.LoaderOpts
---@field search_opts? table
---@field cache_opts? table
---@field get_cached? fun(modname: string, cache_opts: table):nil|string|fun():string?, fnFinder.Meta
---@field cache_chunk? fun(chunk: string, meta: fnFinder.Meta, cache_opts: table)
---@field search_path? string|fun(n: string, lang_opts: table):string
---@field strip? boolean
---@field env? table
---@field auto_invalidate? boolean

---@param loader_opts? table
---@return fun(modname: string):function|string
M.mkFinder = function(loader_opts)
    loader_opts = loader_opts or {}
    loader_opts.auto_invalidate = loader_opts.auto_invalidate ~= false
    local opts_hash = simple_table_hash {
        VERSION = _VERSION,
        loader_opts = loader_opts,
    }
    return function(modname)
        local chunk, modpath, err = fetch_cached(modname, opts_hash, loader_opts)
        local mkmsg = function(n, e)
            return "\n\tModule not found: '" .. n .. "'" .. (e and (" " .. tostring(e)) or "")
        end
        if modpath and chunk then
            chunk, err = load(chunk, "@" .. modpath, "b", loader_opts.env)
            return chunk or mkmsg(modname, err)
        else
            local spath = loader_opts.search_path or package.path
            if type(spath) == "function" then
                chunk, modpath, err = spath(modname, loader_opts.search_opts or {})
            else
                modpath = M.searchModule(modname, spath)
                chunk, err = read_file(modpath)
            end
            if modpath and chunk then
                chunk = load(chunk, "@" .. modpath, "t", loader_opts.env)
                if chunk then
                    ---@type fnFinder.Meta
                    local meta = {
                        opts_hash = opts_hash,
                        modname = modname,
                        modpath = modpath,
                    }
                    if get_file_meta(modpath, meta) then
                        local compiled = string.dump(chunk, loader_opts.strip)
                        local cacher = loader_opts.cache_chunk or cache_chunk
                        cacher(compiled, meta, loader_opts.cache_opts or {})
                    end
                    return chunk
                end
            end
        end
        return mkmsg(modname, err)
    end
end

local function fennel_search(modname, opts)
    local ok, fennel = pcall(require, "fennel")
    if ok and fennel then
        local modpath = M.searchModule(modname, fennel.path)
        local lua_code
        ok, lua_code = pcall(fennel.compile, modpath, opts or {})
        if ok then
            return lua_code, modpath, nil
        else
            return nil, nil, "\n\tfnlFinder could not find a valid fennel file for '" .. modname .. "': " .. tostring(lua_code or modpath)
        end
    end
    return nil, nil, "\n\tfnlFinder cannot require('fennel')"
end

M.fnlFinder = function(loader_opts)
    loader_opts = loader_opts or {}
    loader_opts.search_path = loader_opts.search_path or fennel_search
    return M.mkFinder(loader_opts)
end

return M
