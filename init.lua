vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.loader.enable()
vim.o.exrc = true
require('nixCatsUtils').setup { non_nix_value = true }
if vim.g.vscode == nil then
  require('birdee')
end
