inputs: let
  inherit (inputs.nixCats) utils;
in { pkgs, settings, categories, name, extra, mkPlugin, ... }@packageDef: {

  extraCats = {
    kotlin = [
      [ "java" ]
    ];
    AI = [
      [ "AI" "default" ]
    ];
  };

  environmentVariables = {
    test = {
      BIRDTVAR = "It worked!";
    };
  };
  sharedLibraries = {};
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
  extraWrapperArgs = {};

  # python.withPackages or lua.withPackages
  # vim.g.python3_host_prog
  # :!nvim-python3
  python3.libraries = {
    python = (py:[
      # NOTE: check disabled globally for nvim because they take SO LONG OMG
      (py.debugpy.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (py.pylsp-mypy.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (py.pyls-isort.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      # py.python-lsp-server
      # py.python-lsp-black
      (py.pytest.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      # py.pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
      # py.google-generativeai
    ]);
  };

  # populates $LUA_PATH and $LUA_CPATH
  extraLuaPackages = {
    fennel = [ (lp: with lp; [ fennel ]) ];
  };

  lspsAndRuntimeDeps = with pkgs; {
    portableExtras = [
      xclip
      wl-clipboard
      git
      nix
      coreutils-full
      curl
    ];
    markdown = [
      (pkgs.stdenvNoCC.mkDerivation {
        pname = "marksman";
        version = "2024-12-18";
        src = pkgs.fetchurl {
          url = "https://github.com/artempyanykh/marksman/releases/download/2024-12-18/marksman-macos";
          hash = "sha256-fhiAOWYjGjPuEH0NJvabQfLw3BMyxS3ZcpwuKft3voM=";
        };
        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/marksman
          chmod +x $out/bin/marksman
        '';
      })
      python311Packages.pylatexenc
      harper
    ];
    fennel = [
      fnlfmt
      fennel-ls
    ];
    general = {
      core = [
        universal-ctags
        ripgrep
        fd
        ast-grep
        lazygit
      ];
    };
    AI = {
      default = [
        # bitwarden-cli  # Disabled due to broken package
      ];
      opencode = [
        opencode
      ];
    };
    java = [
      jdt-language-server
    ];
    zig = [
      zls
      zig
      zig-shell-completions
    ];
    kotlin = [
      # kotlin-lsp
      kotlin-language-server
      ktlint
    ];
    go = [
      gopls
      delve
      golint
      golangci-lint
      gotools
      go-tools
      go
    ];
    elixir = [
      elixir-ls
    ];
    web = {
      templ = with inputs; [
        templ.packages.${system}.templ
      ];
      tailwindcss = [
        tailwindcss-language-server
      ];
      HTMX = [
        htmx-lsp
      ];
      HTML = [
        vscode-langservers-extracted
      ];
      JS = with nodePackages; [
        typescript-language-server
        eslint
        prettier
      ];
    };
    rust = [
      (extra.rust.toolchain or inputs.fenix.packages.${system}.latest.toolchain)
      rustup
      llvmPackages.bintools
      lldb
    ];
    lua = [
      lua-language-server
    ];
    typst = [
      typst
      typst-live
      tinymist
      websocat
    ];
    nix = [
      nix-doc
      nil
      nixd
      nixfmt-rfc-style
    ];
    neonixdev = [
      nix-doc
      nil
      lua-language-server
      nixd
      nixfmt-rfc-style
    ];
    vimagePreview = [
      imagemagick
      ueberzugpp
    ];
    bash = [
      nodePackages.bash-language-server
    ];
    python = with python311Packages; [
      # jedi-language-server
      (python-lsp-server.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (debugpy.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      (pytest.overrideAttrs {
        doCheck = false;
        doInstallCheck = false;
        pytestCheckPhase = "";
        installCheckPhase = "";
      })
      # pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
    ];
    C = [
      clang-tools
      # valgrind  # Disabled due to broken package on macOS
      cmake-language-server
      cpplint
      cmake
      cmake-format
    ];
    SQL = [
    ];
  };

  startupPlugins = with pkgs.vimPlugins; {
    theme = builtins.getAttr (extra.colorscheme or "onedark") {
      "onedark" = onedark-nvim;
      "catppuccin" = catppuccin-nvim;
      "catppuccin-mocha" = catppuccin-nvim;
      "tokyonight" = tokyonight-nvim;
      "tokyonight-day" = tokyonight-nvim;
    };
    general = [
      pkgs.neovimPlugins.lze
      pkgs.neovimPlugins.lzextras
      smart-splits-nvim  # Force load for tmux integration
      vim-repeat
      pkgs.neovimPlugins.nvim-luaref
      nvim-nio
      nui-nvim
      nvim-web-devicons
      plenary-nvim
      mini-nvim
      pkgs.neovimPlugins.snacks-nvim
      nvim-ts-autotag
    ];
    other = [
      nvim-spectre
      pkgs.neovimPlugins.shelua
      # (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (p: { installQueries = true; })))
    ];
    lua = [
      luvit-meta
    ];
    fennel = [
      pkgs.neovimPlugins.fn_finder
    ];
    rust = [
      pkgs.neovimPlugins.rustaceanvim
    ];
    neonixdev = [
      luvit-meta
    ];
  };

  optionalPlugins = with pkgs.vimPlugins; {
    SQL = [
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];
    vimagePreview = [
      image-nvim
    ];
    C = [
      vim-cmake
      clangd_extensions-nvim
    ];
    python = [
      nvim-dap-python
    ];
    otter = [
      otter-nvim
    ];
    go = [
      nvim-dap-go
    ];
    fennel = [
      conjure
      cmp-conjure
    ];
    java = [
      nvim-jdtls
    ];
    typst = [
      typst-preview-nvim
    ];
    neonixdev = [
      lazydev-nvim
    ];
    AI = {
      companion = [
        codecompanion-nvim
      ];
      minuet = [
        minuet-ai-nvim
      ];
      opencode = [
        pkgs.neovimPlugins.opencode-nvim
      ];
      windsurf = [
        windsurf-nvim
      ];
      claudecode = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "claudecode.nvim";
          version = "2024-12-19";
          src = pkgs.fetchFromGitHub {
            owner = "coder";
            repo = "claudecode.nvim";
            rev = "main";
            hash = "sha256-XYmf1RQ2bVK6spINZW4rg6OQQ5CWWcR0Tw4QX8ZDjgs=";
          };
          meta = {
            description = "Claude Code integration for Neovim";
            homepage = "https://github.com/coder/claudecode.nvim";
          };
        })
      ];
    };
    obsidian = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "obsidian-nvim";
        version = "2025-01-01";
        src = pkgs.fetchFromGitHub {
          owner = "obsidian-nvim";
          repo = "obsidian.nvim";
          rev = "1a1a475846a4cfa3cfedde1c59141d99b6212951";
          hash = "sha256-b337e6220d57039d9eae9ec0eb0d104fcbf9946abe611861462d4a1bb9636cac";
        };
        meta = {
          description = "Obsidian.md integration for Neovim";
          homepage = "https://github.com/obsidian-nvim/obsidian.nvim";
        };
      })
    ];
    debug = [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ];
    other = [
      img-clip-nvim
      nvim-highlight-colors
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      pkgs.neovimPlugins.hlargs
      pkgs.neovimPlugins.visual-whitespace
      noice-nvim
      edgy-nvim
      persistence-nvim
    ];
    markdown = [
      render-markdown-nvim
      markdown-preview-nvim
      # obsidian-nvim  # TEMPORARILY DISABLED - Build fails due to missing fzf dependency
    ];
    general = with pkgs.neovimPlugins; {
      blink = with pkgs.vimPlugins; [
        luasnip
        cmp-cmdline
        blink-cmp
        blink-compat
        colorful-menu-nvim
      ];
      core = [
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        vim-rhubarb
        vim-fugitive
        diffview-nvim
        lspsaga-nvim
        pkgs.neovimPlugins.nvim-lspconfig
        lualine-lsp-progress
        lualine-nvim
        gitsigns-nvim
        grapple-nvim
        # marks-nvim
        nvim-lint
        conform-nvim
        undotree
        nvim-surround
        treesj
        dial-nvim
        vim-sleuth
      ];
    };
  };
}
