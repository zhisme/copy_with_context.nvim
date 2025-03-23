package = "copy_with_context"
version = "2.1.0-1"
source = {
    url = "git://github.com/zhisme/copy_with_context.nvim.git",
    tag = "v2.1.0"
}
description = {
    summary = "A Neovim plugin for copying with context",
    detailed = [[Copy lines with file path and line number metadata. Perfect for sharing code snippets with context.]],
    homepage = "https://github.com/zhisme/copy_with_context.nvim",
    license = "MIT"
}
dependencies = {
    "luacheck >= 0.25.0",
    "busted >= 2.0.0",
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        ["copy_with_context"] = "lua/copy_with_context/init.lua",
    }
}
