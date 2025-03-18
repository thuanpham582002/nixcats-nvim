nixpkgs: type: path: let
  pkgs = import nixpkgs {};
  inherit (pkgs) lib;
  targetFlake = with builtins; getFlake "path:${toString path}";
  allTargets = {
    nixos = [
      [ "outputs" "nixosConfigurations" ]
      [ "outputs" "legacyPackages" "${pkgs.system}" "nixosConfigurations" ]
    ];
    home-manager = [
      [ "outputs" "homeConfigurations" ]
      [ "outputs" "legacyPackages" "${pkgs.system}" "homeConfigurations" ]
    ];
    darwin = [
      [ "outputs" "darwinConfigurations" ]
      [ "outputs" "legacyPackages" "${pkgs.system}" "darwinConfigurations" ]
    ];
  };
  mergeOpts = targetFlake: lib.flip lib.pipe (let
    getCfgs = lib.flip lib.pipe [
      (atp: lib.attrByPath atp {} targetFlake)
      builtins.attrValues
    ];
  in [
    (type: allTargets.${type})
    (map getCfgs)
    (builtins.foldl' (a: v: a ++ v) [])
    lib.mergeAttrsList
    (v: v.options)
  ]);
in mergeOpts targetFlake type
