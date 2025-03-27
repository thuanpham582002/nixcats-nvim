if vim.g.vscode ~= nil or not nixCats('otter') then
  return
end
-- currently disabled because I found it annoying with all the bash errors
vim.schedule(function ()
  require('otter').activate(nil, true, true, nil)
end)
