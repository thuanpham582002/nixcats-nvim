# Example overlay:
/*
importName: inputs: let
  overlay = self: super: { 
    ${importName} = SOME_DRV;
    # or
    ${importName} = {
      # define your overlay derivations here
    };
  };
in
overlay
*/

inputs: let 
  inherit (inputs.nixCats) utils;
  overlaySet = {

    # locked = import ./locked.nix;
    # internalvim = import ./build;
    # lua-git2 = import ./lua-git2.nix;

  };
  extra = [
    (utils.sanitizedPluginOverlay inputs)
    # add any flake overlays here.
    inputs.neorg-overlay.overlays.default
    inputs.neovim-nightly-overlay.overlays.default
    (utils.fixSystemizedOverlay inputs.codeium.overlays
      (system: inputs.codeium.overlays.${system}.default)
    )
  ];
in
builtins.attrValues (builtins.mapAttrs (name: value: (value name inputs)) overlaySet) ++ extra
