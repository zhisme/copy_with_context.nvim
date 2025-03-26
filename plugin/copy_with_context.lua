-- Plugin: Copy With Context
-- Author: Evgeny Zhdanov evdev34@gmail.com
-- Description: Copy lines with file path and line number context

-- luacheck: globals vim
if vim.g.loaded_copy_with_context == 1 then
  return
end

-- luacheck: ignore 5 11
vim.g.loaded_copy_with_context = 1

require('copy_with_context').setup()
