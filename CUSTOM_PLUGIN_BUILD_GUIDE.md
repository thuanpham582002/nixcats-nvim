# Custom Plugin Build Guide - NixCats-nvim

## ❌ COMMON MISTAKES TO AVOID

### 1. **NEVER put custom builds in `optionalPlugins`**
```nix
# ❌ WRONG - Causes infinite evaluation
optionalPlugins = {
  myplugin = [
    (pkgs.vimUtils.buildVimPlugin { ... })  # Custom build here
  ];
};
```

**Problem**: Custom builds in optionalPlugins cause nixCats infinite evaluation loops because lazy loading conflicts with custom dependency resolution.

### 2. **NEVER use complex custom builds with metadata**
```nix
# ❌ WRONG - Too complex
(pkgs.vimUtils.buildVimPlugin {
  pname = "my-plugin";
  version = "latest";
  src = pkgs.fetchFromGitHub { ... };
  propagatedBuildInputs = [ ... ];  # Bad
  meta = { ... };  # Bad
})
```

**Problem**: Extra dependencies and metadata create circular dependencies in nixCats evaluation.

### 3. **NEVER mismatch plugin names**
```lua
-- ❌ WRONG - Name mismatch
{
  "obsidian-nvim",  -- Custom build name
  for_cat = "obsidian",
}
```

**Problem**: Custom build creates plugin with different name than referenced in config.

### 4. **NEVER use multiple conflicting loading triggers**
```lua
-- ❌ WRONG - Conflicting triggers
{
  "my-plugin",
  for_cat = "mycat",
  ft = "markdown",  # Filetype trigger
  cmd = { "MyCommand" },  # Command trigger
  event = "VeryLazy",  # Event trigger
}
```

**Problem**: Multiple loading strategies confuse nixCats LZE system.

## ✅ CORRECT PATTERNS

### 1. **ALWAYS use `startupPlugins` for custom builds**
```nix
# ✅ CORRECT - Custom builds in startupPlugins
startupPlugins = {
  myplugin = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "my-plugin";
      src = pkgs.fetchFromGitHub { ... };
    })
  ];
};
```

### 2. **ALWAYS keep custom builds minimal**
```nix
# ✅ CORRECT - Minimal build
pkgs.vimPlugins.obsidian-nvim or (pkgs.vimUtils.buildVimPlugin {
  name = "obsidian-nvim";
  src = pkgs.fetchFromGitHub {
    owner = "obsidian-nvim";
    repo = "obsidian.nvim";
    rev = "refs/tags/v3.14.3";
    hash = "sha256-...";
  };
})
```

### 3. **ALWAYS use fallback to nixpkgs if available**
```nix
# ✅ CORRECT - Fallback pattern
pkgs.vimPlugins.obsidian-nvim or (custom_build)
```

### 4. **ALWAYS match plugin names correctly**
```lua
-- ✅ CORRECT - Name matches repository
{
  "obsidian.nvim",  # Repository name
  for_cat = "obsidian",
}
```

### 5. **ALWAYS use single loading strategy**
```lua
-- ✅ CORRECT - Simple loading
{
  "obsidian.nvim",
  for_cat = "obsidian",
  -- No conflicting triggers
}
```

## 🔧 DEBUG CHECKLIST

### When custom build fails:

1. **Check build isolation**:
```bash
nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in (pkgs.vimUtils.buildVimPlugin { ... }).name'
```

2. **Move from optional → startup**:
```nix
# If in optionalPlugins, move to startupPlugins
```

3. **Simplify build**:
```nix
# Remove propagatedBuildInputs, meta, complex features
```

4. **Check name matching**:
```lua
# Ensure config name matches build name
```

5. **Test with minimal loading**:
```lua
# Remove ft, cmd, event triggers
```

## 🎯 RULES OF THUMB

1. **Custom builds = startupPlugins**
2. **Standard plugins = optionalPlugins**
3. **Keep builds minimal**
4. **Single loading strategy**
5. **Match names exactly**
6. **Always test isolation first**

## 📋 WORKFLOW

1. **Test custom build in isolation**
2. **Add to startupPlugins (never optional)**
3. **Use minimal config**
4. **Match names exactly**
5. **Test nixCats build**
6. **Enable category in nvims.nix**
7. **Test commands work**

---

**Remember: Custom builds + optionalPlugins = INFINITE EVALUATION**
**Always use startupPlugins for custom builds!**