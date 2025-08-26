# 🚀 Nixcats Plugin Migration Checklist

> **Migration Status**: Active Development Phase  
> **Last Updated**: 2025-08-26  
> **Progress**: 25/59 plugins migrated (42%)

## 📊 Progress Overview
```
┌─────────────────────────────────────────────┐
│ Migration Progress                          │
├─────────────────────────────────────────────┤
│ ✅ Completed:    25/59 (42%)               │
│ 🔄 In Progress:   0/59 (0%)                │
│ 🚧 Blocked:       1/59 (2%)                │
│ 📋 Planned:      33/59 (56%)               │
└─────────────────────────────────────────────┘
```

## 🎯 Priority Legend
- **🔴 HIGH**: Critical functionality, needed immediately
- **🟡 MEDIUM**: Useful features, nice to have
- **🟢 LOW**: Enhancement features, can wait

## 🚧 Blocked Issues
- **🚧 obsidian.nvim**: Build fails due to missing fzf dependency in nixpkgs. The plugin requires `obsidian.pickers._fzf` module which is not properly packaged. Configuration is ready but plugin is temporarily disabled.

## 📋 Migration Categories

### 🤖 AI & Productivity Tools
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| [ ] | 🔴 HIGH | `copilot.lua` | `vimPlugins.copilot-lua` | `AI.copilot` | GitHub Copilot integration |
| [ ] | 🔴 HIGH | `blink-copilot` | `vimPlugins.blink-copilot` | `AI.copilot` | Blink.cmp integration for Copilot |
| ✅ | 🔴 HIGH | `claudecode.nvim` | Custom build | `AI.claudecode` | Claude Code integration - IMPLEMENTED |
| 🚧 | 🔴 HIGH | `obsidian.nvim` | `vimPlugins.obsidian-nvim` | `markdown` | Note management system - BLOCKED (build fails) |

**Progress**: 1/4 completed (1 blocked)

---

### 🔍 LSP & Navigation Enhancement
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🔴 HIGH | `lspsaga.nvim` | `vimPlugins.lspsaga-nvim` | `general.core` | Enhanced LSP UI, finder, outline |
| [ ] | 🟡 MEDIUM | `lazydev.nvim` | `vimPlugins.lazydev-nvim` | `general.core` | Better Lua development (expand from neonixdev) |

**Progress**: 1/2 completed

---

### 📝 Markdown & Documentation
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🔴 HIGH | `markdown-preview.nvim` | `vimPlugins.markdown-preview-nvim` | `markdown` | Live preview in browser - IMPLEMENTED |
| ✅ | 🔴 HIGH | `render-markdown.nvim` | `vimPlugins.render-markdown-nvim` | `markdown` | Render markdown in buffer - IMPLEMENTED |
| [ ] | 🟡 MEDIUM | `markdown-toc.nvim` | `vimPlugins.markdown-toc-nvim` | `markdown` | Table of contents generation |
| [ ] | 🟡 MEDIUM | `markdown-togglecheck` | `vimPlugins.markdown-togglecheck` | `markdown` | Toggle checkboxes |
| [ ] | 🟡 MEDIUM | `markdowny.nvim` | `vimPlugins.markdowny-nvim` | `markdown` | Enhanced markdown editing |
| [ ] | 🟡 MEDIUM | `vim-table-mode` | `vimPlugins.vim-table-mode` | `markdown` | Table editing mode |
| [ ] | 🟢 LOW | `vim-markdown-folding` | `vimPlugins.vim-markdown-folding` | `markdown` | Better folding |
| [ ] | 🟢 LOW | `nvim-markdown` | `vimPlugins.nvim-markdown` | `markdown` | Enhanced markdown support |

**Progress**: 2/8 completed

---

### 🎨 UI & Visual Enhancements
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🟡 MEDIUM | `noice.nvim` | `vimPlugins.noice-nvim` | `other` | UI replacement for messages/cmdline - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `edgy.nvim` | `vimPlugins.edgy-nvim` | `other` | Window layout management - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `smart-splits.nvim` | `vimPlugins.smart-splits-nvim` | `other` | Smart window navigation - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `persistence.nvim` | `vimPlugins.persistence-nvim` | `other` | Session management - IMPLEMENTED |
| [ ] | 🟡 MEDIUM | `bufferline.nvim` | `vimPlugins.bufferline-nvim` | `other` | Buffer line with tabs |
| [ ] | 🟢 LOW | `zen-mode.nvim` | `vimPlugins.zen-mode-nvim` | `other` | Distraction-free writing |
| [ ] | 🟢 LOW | `twilight.nvim` | `vimPlugins.twilight-nvim` | `other` | Code dimming for focus |
| [ ] | 🟢 LOW | `peek.nvim` | `vimPlugins.peek-nvim` | `other` | File preview |

**Progress**: 4/8 completed

---

### 🔧 Utilities & Tools
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🔴 HIGH | `diffview.nvim` | `vimPlugins.diffview-nvim` | `general.core` | Git diff viewer - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `persistence.nvim` | `vimPlugins.persistence-nvim` | `other` | Session management - IMPLEMENTED |
| [ ] | 🟡 MEDIUM | `grug-far.nvim` | `vimPlugins.grug-far-nvim` | `other` | Search and replace |
| [ ] | 🟡 MEDIUM | `advanced-git-search.nvim` | `vimPlugins.advanced-git-search-nvim` | `other` | Advanced git search |
| [ ] | 🟡 MEDIUM | `mason.nvim` | `vimPlugins.mason-nvim` | `general.core` | LSP/DAP/Linter installer |
| [ ] | 🟡 MEDIUM | `mason-lspconfig.nvim` | `vimPlugins.mason-lspconfig-nvim` | `general.core` | Mason LSP integration |
| [ ] | 🟡 MEDIUM | `mason-nvim-dap.nvim` | `vimPlugins.mason-nvim-dap-nvim` | `debug` | Mason DAP integration |
| [ ] | 🟡 MEDIUM | `mason-tool-installer.nvim` | `vimPlugins.mason-tool-installer-nvim` | `other` | Auto-install tools |

**Progress**: 2/8 completed

---

### 🎯 Navigation & Search
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| [ ] | 🟡 MEDIUM | `telescope.nvim` | `vimPlugins.telescope-nvim` | `general.core` | Alternative to snacks picker |
| [ ] | 🟢 LOW | `leap.nvim` | `vimPlugins.leap-nvim` | `other` | Motion plugin (alternative to eyeliner) |
| [ ] | 🟢 LOW | `harpoon` | `vimPlugins.harpoon` | `other` | File bookmarking (alternative to grapple) |

**Progress**: 0/3 completed

---

### 🧪 Testing & Debug (Already Implemented)
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🔴 HIGH | `nvim-dap` | `vimPlugins.nvim-dap` | `debug` | Already in nixcats |
| ✅ | 🔴 HIGH | `nvim-dap-ui` | `vimPlugins.nvim-dap-ui` | `debug` | Already in nixcats |
| ✅ | 🔴 HIGH | `nvim-dap-virtual-text` | `vimPlugins.nvim-dap-virtual-text` | `debug` | Already in nixcats |

**Progress**: 3/3 completed ✅

---

### 🎨 Colorschemes (Already Implemented)
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🟡 MEDIUM | `catppuccin-nvim` | `vimPlugins.catppuccin-nvim` | `theme` | Already in nixcats |
| ✅ | 🟡 MEDIUM | `tokyonight.nvim` | `vimPlugins.tokyonight-nvim` | `theme` | Already in nixcats |
| ✅ | 🟡 MEDIUM | `onedark.nvim` | `vimPlugins.onedark-nvim` | `theme` | Already in nixcats |

**Progress**: 3/3 completed ✅

---

### ✅ Additional Implemented Plugins (Not in Original List)
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| ✅ | 🟡 MEDIUM | `todo-comments.nvim` | `vimPlugins.todo-comments-nvim` | `other` | Highlight TODO, FIXME comments - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `eyeliner.nvim` | `vimPlugins.eyeliner-nvim` | `other` | Enhanced f/F navigation - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `hlargs.nvim` | Custom | `other` | Highlight function arguments - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `visual-whitespace.nvim` | Custom | `other` | Visualize whitespace - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `nvim-highlight-colors` | `vimPlugins.nvim-highlight-colors` | `other` | Highlight color codes - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `treesj` | `vimPlugins.treesj` | `general.core` | Split/join code structures - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `dial.nvim` | `vimPlugins.dial-nvim` | `general.core` | Enhanced increment/decrement - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `undotree` | `vimPlugins.undotree` | `general.core` | Visualize undo history - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `nvim-surround` | `vimPlugins.nvim-surround` | `general.core` | Surround selections - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `vim-sleuth` | `vimPlugins.vim-sleuth` | `general.core` | Auto indentation detection - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `otter.nvim` | `vimPlugins.otter-nvim` | `otter` | Code completion in markdown - IMPLEMENTED |
| ✅ | 🟡 MEDIUM | `typst-preview.nvim` | `vimPlugins.typst-preview-nvim` | `typst` | Typst document preview - IMPLEMENTED |

**Progress**: 12/12 completed ✅

---

### 📦 Additional LazyVim Dependencies
| Status | Priority | Plugin | Nixpkgs Name | Category | Notes |
|--------|----------|--------|--------------|-----------|-------|
| [ ] | 🟡 MEDIUM | `friendly-snippets` | `vimPlugins.friendly-snippets` | `general.blink` | Snippet collection |
| [ ] | 🟡 MEDIUM | `ts-comments.nvim` | `vimPlugins.ts-comments-nvim` | `general.core` | Smart commenting |
| [ ] | 🟡 MEDIUM | `mini.ai` | `vimPlugins.mini-nvim` | `general.core` | Text objects (part of mini.nvim) |
| [ ] | 🟡 MEDIUM | `mini.pairs` | `vimPlugins.mini-nvim` | `general.core` | Auto pairs (part of mini.nvim) |
| [ ] | 🟡 MEDIUM | `mini.icons` | `vimPlugins.mini-nvim` | `general.core` | Icons (part of mini.nvim) |
| [ ] | 🟡 MEDIUM | `flash.nvim` | `vimPlugins.flash-nvim` | `other` | Enhanced navigation |
| [ ] | 🟡 MEDIUM | `trouble.nvim` | `vimPlugins.trouble-nvim` | `other` | Diagnostics list |

**Progress**: 0/7 completed

---

## 🛠️ Implementation Workflow

### Phase 1: Critical Plugins (🔴 HIGH Priority)
1. [ ] **AI Tools Setup**
   - Add copilot.lua + blink-copilot to `AI.copilot` category
   - Configure in `cats.nix` under `optionalPlugins.AI.copilot`
   - Enable in relevant nixcats packages

2. [ ] **Obsidian Integration**
   - Add obsidian.nvim to `markdown` category
   - Create lua configuration in `lua/birdee/plugins/`

3. [ ] **LSP Enhancement**
   - Add lspsaga.nvim to `general.core` category
   - Configure advanced LSP features

4. [ ] **Git Tools**
   - Add diffview.nvim to `general.core`
   - Configure git diff viewing

### Phase 2: Useful Features (🟡 MEDIUM Priority)
1. [ ] **UI Improvements**
   - noice.nvim for better UI
   - edgy.nvim for window management
   - bufferline.nvim for buffer tabs

2. [ ] **Markdown Tooling**
   - markdown-preview.nvim for live preview
   - Additional markdown utilities

3. [ ] **Development Tools**
   - Mason tooling for LSP management
   - Enhanced search and replace

### Phase 3: Nice-to-Have (🟢 LOW Priority)
1. [ ] **Focus Tools**
   - zen-mode + twilight for distraction-free writing
   
2. [ ] **Alternative Tools**
   - telescope as alternative to snacks
   - leap/harpoon as alternatives to existing tools

---

## 📋 Configuration Checklist

### For Each Plugin:
- [ ] Add to appropriate category in `cats.nix`
- [ ] Add nixpkgs dependency if needed
- [ ] Create lua configuration file
- [ ] Test loading and functionality
- [ ] Update package definitions in `nvims.nix`
- [ ] Document any special requirements

### Categories to Modify:
- [ ] `AI.*` - New AI tools
- [ ] `markdown` - Markdown enhancements
- [ ] `general.core` - Core functionality
- [ ] `general.blink` - Completion related
- [ ] `other` - UI and utility plugins
- [ ] `debug` - Debug tools (mostly done)

---

## 🚨 Potential Issues & Solutions

### Common Nixcats Challenges:
1. **Plugin Not in Nixpkgs**: Create custom overlay in `misc_nix/overlays/`
2. **Category Conflicts**: Use subcategories like `AI.copilot`, `AI.opencode`
3. **Lua Configuration**: Use `for_cat` conditions for lazy loading
4. **Dependencies**: Ensure all dependencies are in `startupPlugins` or same category

### Migration Strategy:
1. Start with plugins already in nixpkgs
2. Create custom packages for missing plugins
3. Test each category incrementally
4. Maintain backward compatibility with existing config

---

## 🔄 Progress Tracking

### Completion Checklist:
- [ ] All high priority plugins migrated
- [ ] All medium priority plugins evaluated
- [ ] Custom overlays created where needed
- [ ] Configuration files created and tested
- [ ] Package variants updated
- [ ] Documentation updated
- [ ] Migration verified

### Testing Protocol:
1. [ ] Build test with each new category
2. [ ] Verify plugin loading in runtime
3. [ ] Test key functionality
4. [ ] Check for conflicts with existing plugins
5. [ ] Validate all package variants still work

---

**Next Action**: Start with Phase 1 - Critical Plugins (copilot, obsidian, lspsaga, diffview)