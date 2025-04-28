local M = {}

local is_pre_5_2 = (function()
	local majorversion, minorversion = _VERSION:match("Lua (%d+).(%d+)")
	majorversion = tonumber(majorversion)
	if majorversion < 6 then
		if majorversion == 5 and tonumber(minorversion) < 2 then
			return true
		end
	end
	return false
end)()

-- converts key and it's argument to "-k" or "-k=v" or just ""
local function arg(k, a)
	if not a then return k end
	if type(a) == 'string' and #a > 0 then return k .. '=\'' .. a .. '\'' end
	if type(a) == 'number' then return k .. '=' .. tostring(a) end
	if type(a) == 'boolean' and a == true then return k end
	error("invalid argument type: '" .. type(a) .. "' of value: '" .. a .. "'")
end

-- converts nested tables into a flat list of arguments and concatenated input
local function flatten(t)
	local result = { args = {}, input = '' }

	local function f(t)
		local keys = {}
		for k = 1, #t do
			keys[k] = true
			local v = t[k]
			if type(v) == 'table' then
				f(v)
			else
				table.insert(result.args, v)
			end
		end
		for k, v in pairs(t) do
			if k == '__input' then
				result.input = result.input .. v
			elseif not keys[k] and k:sub(1, 1) ~= '_' then
				local key = '-' .. k
				if #k > 1 then key = '-' .. key end
				table.insert(result.args, arg(key, v))
			end
		end
	end

	f(t)
	return result
end

-- returns a function that executes the command with given args and returns its
-- output, exit status etc
local function command(cmd, ...)
	local prearg = { ... }
	return function(...)
		local args = flatten({ ... })
		local s = cmd
		for _, v in ipairs(prearg) do
			s = s .. ' ' .. v
		end
		for _, v in pairs(args.args) do
			s = s .. ' ' .. v
		end

		if args.input then
			local f = io.open(M.luash_tmpfile, 'w')
			if f then
				f:write(args.input)
				f:close()
				s = s .. ' <' .. M.luash_tmpfile
			end
		end
		local t = {}
		if is_pre_5_2 then
			local p = io.popen(s .. "; echo __EXITCODE__$?;", 'r')
			local output = ""
			if p then
				output = p:read('*a')
				p:close()
			end
			os.remove(M.luash_tmpfile)
			local exit
			output = output:gsub("__EXITCODE__(%d*)\n?$", function(code)
				exit = tonumber(code)
				return ""
			end)
			t = {
				__input = output,
				__exitcode = exit or 127,
				__signal = (exit and exit > 128) and (exit - 128) or 0
			}
		else
			local p = io.popen(s, 'r')
			local output, exit, status
			if p then
				output = p:read('*a')
				_, exit, status = p:close()
			end
			os.remove(M.luash_tmpfile)

			t = {
				__input = output,
				__exitcode = exit == 'exit' and status or 127,
				__signal = exit == 'signal' and status or 0,
			}
		end
		local mt = {
			__index = function(self, k, ...)
				return M[k] --, ...
			end,
			__tostring = function(self)
				-- return trimmed command output as a string
				return self.__input:match('^%s*(.-)%s*$')
			end
		}
		return setmetatable(t, mt)
	end
end

-- export command() function and configurable temporary "input" file
M.luash_tmpfile = '/tmp/shluainput'

return setmetatable(M, {
	-- set hook for undefined variables
	__index = function(_, cmd)
		return command(cmd)
	end,
	-- allow to call sh to run shell commands
	__call = function(_, cmd, ...)
		return command(cmd, ...)
	end,
})
