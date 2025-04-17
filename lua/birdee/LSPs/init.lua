local catUtils = require('nixCatsUtils')
if catUtils.isNixCats and nixCats('lspDebugMode') then
  vim.lsp.set_log_level("debug")
end
require('lze').h.lsp.set_ft_fallback(function(name)
  vim.api.nvim_create_user_command("LspGetFiletypesToClipboard",function(opts)
    local sname = opts.fargs[1] or vim.fn.getreg("+")
    vim.fn.setreg("+",
      "filetypes = "
      .. vim.inspect(dofile(nixCats.pawsible("allPlugins.opt.nvim-lspconfig") .. "/lsp/" .. sname .. ".lua").filetypes)
      .. ","
    )
  end, { nargs = '?' })
  error(name .. " not provided filetype")
  return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes or {}
end)
return {
  {
    "mason.nvim",
    enabled = not catUtils.isNixCats,
    on_plugin = { "nvim-lspconfig" },
    load = function(name)
      require('lzextras').loaders.multi { name, "mason-lspconfig.nvim" }
      require('mason').setup()
      require('mason-lspconfig').setup { automatic_installation = true, }
    end,
  },
  {
    "nvim-lspconfig",
    for_cat = "general.core",
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
    before = function(_)
      vim.lsp.config('*', {
        on_attach = require('birdee.LSPs.on_attach'),
      })
    end,
  },
  { import = "birdee.LSPs.web", },
  { import = "birdee.LSPs.nixlua", },
  {
    "clangd_extensions.nvim",
    for_cat = 'C',
    dep_of = { "nvim-lspconfig", "blink.cmp", },
  },
  {
    "cmake",
    for_cat = "C",
    lsp = {
      filetypes = { "cmake" },
    },
  },
  {
    "clangd",
    for_cat = "C",
    lsp = {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      -- unneded thanks to clangd_extensions-nvim I think
      -- settings = {
      --   clangd_config = {
      --     init_options = {
      --       compilationDatabasePath="./build",
      --     },
      --   }
      -- }
    },
  },
  {
    "vim-cmake",
    for_cat = "C",
    ft = { "cmake" },
    cmd = {
      "CMakeGenerate", "CMakeClean", "CMakeBuild", "CMakeInstall",
      "CMakeRun", "CMakeTest", "CMakeSwitch", "CMakeOpen", "CMakeClose",
      "CMakeToggle", "CMakeCloseOverlay", "CMakeStop",
    },
    after = function(_)
      vim.api.nvim_create_user_command('BirdeeCMake', [[:CMake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .<CR>]],
        { desc = 'Run CMake with compile_commands.json' })
      vim.cmd [[let g:cmake_link_compile_commands = 1]]
    end,
  },
  {
    "gopls",
    for_cat = "go",
    lsp = {
      filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", },
    },
  },
  {
    "elixirls",
    for_cat = "elixir",
    lsp = {
      filetypes = { "elixir", "eelixir", "heex", "surface" },
      cmd = { "elixir-ls" },
    }
  },
  {
    "jdtls",
    for_cat = 'java',
    lsp = {
      filetypes = { 'java', 'kotlin' },
    }
  },
  {
    "gradle_ls",
    enabled = nixCats('java') or nixCats('kotlin') or false,
    lsp = {
      filetypes = { "kotlin", "java" },
      root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
      cmd = { nixCats.extra("javaExtras.gradle-ls") .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" },
    }
  },
  {
    "bashls",
    for_cat = "bash",
    lsp = {
      filetypes = { "bash", "sh" },
    },
  },
  -- {"pyright", lsp = {}, },
  {
    "pylsp",
    for_cat = "python",
    lsp = {
      filetypes = { "python" },
      settings = {
        pylsp = {
          plugins = {
            -- formatter options
            black = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            -- linter options
            pylint = { enabled = true, executable = "pylint" },
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            -- type checker
            pylsp_mypy = { enabled = true },
            -- auto-completion options
            jedi_completion = { fuzzy = true },
            -- import sorting
            pyls_isort = { enabled = true },
          },
        },
      },
    }
  },
  {
    "marksman",
    for_cat = "markdown",
    lsp = {
      filetypes = { "markdown", "markdown.mdx" },
    },
  },
  {
    "harper_ls",
    for_cat = "markdown",
    lsp = {
      filetypes = { "markdown", "norg" },
      settings = {
        ["harper-ls"] = {},
      },
    },
  },
  {
    "kotlin_language_server",
    for_cat = 'kotlin',
    lsp = {
      filetypes = { 'kotlin' },
      -- root_pattern = {"settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw'},
      settings = {
        kotlin = {
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          workspace = { checkThirdParty = true },
          telemetry = { enabled = false },
        },
      },
    }
  },
}
