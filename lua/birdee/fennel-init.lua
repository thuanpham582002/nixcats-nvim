-- Source: https://neovim.discourse.group/t/how-to-use-fennel-in-runtime-scripts-without-compiling-to-lua/147
local status, fennel = pcall(require, 'fennel')
if not status then
  return nil
end
local function _fennel_runtime_searcher(name)
  local basename = name:gsub('%.', '/')
  local paths = {
    "fnl/"..basename..".fnl",
    "fnl/"..basename.."/init.fnl",
  }
  for _,path in ipairs(paths) do
    local found = vim.api.nvim_get_runtime_file(path, false)
    if #found > 0 then
      return function()
        return fennel.dofile(found[1])
      end
    end
  end
end
table.insert(package.loaders or package.searchers, fennel.searcher)
table.insert(package.loaders or package.searchers, _fennel_runtime_searcher)

return fennel
