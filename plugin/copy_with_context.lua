-- Plugin: Copy With Context
-- Author: Evgeny Zhdanov evdev34@gmail.com
-- Description: Copy lines with file path and line number context

if vim.g.loaded_copy_with_context == 1 then
  return
end
vim.g.loaded_copy_with_context = 1

require('copy_with_context').setup()
