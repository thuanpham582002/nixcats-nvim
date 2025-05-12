local M = {}
M.add_reprs = function (sh, ...)
    ---@cast sh Shelua
    sh = sh or require('sh')
    for _, v in ipairs({...}) do
      sh = require('shelua.repr.' .. v)(sh)
    end
    return sh
end
M.safe_add_reprs = function (sh, ...)
    ---@cast sh Shelua
    sh = sh or require('sh')
    for _, v in ipairs({...}) do
      if not getmetatable(sh).repr[v] then
        sh = require('shelua.repr.' .. v)(sh)
      end
    end
    return sh
end
return M
