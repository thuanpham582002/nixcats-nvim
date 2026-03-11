_: _: self: super: {
  vimPlugins = super.vimPlugins // {
    conjure = super.vimPlugins.conjure.overrideAttrs (_: {
      nativeCheckInputs = [];
      dontFixup = true;
    });
    cmp-conjure = super.vimPlugins.cmp-conjure.overrideAttrs (_: {
      nativeCheckInputs = [];
      checkInputs = [];
      buildInputs = [ self.vimPlugins.conjure ];
      dontFixup = true;
    });
  };
}
