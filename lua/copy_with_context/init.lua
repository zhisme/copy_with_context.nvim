-- Plugin: Copy With Context
-- Author: Evgeny Zhdanov evdev34@gmail.com
-- Description: Copy lines with file path and line number context

local M = {}

function M.setup(opts)
  local config = require('copy_with_context.config')
  config.setup(opts)

  local main = require('copy_with_context.main')
  main.setup()

  return M
end

return M
