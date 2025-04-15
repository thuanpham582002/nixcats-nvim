inputs: let
  inherit (inputs.nixCats) utils;
in { pkgs, settings, categories, name, extra, mkPlugin, ... }@packageDef: {

  extraCats = {
    kotlin = [
      [ "java" ]
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
      py.debugpy
      py.pylsp-mypy
      py.pyls-isort
      py.python-lsp-server
      # py.python-lsp-black
      py.pytest
      py.pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
    ]);
  };

  # populates $LUA_PATH and $LUA_CPATH
  extraLuaPackages = {
    # vimagePreview = [ (lp: with lp; [ magick ]) ];
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
    general = {
      core = [
        universal-ctags
        ripgrep
        fd
        ast-grep
        lazygit
      ];
      other = [
        sqlite
      ];
      markdown = [
        marksman
        python311Packages.pylatexenc
        harper
      ];
    };
    AI = [
      bitwarden-cli
    ];
    java = [
      jdt-language-server
    ];
    kotlin = [
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
      python-lsp-server
      debugpy
      pytest
      # pylint
      # python-lsp-ruff
      # pyls-flake8
      # pylsp-rope
      # yapf
      # autopep8
    ];
    C = [
      clang-tools
      valgrind
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
      oil-nvim
      vim-repeat
      pkgs.neovimPlugins.nvim-luaref
      nvim-nio
      nui-nvim
      nvim-web-devicons
      plenary-nvim
      mini-nvim
      pkgs.neovimPlugins.snacks-nvim
    ];
    other = [
      nvim-spectre
      # (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (p: { installQueries = true; })))
    ];
    lua = [
      luvit-meta
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
    java = [
      nvim-jdtls
    ];
    neonixdev = [
      lazydev-nvim
    ];
    AI = {
      minuet = [
        minuet-ai-nvim
        codecompanion-nvim
      ];
      windsurf = [
        windsurf-nvim
        codecompanion-nvim
      ];
    };
    debug = [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ];
    other = [
      img-clip-nvim
      nvim-highlight-colors
      nvim-neoclip-lua
      which-key-nvim
      eyeliner-nvim
      todo-comments-nvim
      vim-startuptime
      grapple-nvim
      pkgs.neovimPlugins.hlargs
      pkgs.neovimPlugins.visual-whitespace
    ];
    general = with pkgs.neovimPlugins; {
      markdown = [
        render-markdown-nvim
        markdown-preview-nvim
      ];
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
        pkgs.neovimPlugins.nvim-lspconfig
        lualine-lsp-progress
        lualine-nvim
        gitsigns-nvim
        # marks-nvim
        nvim-lint
        conform-nvim
        undotree
        nvim-surround
        treesj
        vim-sleuth
      ];
    };
  };
}
