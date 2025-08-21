local catUtils = require('nixCatsUtils')
local get_nixd_opts = nixCats.extra("nixdExtras.get_configs")
return {
  {
    "lazydev.nvim",
    for_cat = "neonixdev",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "uv", "vim%.uv", "vim%.loop" }, path = (nixCats.pawsible({"allPlugins", "start", "luvit-meta"}) or "luvit-meta") .. "/library" },
          { words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  {
    "lua_ls",
    enabled = nixCats('lua') or nixCats('neonixdev'),
    lsp = {
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
            disable = { },
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
  },
  {
    "nixd",
    enabled = catUtils.isNixCats and (nixCats('nix') or nixCats('neonixdev')),
    after = function(_)
      vim.api.nvim_create_user_command("StartNilLSP", function()
        vim.lsp.start(vim.lsp.config.nil_ls)
      end, { desc = 'Run nil-ls (when you really need docs for the builtins and nixd refuse)' })
    end,
    lsp = {
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
  },
  {
    "rnix",
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nil_ls",
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
}
