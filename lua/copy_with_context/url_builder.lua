-- URL builder module for generating repository URLs

local M = {}

-- Build a repository URL for the given file and line range
-- @param file_path string File path (relative or absolute)
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @return string|nil Repository URL or nil if not available
function M.build_url(file_path, line_start, line_end)
  -- Get git info
  local git = require("copy_with_context.git")
  local git_info = git.get_git_info(file_path)
  if not git_info then
    return nil
  end

  -- Get provider
  local providers = require("copy_with_context.providers")
  local provider = providers.get_provider(git_info)
  if not provider then
    return nil
  end

  -- Build URL
  local url = provider.build_url(git_info, line_start, line_end)
  return url
end

return M
