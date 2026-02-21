-- lua/birdee/plugins/go.lua
local MP = ...

return {
  {
    "fatih/vim-go",
    for_cat = "go",
    ft = "go",
    after = function()
      -- Disable default keymaps that conflict with lspsaga
      vim.g.go_def_mapping_enabled = 0
      vim.g.go_doc_mapping_enabled = 0
      vim.g.go_implements_mapping_enabled = 0
      vim.g.go_guru_mapping_enabled = 0
      vim.g.go_references_mapping_enabled = 0

      -- Setup commands
      require("go.lsp").setup()

      -- Optional: Add extra vim-go configuration here
      vim.g.go_fmt_command = "goimports"
      vim.g.go_term_enabled = 1
    end,
    cmd = {
      "GoRun",
      "GoBuild",
      "GoTest",
      "GoTestFunc",
      "GoCoverage",
      "GoLint",
      "GoVet",
      "GoModTidy",
      "GoImport",
      "GoRename",
    },
  },
}
