# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - TBD

### Added
- Flexible mapping system allowing unlimited custom mappings with unique keybindings
- Format string support with template variables: `{filepath}`, `{line}`, `{linenumber}`, `{remote_url}`
- Configuration validation module with clear error messages at setup time
- Support for nested groups in repository URLs (GitLab, GitHub, Bitbucket)
- New modules:
  - `user_config_validation.lua` - Validates configuration structure and format strings
  - `formatter.lua` - Handles variable replacement in format strings
  - `url_builder.lua` - Wrapper for git info gathering and URL generation
- Comprehensive test coverage (~100%) for all new modules
- Smart performance optimization: only fetches remote URL when format uses `{remote_url}`

### Changed
- **BREAKING**: Configuration structure completely redesigned
  - Replaced `context_format` string with `formats` table
  - Removed `include_remote_url` boolean flag
  - Format strings now use `{variable}` syntax instead of `%s` placeholders
- **BREAKING**: `main.copy_with_context()` signature changed from `(absolute_path, is_visual)` to `(mapping_name, is_visual)`
- Refactored `git.parse_remote_url()` to support any depth of nested paths
- Updated all provider URL builders to handle nested owner paths
- Simplified `utils.lua` by removing `format_output()` and `get_remote_url_line()`

### Fixed
- GitLab nested groups (e.g., `team/subgroup/project`) now parse correctly
- GitHub Enterprise URLs with nested organization paths now work
- Bitbucket nested project keys now supported
- URL parsing now handles HTTP (not just HTTPS) URLs
- Relative paths in `get_file_git_path()` now properly converted to absolute

### Removed
- **BREAKING**: `context_format` configuration option (use `formats.default` instead)
- **BREAKING**: `include_remote_url` boolean flag (use `{remote_url}` variable in custom formats)

### Migration Guide

**Before (v2.x):**
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

**After (v3.0):**
```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY',
    remote = '<leader>cyU',     -- Optional: custom mapping for URL only
    full = '<leader>cyF',        -- Optional: custom mapping with both
  },
  formats = {
    default = '# {filepath}:{line}',
    remote = '# {remote_url}',
    full = '# {filepath}:{line}\n# {remote_url}',
  },
})
```

## [2.1.0] - Previous Release

### Added
- Repository URL generation for GitHub, GitLab, and Bitbucket
- Git utilities module for repository detection
- Provider architecture for different git hosting platforms

### Changed
- Enhanced output with optional repository URLs
- Improved configuration options

### Fixed
- Various bug fixes and improvements

---

[Unreleased]: https://github.com/zhisme/copy_with_context.nvim/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/zhisme/copy_with_context.nvim/compare/v2.1.0...v3.0.0
[2.1.0]: https://github.com/zhisme/copy_with_context.nvim/releases/tag/v2.1.0
