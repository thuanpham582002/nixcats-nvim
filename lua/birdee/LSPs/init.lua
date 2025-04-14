local catUtils = require('nixCatsUtils')
if catUtils.isNixCats and nixCats('lspDebugMode') then
  vim.lsp.set_log_level("debug")
end
local get_nixd_opts = nixCats.extra("nixdExtras.get_configs")
if nixCats('nvim-cmp') then
  local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  vim.lsp.config('*', {
    capabilities = capabilities,
  })
end
if nixCats('blink') then
  local capabilities = {}
  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
  })
end
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
  callback = function(event)
    require('birdee.LSPs.on_attach')(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
  end,
})
local servers = {
  lua_ls = {
    filetypes = { 'lua' },
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixCats", "vim", "make_test" },
          disable = { 'missing-fields' },
        },
        workspace = {
          checkThirdParty = false,
          library = {
            -- '${3rd}/luv/library',
            -- unpack(vim.api.nvim_get_runtime_file('', true)),
          },
        },
        completion = {
          callSnippet = 'Replace',
        },
        telemetry = { enabled = false },
      },
    },
  },
  nixd = {
    filetypes = { 'nix' },
    settings = {
      nixd = {
        nixpkgs = {
          -- ''import ${pkgs.path} {}''
          expr = nixCats.extra("nixdExtras.nixpkgs") or "import <nixpkgs> {}",
        },
        formatting = {
          command = { "nixfmt" }
        },
        options = {
          -- (builtins.getFlake "path:${builtins.toString <path_to_system_flake>}").legacyPackages.<system>.nixosConfigurations."<user@host>".options
          nixos = {
            expr = get_nixd_opts and get_nixd_opts("nixos", nixCats.extra("nixdExtras.flake-path"))
          },
          -- (builtins.getFlake "path:${builtins.toString <path_to_system_flake>}").legacyPackages.<system>.homeConfigurations."<user@host>".options
          ["home-manager"] = {
            expr = get_nixd_opts and get_nixd_opts("home-manager", nixCats.extra("nixdExtras.flake-path")) -- <-  if flake-path is nil it will be lsp root dir
          }
        },
        diagnostic = {
          suppress = {
            "sema-escaping-with"
          }
        }
      }
    },
  },
  elixirls = {
    filetypes = { "elixir", "eelixir", "heex", "surface" },
    cmd = { "elixir-ls" },
  },
  kotlin_language_server = {
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
  },
  jdtls = {
    filetypes = { 'java', 'kotlin' },
  },
  gradle_ls = {
    filetypes = { "kotlin", "java" },
    root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
    cmd = { nixCats.extra("javaExtras.gradle-ls") .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" },
  },
  bashls = {
    filetypes = { "bash", "sh" },
  },
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", },
  },
  pylsp = {
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
  },
  marksman = {
    filetypes = { "markdown", "markdown.mdx" },
  },
  harper_ls = {
    filetypes = { "markdown", "norg" },
    settings = {
      ["harper-ls"] = {},
    },
  },
  templ = {
    filetypes = { "templ" },
  },
  tailwindcss = {
  },
  ts_ls = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
  },
  clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    -- unneded thanks to clangd_extensions-nvim I think
    -- clangd_config = {
    --   init_options = {
    --     compilationDatabasePath="./build",
    --   },
    -- }
  },
  cmake = {
    filetypes = { "cmake" },
  },
  htmx = {
  },
  cssls = {
    filetypes = { "css", "scss", "less" },
  },
  eslint = {
  },
  jsonls = {
    filetypes = { "json", "jsonc" },
  },
  html = {
    filetypes = { 'html', 'twig', 'hbs', 'templ' },
    settings = {
      html = {
        format = {
          templating = true,
          wrapLineLength = 120,
          wrapAttributes = 'auto',
        },
        hover = {
          documentation = true,
          references = true,
        },
      },
    },
  },
}
local function enable_with_defaults(name, config)
  vim.lsp.config[name] = vim.tbl_extend("force", vim.lsp.config[name] or {}, config or {})
  vim.lsp.enable(name)
end
for name, config in pairs(servers) do
  enable_with_defaults(name, config)
end

-- NOTE: gets filetypes = {}, for server name in + register and puts it into the + register, overwriting server name.
-- :lua vim.fn.setreg([[+]],"filetypes = " .. vim.inspect(require('lspconfig.configs.' .. vim.fn.getreg("+")).default_config.filetypes) .. ",")
