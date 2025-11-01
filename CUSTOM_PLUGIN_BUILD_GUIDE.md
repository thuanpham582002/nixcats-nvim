# Custom Plugin Build Guide - NixCats-nvim

## 🚨 **CRITICAL BUILD FAILURE ROOT CAUSE**

**Original Issue**: `nix build '.#birdeevim'` failed with infinite evaluation/hanging when adding custom obsidian.nvim build.

## ❌ **WHAT CAUSED THE BUILD FAILURE**

### 1. **Custom build complexity in `optionalPlugins` caused infinite evaluation**
```nix
# ❌ CAUSED BUILD FAILURE
optionalPlugins = {
  obsidian = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "obsidian.nvim";
      version = "2025-01-01";
      src = pkgs.fetchFromGitHub {
        owner = "obsidian-nvim";
        repo = "obsidian.nvim";
        rev = "1a1a475846a4cfa3cfedde1c59141d99b6212951";
        hash = "sha256-b337e6220d57039d9eae9ec0eb0d104fcbf9946abe611861462d4a1bb9636cac";
      };
      propagatedBuildInputs = with pkgs.vimPlugins; [ plenary-nvim ];  # ❌ COMPLEXITY
      meta = {  # ❌ COMPLEXITY
        description = "Obsidian.md integration for Neovim";
        homepage = "https://github.com/obsidian-nvim/obsidian.nvim";
      };
    })
  ];
}
```

**Problem**: Complex custom builds with `propagatedBuildInputs` and `meta` in `optionalPlugins` caused nixCats infinite evaluation loops.

### 2. **Symptoms of the build failure**
```bash
$ nix build '.#birdeevim'
# No output, just hangs forever
# Timeout after minutes
# No error message, just infinite evaluation
```

## ✅ **WHAT FIXED THE BUILD FAILURE**

### 1. **Simplified custom build**
```nix
# ✅ WORKING - Minimal build
pkgs.vimPlugins.obsidian-nvim or (pkgs.vimUtils.buildVimPlugin {
  name = "obsidian-nvim";
  src = pkgs.fetchFromGitHub {
    owner = "obsidian-nvim";
    repo = "obsidian.nvim";
    rev = "refs/tags/v3.14.3";
    hash = "sha256-82e352cca563d91a070e851ec6fdb0062c22811d708e751cbf6fe63ea9bfe4cb";
  };
  # No propagatedBuildInputs
  # No meta
})
```

### 2. **Used release tag instead of commit**
```nix
# ❌ PROBLEMATIC - Commit hash
rev = "1a1a475846a4cfa3cfedde1c59141d99b6212951";

# ✅ WORKING - Release tag
rev = "refs/tags/v3.14.3";
```

### 3. **Added fallback pattern**
```nix
# ✅ SAFE - Fallback to nixpkgs if available
pkgs.vimPlugins.obsidian-nvim or (custom_build)
```

## 🔧 **DEBUG BUILD FAILURE**

### When build hangs indefinitely:

1. **Test custom build in isolation**:
```bash
nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; in (pkgs.vimUtils.buildVimPlugin { ... }).name'
```

2. **Simplify custom build**:
```nix
# Remove propagatedBuildInputs
# Remove meta
# Use release tags instead of commits
```

3. **Test minimal build**:
```nix
pkgs.vimUtils.buildVimPlugin {
  name = "test";
  src = pkgs.fetchFromGitHub { ... };
}
```

4. **Move to startupPlugins if still fails**:
```nix
# Last resort - move from optionalPlugins to startupPlugins
startupPlugins = {
  obsidian = [ (custom_build) ];
};
```

## 🎯 **BUILD FAILURE PATTERNS TO AVOID**

### ❌ **NEVER do this in optionalPlugins**:
```nix
optionalPlugins = {
  myplugin = [
    (pkgs.vimUtils.buildVimPlugin {
      # Complex configuration
      propagatedBuildInputs = [ ... ];  # ❌ INFINITE EVALUATION
      meta = { ... };  # ❌ INFINITE EVALUATION
      pname = "complex-name";  # ❌ CAN CAUSE ISSUES
      version = "latest";  # ❌ NOT DETERMINISTIC
    })
  ];
};
```

### ✅ **ALWAYS do this**:
```nix
optionalPlugins = {
  myplugin = [
    pkgs.vimPlugins.myplugin or (pkgs.vimUtils.buildVimPlugin {
      name = "myplugin";  # ✅ SIMPLE
      src = pkgs.fetchFromGitHub {
        owner = "owner";
        repo = "repo";
        rev = "refs/tags/v1.0.0";  # ✅ DETERMINISTIC
        hash = "sha256-...";  # ✅ CORRECT HASH
      };
    })
  ];
};
```

## 📋 **BUILD SUCCESS WORKFLOW**

1. **Test custom build isolation first**
2. **Use release tags, not commits**
3. **Keep builds minimal (no inputs, no meta)**
4. **Use fallback pattern**
5. **Add to optionalPlugins**
6. **If still fails, try startupPlugins**

## 🚨 **KEY LESSON**

**Custom builds in optionalPlugins can cause infinite evaluation if too complex. Keep them minimal!**

**The build failure was NOT about workspace configuration - that was a separate issue after build succeeded.**

---

**Remember: Build fail = infinite evaluation from complex custom builds in optionalPlugins. Keep it simple!**