package = "copy_with_context"
version = "3.1.0-1"
source = {
  url = "git://github.com/zhisme/copy_with_context.nvim.git",
  tag = "v3.1.0",
}
description = {
  summary = "A Neovim plugin for copying code with context",
  detailed = [[
    Copy lines with file path and line number metadata.
    Supports flexible format strings with custom variables and
    repository URL generation for GitHub, GitLab, and Bitbucket.

    Features:
    - Unlimited custom mappings with unique formats
    - Template variables: {filepath}, {line}, {remote_url}
    - Repository URL support with commit SHAs
    - Works with nested groups (GitLab, GitHub, Bitbucket)
  ]],
  homepage = "https://github.com/zhisme/copy_with_context.nvim",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1",
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
  },
}
