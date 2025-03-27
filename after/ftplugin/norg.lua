if vim.g.vscode ~= nil or not nixCats('otter') then
  return
end
vim.schedule(function ()
  require('otter').activate(nil, true, true, nil)
end)
