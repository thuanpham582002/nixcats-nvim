# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#examples
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgsLocked.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    # nixCats.url = "git+file:/home/birdee/Projects/nixCats-nvim";
    # neovim-src = { url = "github:neovim/neovim/nightly"; flake = false; };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # inputs.nixpkgs.follows = "nixpkgsNV";
      # inputs.neovim-src.follows = "neovim-src";
    };

    fenix.url = "github:nix-community/fenix";
    nix-appimage.url = "github:ralismark/nix-appimage";
    templ.url = "github:a-h/templ";
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";

    plugins-lze = {
      url = "github:BirdeeHub/lze";
      # url = "git+file:/home/birdee/Projects/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      # url = "git+file:/home/birdee/Projects/lzextras";
      flake = false;
    };
    codeium = {
      url = "github:Exafunction/codeium.nvim";
      # inputs.nixpkgs.follows = "nixpkgsNV";
    };
    "plugins-hlargs" = {
      url = "github:m-demare/hlargs.nvim";
      flake = false;
    };
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-telescope-git-file-history" = {
      url = "github:isak102/telescope-git-file-history.nvim";
      flake = false;
    };
    "plugins-visual-whitespace" = {
      url = "github:mcauley-penney/visual-whitespace.nvim";
      flake = false;
    };
    "plugins-snacks.nvim" = {
      # temporary
      url = "github:BirdeeHub/snacks.nvim";
      flake = false;
    };
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
    };
    dependencyOverlays = import ./overlays inputs;

    categoryDefinitions = import ./categories.nix inputs;

    packageDefinitions = import ./packages.nix inputs;

    defaultPackageName = "birdeevim";
  in
    forEachSystem (system: let
      inherit (utils) baseBuilder;
      nixCatsBuilder = baseBuilder luaPath {
        inherit nixpkgs;
        inherit system dependencyOverlays extra_pkg_config;
      } categoryDefinitions packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      portablevim = nixCatsBuilder "portableVim";
    in {
      packages = utils.mkAllWithDefault defaultPackage;
      app-images = {
        portableVim = inputs.nix-appimage.bundlers.${system}.default portablevim;
      };
    }
  ) // (let
    nixosModule = utils.mkNixosModules {
      inherit nixpkgs;
      inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
      moduleNamespace = [ defaultPackageName ];
    };
    homeModule = utils.mkHomeModules {
      inherit nixpkgs;
      inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
      moduleNamespace = [ defaultPackageName ];
    };
  in {
    overlays = utils.makeOverlaysWithMultiDefault luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;
    inherit nixosModule homeModule;
    nixosModules.default = nixosModule;
    homeModules.default = homeModule;
  });
}
