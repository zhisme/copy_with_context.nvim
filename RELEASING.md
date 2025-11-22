# Release Guide

This guide covers the process for releasing a new version of `copy_with_context.nvim`.

## Release Checklist

### 1. Pre-Release Checks

Before releasing, ensure:

- [ ] All tests pass: `make test`
- [ ] No linting errors: `make lint`
- [ ] Code is formatted: `make fmt-check`
- [ ] All CI/CD checks are passing on the main branch
- [ ] Documentation is up to date (README.md, etc.)
- [ ] All PRs for the release are merged

### 2. Determine Version Number

Use [Semantic Versioning](https://semver.org/):

- **Major version (X.0.0)**: Breaking changes (API changes, removed features)
- **Minor version (0.X.0)**: New features (backward compatible)
- **Patch version (0.0.X)**: Bug fixes (backward compatible)

**Current version:** 2.1.0

**For this release (flexible mapping system):**
- Breaking changes: Configuration API changed
- Recommendation: **3.0.0** (major version bump)

### 3. Generate Release Notes from Git History

Instead of maintaining a CHANGELOG.md, we generate release notes from commit messages.

**Get commits since last release:**
```bash
# Get the last release tag
LAST_TAG=$(git describe --tags --abbrev=0)

# Generate release notes from commits
git log ${LAST_TAG}..HEAD --pretty=format:"- %s (%h)" --reverse
```

**Better formatted with categories:**
```bash
# Get commits since last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -z "$LAST_TAG" ]; then
  # No previous tag, get all commits
  git log --pretty=format:"%s" --reverse
else
  # Get commits since last tag
  echo "## Changes since ${LAST_TAG}"
  echo ""

  # Breaking changes
  echo "### Breaking Changes"
  git log ${LAST_TAG}..HEAD --grep="BREAKING" --pretty=format:"- %s (%h)" --reverse
  echo ""

  # Features
  echo "### Features"
  git log ${LAST_TAG}..HEAD --grep="^feat" --pretty=format:"- %s (%h)" --reverse
  echo ""

  # Bug fixes
  echo "### Bug Fixes"
  git log ${LAST_TAG}..HEAD --grep="^fix" --pretty=format:"- %s (%h)" --reverse
  echo ""

  # Other changes
  echo "### Other Changes"
  git log ${LAST_TAG}..HEAD --grep="^chore\|^docs\|^test\|^refactor" --pretty=format:"- %s (%h)" --reverse
fi
```

**Or use GitHub's auto-generate feature:**
When creating a release on GitHub, click "Generate release notes" button - it automatically creates notes from PRs and commits.

**Save the script (optional):**
```bash
# Save as scripts/generate-release-notes.sh
chmod +x scripts/generate-release-notes.sh
./scripts/generate-release-notes.sh > release-notes.md
```

### 4. Update Rockspec

Create a new rockspec file for the version:

```bash
# Copy the current rockspec
cp copy_with_context-2.1.0-1.rockspec copy_with_context-3.0.0-1.rockspec
```

Update `copy_with_context-3.0.0-1.rockspec`:

```lua
package = "copy_with_context"
version = "3.0.0-1"  -- Update version
source = {
    url = "git://github.com/zhisme/copy_with_context.nvim.git",
    tag = "v3.0.0"  -- Update tag
}
description = {
    summary = "A Neovim plugin for copying with context",
    detailed = [[
        Copy lines with file path and line number metadata.
        Supports flexible format strings and repository URL generation
        for GitHub, GitLab, and Bitbucket.
    ]],
    homepage = "https://github.com/zhisme/copy_with_context.nvim",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        ["copy_with_context"] = "lua/copy_with_context/init.lua",
        ["copy_with_context.config"] = "lua/copy_with_context/config.lua",
        ["copy_with_context.formatter"] = "lua/copy_with_context/formatter.lua",
        ["copy_with_context.git"] = "lua/copy_with_context/git.lua",
        ["copy_with_context.main"] = "lua/copy_with_context/main.lua",
        ["copy_with_context.url_builder"] = "lua/copy_with_context/url_builder.lua",
        ["copy_with_context.user_config_validation"] = "lua/copy_with_context/user_config_validation.lua",
        ["copy_with_context.utils"] = "lua/copy_with_context/utils.lua",
        ["copy_with_context.providers.init"] = "lua/copy_with_context/providers/init.lua",
        ["copy_with_context.providers.github"] = "lua/copy_with_context/providers/github.lua",
        ["copy_with_context.providers.gitlab"] = "lua/copy_with_context/providers/gitlab.lua",
        ["copy_with_context.providers.bitbucket"] = "lua/copy_with_context/providers/bitbucket.lua",
    }
}
```

**Note:** Removed `luacheck` and `busted` from dependencies (they're dev dependencies, not runtime).

### 5. Commit Version Updates

```bash
# Stage the changes
git add copy_with_context-3.0.0-1.rockspec Makefile

# Commit with conventional commit message
git commit -m "chore: bump version to 3.0.0"

# Push to main
git push origin main
```

### 6. Create Git Tag

```bash
# Create an annotated tag (recommended)
git tag -a v3.0.0 -m "Release v3.0.0: Flexible mapping system

Major changes:
- Flexible mapping system with custom format strings
- Support for nested groups in repository URLs
- Configuration validation
- Breaking changes to configuration API

See CHANGELOG.md for full details."

# Push the tag to GitHub
git push origin v3.0.0
```

### 7. Create GitHub Release

1. Go to https://github.com/zhisme/copy_with_context.nvim/releases
2. Click "Draft a new release"
3. Choose tag: `v3.0.0`
4. Release title: `v3.0.0 - Flexible Mapping System`
5. Click "Generate release notes" button (auto-generates from commits and PRs)
6. Edit/enhance the generated notes, or write a custom summary:

```markdown
# 🎉 v3.0.0 - Flexible Mapping System

This is a major release with breaking changes that introduces a flexible mapping system.

## ⚠️ Breaking Changes

**Configuration has changed!** Update your config:

### Before (v2.x)
```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY'
  },
  context_format = '# %s:%s',
  include_remote_url = true,
})
```

### After (v3.0)
```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY',
    remote = '<leader>cyU',  -- New: custom mappings!
  },
  formats = {
    default = '# {filepath}:{line}',
    remote = '# {remote_url}',
  },
})
```

## ✨ New Features

- 🎯 **Unlimited custom mappings** - Create as many format variations as you need
- 🔧 **Format variables** - `{filepath}`, `{line}`, `{linenumber}`, `{remote_url}`
- ✅ **Configuration validation** - Catch errors at setup time
- 🌳 **Nested groups support** - GitLab `team/subgroup/project` URLs now work

## 🐛 Bug Fixes

- Fixed GitLab nested groups parsing
- Fixed GitHub Enterprise nested paths
- Fixed Bitbucket nested project keys

## 📚 Documentation

See commit history for full details:
```bash
git log v2.1.0..v3.0.0 --oneline
```

## 🙏 Migration Guide

No migration needed if you're using default configuration. If you customized:
- Replace `context_format` with `formats.default`
- Replace `include_remote_url: true` with a custom mapping that includes `{remote_url}`

Full docs in [README.md](./README.md).
```

6. Check "Set as the latest release"
7. Click "Publish release"

### 8. Publish to LuaRocks (Optional)

If you want to publish to [LuaRocks](https://luarocks.org/):

```bash
# Install luarocks CLI if not already installed
# https://github.com/luarocks/luarocks/wiki/Download

# Upload the rockspec
luarocks upload copy_with_context-3.0.0-1.rockspec --api-key=YOUR_API_KEY
```

**Note:** You need a LuaRocks account and API key.

### 9. Post-Release

- [ ] Announce the release (if applicable):
  - Reddit: r/neovim
  - Twitter/X
  - Discord communities
- [ ] Update any external documentation
- [ ] Close the milestone (if using GitHub milestones)
- [ ] Update project board (if using GitHub projects)

## Quick Reference

### Version Bumping Rules

| Change Type | Example | Version Bump |
|-------------|---------|--------------|
| Breaking change | API change, removed config option | 2.1.0 → 3.0.0 |
| New feature | New mapping variable | 2.1.0 → 2.2.0 |
| Bug fix | Fix URL parsing | 2.1.0 → 2.1.1 |

### Rockspec Naming Convention

Format: `<package>-<version>-<revision>.rockspec`

- Package: `copy_with_context`
- Version: `3.0.0` (semantic version)
- Revision: `1` (increment if republishing same version with rockspec changes)

Example: `copy_with_context-3.0.0-1.rockspec`

### Tag Naming Convention

Format: `v<version>`

Examples:
- `v3.0.0` (release)
- `v3.0.0-rc.1` (release candidate)
- `v3.0.0-beta.1` (beta)

## Troubleshooting

### Tag already exists

```bash
# Delete local tag
git tag -d v3.0.0

# Delete remote tag
git push origin :refs/tags/v3.0.0

# Recreate tag
git tag -a v3.0.0 -m "Release v3.0.0"
git push origin v3.0.0
```

### Rockspec upload fails

```bash
# Validate rockspec locally
luarocks lint copy_with_context-3.0.0-1.rockspec

# Test local installation
luarocks make copy_with_context-3.0.0-1.rockspec
```

### Wrong version in Makefile

Update `Makefile` if it references the version:

```makefile
ROCKSPEC = copy_with_context-3.0.0-1.rockspec  # Update this
```

## Automation (Future)

Consider automating releases with GitHub Actions:

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
```

---

**Last Updated:** 2024-01-XX (update when creating releases)
