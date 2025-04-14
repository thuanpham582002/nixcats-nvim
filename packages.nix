inputs: let
  inherit (inputs.nixCats) utils;
  birdeevim_settings = { pkgs, name, ... }@misc: {
    # so that it finds my ai auths in ~/.cache/birdeevim
    extraName = "birdeevim";
    configDirName = "birdeevim";
    wrapRc = true;
    hosts.node.enable = true;
    hosts.ruby.enable = true;
    hosts.python3.enable = true;
    hosts.perl.enable = false;
    unwrappedCfgPath = utils.n2l.types.inline-unsafe.mk {
      body = /*lua*/ ''(os.getenv("HOME") or "/home/birdee") .. "/.birdeevim"'';
    };
    # moduleNamespace = [ defaultPackageName ];
    hosts.neovide.path = {
      value = "${pkgs.neovide}/bin/neovide";
      args = [ "--add-flags" "--neovim-bin ${placeholder "out"}/bin/${name}" ];
    };
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
    otter = true;
    bash = true;
    notes = true;
    nvim-cmp = false;
    blink = true;
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
      nixpkgs = "import ${pkgs.path} {}";
      get_configs = utils.n2l.types.function-unsafe.mk {
        args = [ "type" "path" ];
        body = ''return [[import ${./misc_nix/nixd.nix} ${pkgs.path} "]] .. type .. [[" ]] .. (path or "./.")'';
      };
    };
    # AIextras = {
    #   codeium_token_uuid = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
    #   # codeium table gets deep extended into codeium settings.
    #   codeium = {
    #     tools = {
    #       uname = "${pkgs.coreutils}/bin/uname";
    #       uuidgen = "${pkgs.util-linux}/bin/uuidgen";
    #       curl = "${pkgs.curl}/bin/curl";
    #       gzip = "${pkgs.gzip}/bin/gzip";
    #       language_server = "${inputs.windsurf.packages.${pkgs.system}.codeium-lsp}/bin/codeium-lsp";
    #     };
    #   };
    # };
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
      nvim-cmp = false;
      blink = true;
      theme = true;
      other = true;
      debug = true;
      customPlugins = true;
      general = true;
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
      hosts.ruby.enable = false;
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
      vimagePreview = true;
      nvim-cmp = false;
      blink = true;
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
      hosts.node.enable = false;
      hosts.ruby.enable = false;
      hosts.perl.enable = false;
      hosts.python3.enable = false;
    };
    categories = {};
    extra = {};
  };
}
