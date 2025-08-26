# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixCats-nvim Neovim configuration using the nixCats package manager. It's built as a Nix flake that creates multiple Neovim builds with different feature sets and is designed for Nix/NixOS environments.

## Build Commands

### Core Build Commands
```bash
# Build the main birdeevim configuration
nix build '.#birdeevim'

# Build and run directly
nix run '.#birdeevim'

# Build specific variants
nix build '.#nvim_for_u'      # Version without AI plugins
nix build '.#noAInvim'        # Another AI-free version
nix build '.#portableVim'     # Portable version
nix build '.#minimalVim'      # Minimal configuration
nix build '.#nightlytest'     # Testing version with debug mode
nix build '.#vigo'            # Go-focused variant

# Install to profile
nix profile install '.#birdeevim'

# Create portable AppImage
nix build '.#app-images.portableVim'
```

### Development Commands
```bash
# List all available packages
nix flake show

# Update flake inputs
nix flake update

# Check flake syntax
nix flake check

# Test configuration without building
nix eval '.#birdeevim'
```

## Architecture Overview

### Core Structure

**NixCats Architecture**: Uses the nixCats plugin manager which combines Nix packaging with lazy-loading via `lze` (a custom lazy loader). This creates a hybrid system where:
- Nix handles plugin installation and system dependencies
- `lze` handles runtime plugin loading based on categories
- Categories determine which plugins/features are enabled per build

**Key Files**:
- `flake.nix` - Main flake definition with inputs and outputs
- `cats.nix` - Category definitions (plugin groups, LSPs, tools)
- `nvims.nix` - Package definitions (different Neovim variants)
- `lua/birdee/` - Main Lua configuration directory
- `misc_nix/overlays/` - Custom package overlays

### Plugin System

**Category-Based Loading**: Plugins are organized into categories that can be enabled/disabled per build:
- `AI.*` - AI-related plugins (claudecode, opencode, windsurf, etc.)
- `general` - Core plugins (snacks, mini, plenary, etc.) 
- `theme` - Colorscheme plugins
- Language categories (`python`, `rust`, `go`, `web`, etc.)
- Feature categories (`debug`, `markdown`, `vimagePreview`)

**Lazy Loading**: Uses `lze` instead of lazy.nvim:
```lua
-- Plugin specs use nixCats categories
{
  'plugin-name',
  for_cat = 'category.subcategory', -- Only loads if category enabled
  event = 'VeryLazy',
  keys = { ... },
  after = function() ... end
}
```

### Configuration Structure

**Lua Organization**:
- `lua/birdee/init.lua` - Main entry point, loads lze and imports
- `lua/birdee/plugins/` - Plugin configurations organized by type
- `lua/birdee/LSPs/` - LSP configurations
- `lua/birdee/fossil/` - Utility functions and legacy code
- `lua/birdee/utils/` - Helper utilities

**Theme System**: Supports multiple colorschemes via `extra.colorscheme`:
- Tokyo Night (storm, day variants) - currently active
- OneDark (darker variant)
- Catppuccin

### Package Variants

Each variant in `nvims.nix` has different:
- **Settings**: Wrapper configuration, aliases, host language support
- **Categories**: Which plugin/feature sets are enabled 
- **Extra**: Additional configuration like colorscheme, API keys

Examples:
- `birdeevim` - Full-featured with AI plugins
- `nvim_for_u` - Public version without AI, normal completion keys
- `portableVim` - Portable variant for AppImage
- `minimalVim` - Bare minimum configuration

### Language Support

**Multi-Language LSP Setup**: Comprehensive language support with:
- Python: pylsp with multiple plugins, debugpy
- Rust: rustaceanvim with full toolchain
- Go: go LSP with debug adapter
- Web: typescript, tailwind, htmx, html
- Java: nvim-jdtls with VSCode extensions
- Nix: nixd with custom configurations
- Many others (C, Zig, Fennel, Kotlin, SQL, etc.)

**Host Language Integration**: Configured providers for:
- Python 3: Custom bundled environment with debugging
- Ruby: Bundler-based environment 
- Node.js: Enabled for LSPs and tools

### Key Features

**Modern Neovim Setup**:
- Snacks.nvim for terminal, picker, explorer, notifications
- Blink completion instead of nvim-cmp
- Tree-sitter for syntax highlighting
- DAP for debugging multiple languages
- Grapple for quick file navigation

**AI Integration**:
- Claude Code (`<leader>ac` to toggle terminal)
- OpenCode integration
- Windsurf support
- Bitwarden integration for API keys

**Build Optimizations**:
- Lazy loading everything possible via categories
- Nix caching for fast rebuilds  
- Disabled test suites for Python packages (performance)
- Custom overlays for package modifications

## Category System Usage

When adding new plugins or features:

1. **Add to appropriate category** in `cats.nix`
2. **Enable category** in relevant package definitions in `nvims.nix`  
3. **Use `for_cat` in plugin specs** to conditionally load
4. **Test with minimal builds** to ensure categorization works

Example:
```nix
# In cats.nix
optionalPlugins = {
  newFeature = [ some-plugin ];
};

# In nvims.nix  
categories = {
  newFeature = true; # Enable for this build
};

# In plugin config
{
  'some-plugin',
  for_cat = 'newFeature', # Only loads if enabled
}
```

## AI Plugin Configuration

AI features are gated behind the `AI.*` categories. Current setup includes:
- Claude Code terminal integration
- API key management via Bitwarden
- Different completion key bindings for AI vs non-AI builds

The `birdeevim` build enables AI features while public variants (`nvim_for_u`, `noAInvim`) disable them.

## Testing

### Headless Plugin Testing
```bash
# Test single plugin
nix run '.#birdeevim' -- --headless -c "lua print(pcall(require, 'plugin')); quit"

# Test multiple plugins
nix run '.#birdeevim' -- --headless -c "
lua for _, p in ipairs({'copilot', 'lspsaga'}) do
  print(pcall(require, p) and '✅ ' .. p or '❌ ' .. p)
end; quit"

# Debug failed plugin
nix run '.#birdeevim' -- --headless -c "
lua local ok, err = pcall(require, 'plugin')
lua print(ok or vim.inspect(err)); quit"
```

### Testing Workflow
1. `nix build '.#birdeevim' --show-trace` - Build test
2. Headless `pcall(require, 'plugin')` - Load test  
3. Headless `plugin.setup({})` - Function test
4. Test all variants: birdeevim, nvim_for_u, minimalVim

## Plugin Configuration Guidelines

### NixCats + LZE Plugin Patterns

**Category System**: Plugins organized by functional groups
- `AI.*` - AI tools (claudecode, windsurf, opencode, etc.)
- `general.core` - Core functionality (lsp, git, completion, etc.) 
- `general.blink` - Blink completion ecosystem
- `other` - UI enhancements, utilities, visual plugins
- `markdown` - Markdown-specific tools
- Language categories: `python`, `rust`, `go`, `web`, `SQL`, etc.

**Loading Strategies**:
```lua
-- Event-based (most common)
{ "plugin", for_cat = "other", event = "DeferredUIEnter" }

-- On-demand loading (for utilities)  
{ "plugin", for_cat = "other", on_require = { "plugin" } }

-- Command-based
{ "plugin", for_cat = "other", cmd = { "PluginCmd" } }

-- Filetype-based
{ "plugin", for_cat = "markdown", ft = "markdown" }

-- Key-based
{ "plugin", for_cat = "other", keys = { "<leader>key" } }
```

### Plugin Configuration Requirements

**1. Add to cats.nix**:
```nix
optionalPlugins = {
  categoryName = [
    plugin-name  # Must match nixpkgs vimPlugins name
  ];
};
```

**2. Enable category in nvims.nix**:
```nix
categories = {
  categoryName = true;  # Enable in relevant package variants
};
```

**3. Configure in lua/birdee/plugins/init.lua**:
```lua
{
  "plugin-name",
  for_cat = "categoryName", 
  event = "DeferredUIEnter",  -- or appropriate loading strategy
  after = function()
    require("plugin-name").setup({ ... })
  end,
}
```

### LZE vs Lazy.nvim Differences

**❌ Don't use (lazy.nvim patterns)**:
- `event = "VeryLazy"` - Doesn't exist in LZE
- Separate config files with imports - Use inline configs
- `lazy = true/false` - Not needed in LZE
- `dependencies = { ... }` - Use nixcats dependencies

**✅ Use instead (LZE patterns)**:
- `event = "DeferredUIEnter"` - UI-related plugins
- `on_require = { "plugin" }` - On-demand utilities  
- Inline plugin specs in init.lua
- Dependencies in `startupPlugins` (cats.nix)

### Common Plugin Categories

**UI & Visual (`other`)**:
- noice.nvim, which-key.nvim, todo-comments.nvim
- eyeliner.nvim, hlargs, visual-whitespace
- Loading: `event = "DeferredUIEnter"`

**Core Functionality (`general.core`)**:
- gitsigns, fugitive, lualine, treesitter
- nvim-surround, undotree, dial.nvim
- Loading: `event = "DeferredUIEnter"` or specific events

**AI Tools (`AI.*`)**:
- Use subcategories: `AI.claudecode`, `AI.opencode`
- Loading: `event = "InsertEnter"` or `on_require`
- Conditional loading: `for_cat = { cat = 'AI.subcategory', default = false }`

**Language-Specific**:
- Match language name: `python`, `rust`, `markdown`
- Loading: `ft = "language"` or related events

### File Organization Pattern (✅ VERIFIED)

**nixCats + LZE File Structure Pattern**:

**Step 1: Create separate plugin file**
```lua
-- lua/birdee/plugins/ui.lua
local MP = ...  -- ✅ REQUIRED: Receive MP parameter from parent

return {
  -- Plugin specs here
  {
    "noice.nvim",
    for_cat = "other",
    on_require = { "noice" },
    after = function()
      require("noice").setup({ ... })
    end,
    keys = { ... },
  },
}
```

**Step 2: Import in main plugins file**
```lua
-- lua/birdee/plugins/init.lua  
return {
  { import = MP:relpath "ui" },  -- ✅ CORRECT: Single module import
  -- Other imports...
}
```

**Step 3: Git add new files (CRITICAL)**
```bash
git add lua/birdee/plugins/ui.lua  # ✅ REQUIRED: nixCats only copies git files
```

**Step 4: Test loading**
```bash
nix build '.#birdeevim' --show-trace
nix run '.#birdeevim' -- -c ":lua if pcall(require, 'noice') then print('✅ Plugin loaded') else print('❌ Failed') end; vim.cmd('quit')"
```

### nixCats + LZE Core Rules

**✅ CORRECT Patterns**:
- File must be in git (`git add` required)
- Use `local MP = ...` to receive parameter
- Return table of plugin specs
- Import with `{ import = MP:relpath "filename" }`
- LZE imports single modules, not directories

**❌ WRONG Patterns (REMOVED)**:
- `{ import = MP:relpath "ui.index" }` - Incorrect path format
- Creating `/ui/index.lua` structure - LZE doesn't import directories
- Missing `git add` step - Files won't be in build
- Using lazy.nvim patterns - Different loading system

### Troubleshooting Common Issues

**Plugin not found**: Check nixpkgs name matches exactly
**LZE loading errors**: Use correct events (`DeferredUIEnter`, not `VeryLazy`)  
**Dependencies missing**: Add to `startupPlugins` in cats.nix
**Category not enabled**: Verify category enabled in nvims.nix package
**Headless testing fails**: Use `on_require` instead of events for testing