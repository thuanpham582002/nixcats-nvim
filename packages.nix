inputs: let
  inherit (inputs.nixCats) utils;
  birdeevim_settings = { pkgs, ... }@misc: {
    # so that it finds my ai auths in ~/.cache/birdeevim
    extraName = "birdeevim";
    configDirName = "birdeevim";
    wrapRc = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    viAlias = false;
    vimAlias = false;
    gem_path = ./overlays/ruby_provider;
    unwrappedCfgPath = utils.n2l.types.inline-unsafe.mk {
      body = /*lua*/ ''(os.getenv("HOME") or "/home/birdee") .. "/.birdeevim"'';
    };
    # moduleNamespace = [ defaultPackageName ];
    # nvimSRC = inputs.neovim-src;
    # neovim-unwrapped = pkgs.internalvim.nvim;
    # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    # neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
    #   preConfigure = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    #     substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    #   '';
    #   treesitter-parsers = {};
    # });
    # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim.overrideAttrs (prev: {
    #   preConfigure = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    #     substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    #   '';
    #   treesitter-parsers = {};
    # });
  };
  birdeevim_categories = { pkgs, ... }@misc: {
    AI = true;
    vimagePreview = true;
    lspDebugMode = false;
    other = true;
    theme = true;
    debug = true;
    customPlugins = true;
    general = true;
    telescope = true;
    otter = true;
    bash = true;
    notes = true;
    neonixdev = true;
    java = true;
    web = true;
    go = true;
    kotlin = true;
    python = true;
    rust = true;
    SQL = true;
    C = true;
  };
  birdeevim_extra = { pkgs, ... }@misc: {
    colorscheme = "onedark";
    javaExtras = {
      java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
      java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
      gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
    };
    nixdExtras = {
      nixpkgs = pkgs.path;
    };
    AIextras = {
      codeium_token_uuid = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
      # NOTE: codeium table gets deep extended into codeium settings.
      codeium = {
        tools = {
          uname = "${pkgs.coreutils}/bin/uname";
          uuidgen = "${pkgs.util-linux}/bin/uuidgen";
          curl = "${pkgs.curl}/bin/curl";
          gzip = "${pkgs.gzip}/bin/gzip";
          language_server = "${inputs.codeium.packages.${pkgs.system}.codeium-lsp}/bin/codeium-lsp";
        };
      };
    };
  };
in {
  birdeevim = args: {
    settings =  birdeevim_settings args // {
      wrapRc = true;
      aliases = [ "vi" "nvim" ];
    };
    categories =  birdeevim_categories args // {
    };
    extra = birdeevim_extra args // {
    };
  };
  nightlytest = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = [ "tvim" ];
    };
    categories = birdeevim_categories args // {
      test = true;
      notes = true;
      lspDebugMode = true;
    };
    extra = birdeevim_extra args // {
    };
  };
  testvim = args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = [ "vim" ];
    };
    categories = birdeevim_categories args // {
      test = true;
      # notes = true;
      lspDebugMode = true;
    };
    extra = birdeevim_extra args // {
    };
  };
  vigo = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "vigo";
      # aliases = [ "vigo" ];
    };
    categories = {
      theme = true;
      other = true;
      debug = true;
      customPlugins = true;
      general = true;
      telescope = true;
      otter = true;
      nix = true;
      web = true;
      go = true;
      SQL = true;
    };
    extra = {
      inherit (birdeevim_extra args) nixdExtras;
    };
  };
  nvim_for_u = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "nvim_for_u";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      AI = false;
      tabCompletionKeys = true;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  noAInvim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = true;
      extraName = "noAInvim";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      AI = false;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  notesVim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      configDirName = "birdeevim";
      withRuby = false;
      extraName = "notesVim";
      aliases = [ "note" ];
    };
    categories = {
      notes = true;
      otter = true;
      customPlugins = true;
      other = true;
      general = true;
      neonixdev = true;
      telescope = true;
      vimagePreview = true;
      AI = true;
      lspDebugMode = false;
      theme = true;
    };
    extra = birdeevim_extra args // {
      colorscheme = "tokyonight";
      javaExtras = null;
    };
  };
  portableVim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      extraName = "portableVim";
      aliases = [ "vi" "vim" "nvim" ];
    };
    categories = birdeevim_categories args // {
      portableExtras = true;
      notes = true;
      AI = false;
    };
    extra = birdeevim_extra args // {
      AIextras = null;
    };
  };
  minimalVim = { pkgs, ... }@args: {
    settings = birdeevim_settings args // {
      wrapRc = false;
      aliases = null;
      extraName = "minimalVim";
      withNodeJs = false;
      withRuby = false;
      withPython3 = false;
    };
    categories = {};
    extra = {};
  };
}
