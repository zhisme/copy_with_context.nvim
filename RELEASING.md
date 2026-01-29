# Release Guide

This guide covers the process for releasing a new version of `copy_with_context.nvim`.

## Prerequisites

- Write access to the repository
- [LuaRocks](https://luarocks.org/) account (optional, for publishing to LuaRocks)
- Familiarity with [Semantic Versioning](https://semver.org/)
- All CI checks passing on main branch

## Release Checklist

### 1. Pre-Release Verification

Before starting the release process, ensure:

- [ ] All tests pass: `make test`
- [ ] No linting errors: `make lint`
- [ ] Code is formatted: `make fmt-check`
- [ ] All CI/CD checks are passing on the main branch
- [ ] Documentation is up to date (README.md)
- [ ] All planned features/fixes for the release are merged

### 2. Determine Version Number

Follow [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH):

- **Major version (X.0.0)**: Breaking changes
  - API changes
  - Removed features
  - Configuration structure changes

- **Minor version (0.X.0)**: New features (backward compatible)
  - New functionality
  - New configuration options
  - Performance improvements

- **Patch version (0.0.X)**: Bug fixes (backward compatible)
  - Bug fixes
  - Documentation updates
  - Internal refactoring

**Examples:**
- `2.1.0` → `3.0.0` (breaking change: API redesign)
- `2.1.0` → `2.2.0` (new feature: added format variables)
- `2.1.0` → `2.1.1` (bug fix: fixed URL parsing)

### 3. Generate Release Notes

Use git commit history to generate release notes instead of maintaining a CHANGELOG.md file.

**Quick method:**
```bash
# Get commits since last release
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

**Categorized method (recommended):**
```bash
# Use the provided script
./scripts/generate-release-notes.sh > release-notes.md

# Or specify a tag to compare against
./scripts/generate-release-notes.sh v2.0.0 > release-notes.md
```

**GitHub auto-generate:**
When creating a release on GitHub, click **"Generate release notes"** button. GitHub will automatically create notes from PRs and commits.

The `scripts/generate-release-notes.sh` script categorizes commits by type:
- ⚠️ Breaking Changes (commits with "BREAKING")
- ✨ Features (commits starting with "feat")
- 🐛 Bug Fixes (commits starting with "fix")
- ♻️ Refactoring (commits starting with "refactor")
- 📚 Documentation (commits starting with "docs")
- ✅ Tests (commits starting with "test")
- 🔧 Maintenance (commits starting with "chore")

### 4. Update Rockspec

Create a new rockspec file for the version:

```bash
# Determine new version (e.g., 3.0.0)
NEW_VERSION="3.0.0"
OLD_VERSION=$(ls copy_with_context-*.rockspec | head -1 | sed 's/copy_with_context-\(.*\)\.rockspec/\1/')

# Copy the current rockspec
cp copy_with_context-${OLD_VERSION}.rockspec copy_with_context-${NEW_VERSION}-1.rockspec
```

Edit `copy_with_context-${NEW_VERSION}.rockspec`:

```lua
package = "copy_with_context"
version = "X.Y.Z-1"  -- Update this
source = {
  url = "git://github.com/zhisme/copy_with_context.nvim.git",
  tag = "vX.Y.Z",  -- Update this
}
-- ... rest of the file
```

**Important:**
- Update `version` field to match new version
- Update `tag` field to match new version (with `v` prefix)
- Verify all modules are listed in `build.modules` if you added new files
- Dependencies should only include runtime dependencies (not luacheck, busted, etc.)

### 5. Commit Version Bump

```bash
# Stage the changes
git add copy_with_context-*.rockspec

# Commit with conventional commit message
git commit -m "chore: bump version to X.Y.Z"

# Push to main
git push origin main
```

### 6. Create Git Tag

```bash
# Create an annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z

Brief description of major changes in this release.

Breaking changes (if any):
- List breaking changes here

New features:
- List new features here

Bug fixes:
- List bug fixes here
"

# Verify the tag
git tag -n9 vX.Y.Z

# Push the tag to GitHub
git push origin vX.Y.Z
```

**Tag naming convention:**
- Format: `vMAJOR.MINOR.PATCH`
- Examples: `v3.0.0`, `v2.1.5`, `v1.0.0-rc.1`

### 7. Create GitHub Release

1. Go to https://github.com/zhisme/copy_with_context.nvim/releases
2. Click **"Draft a new release"**
3. **Choose tag:** Select the tag you just pushed (e.g., `v3.0.0`)
4. **Release title:** Format: `vX.Y.Z - Brief Description`
   - Examples:
     - `v3.0.0 - Flexible Mapping System`
     - `v2.1.0 - Repository URL Support`
     - `v2.0.1 - Bug Fixes`
5. **Description:**
   - Click **"Generate release notes"** button (recommended)
   - Or paste from `release-notes.md` generated in step 3
   - Or write manually using this template:

```markdown
# 🎉 vX.Y.Z - Release Title

Brief summary of what this release is about.

## ⚠️ Breaking Changes

**If this is a major version (X.0.0), list breaking changes:**
- Configuration change: explain what changed
- API change: explain what changed

**Migration guide:**
- Step-by-step instructions for users to upgrade

## ✨ New Features

- Feature 1: description
- Feature 2: description

## 🐛 Bug Fixes

- Fix 1: description
- Fix 2: description

## 📚 Documentation

See commit history for full details:
```bash
git log vPREV..vX.Y.Z --oneline
```

Full documentation: [README.md](./README.md)
```

6. Check **"Set as the latest release"** (unless it's a pre-release)
7. Click **"Publish release"**

### 8. Publish to LuaRocks (Optional)

If you want to publish to [LuaRocks](https://luarocks.org/):

```bash
# Install luarocks CLI if not already installed
# See: https://github.com/luarocks/luarocks/wiki/Download

# Upload the rockspec
luarocks upload copy_with_context-X.Y.Z-1.rockspec --api-key YOUR_API_KEY
```

**Note:** You need a LuaRocks account and to be a maintainer of the package.

### 9. Post-Release Tasks

- [ ] Verify the release appears on GitHub Releases page
- [ ] Verify the tag is visible: `git tag -l`
- [ ] Test installation from the new tag:
  ```bash
  # In a test environment
  cd /tmp
  git clone https://github.com/zhisme/copy_with_context.nvim.git
  cd copy_with_context.nvim
  git checkout vX.Y.Z
  make test
  ```
- [ ] (Optional) Announce the release:
  - Reddit: r/neovim
  - Twitter/X
  - Discord communities
- [ ] Close the milestone (if using GitHub milestones)

## Quick Reference

### Version Bumping Rules

| Change Type | Example | Current | New Version |
|-------------|---------|---------|-------------|
| Breaking change | API redesign, config structure change | 2.1.0 | 3.0.0 |
| New feature | Add format variables | 2.1.0 | 2.2.0 |
| Bug fix | Fix URL parsing | 2.1.0 | 2.1.1 |
| Multiple bug fixes | Several small fixes | 2.1.0 | 2.1.1 |
| Feature + bug fix | Both in one release | 2.1.0 | 2.2.0 |

### Rockspec Naming Convention

Format: `<package>-<version>-<revision>.rockspec`

- **Package:** `copy_with_context`
- **Version:** Semantic version (e.g., `3.0.0`)
- **Revision:** Usually `1` (increment if republishing same version with rockspec-only changes)

Examples:
- `copy_with_context-3.0.0-1.rockspec` (first release of 3.0.0)
- `copy_with_context-3.0.0-2.rockspec` (rockspec fix for 3.0.0)

### Tag Naming Convention

Format: `v<version>`

Examples:
- `v3.0.0` (stable release)
- `v3.0.0-rc.1` (release candidate)
- `v3.0.0-beta.1` (beta release)
- `v3.0.0-alpha.1` (alpha release)

### Conventional Commit Prefixes

Used for categorizing commits in release notes:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Test updates
- `perf:` - Performance improvements

## Troubleshooting

### Tag Already Exists

```bash
# Delete local tag
git tag -d vX.Y.Z

# Delete remote tag
git push origin :refs/tags/vX.Y.Z

# Recreate tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

### Rockspec Validation Fails

```bash
# Validate rockspec locally
luarocks lint copy_with_context-X.Y.Z-1.rockspec

# Test local installation
luarocks make copy_with_context-X.Y.Z-1.rockspec
```

### Release Notes Script Not Working

```bash
# Make sure script is executable
chmod +x scripts/generate-release-notes.sh

# Run with bash explicitly
bash scripts/generate-release-notes.sh

# Check if git tags exist
git tag -l
```

### GitHub Release Not Showing Up

- Ensure the tag was pushed: `git ls-remote --tags origin`
- Check if CI is passing for the tag
- Verify you have write access to the repository

## Automation

The release process is partially automated with GitHub Actions (`.github/workflows/release.yml`):

- ✅ Automatically creates GitHub releases when tags are pushed
- ✅ Runs tests before releasing
- ✅ Validates rockspec before releasing
- ✅ Auto-generates release notes from commits
- ❌ Publishing to LuaRocks (still manual - see step 8)

## Additional Resources

- [Semantic Versioning](https://semver.org/)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [LuaRocks Documentation](https://github.com/luarocks/luarocks/wiki)
- [Conventional Commits](https://www.conventionalcommits.org/)
