-- URL builder module for generating repository URLs and line fragments

local M = {}

-- Build a repository URL for the given file and line range
-- @param file_path string File path (relative or absolute)
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @return string|nil Repository URL or nil if not available
function M.build_url(file_path, line_start, line_end)
  local git = require("copy_with_context.git")
  local git_info = git.get_git_info(file_path)
  if not git_info then
    return nil
  end

  local providers = require("copy_with_context.providers")
  local provider = providers.get_provider(git_info)
  if not provider then
    return nil
  end

  local url = provider.build_url(git_info, line_start, line_end)
  return url
end

-- Get a provider-specific line fragment for the given file and line range
-- Falls back to GitHub-style (L5 / L5-L8) when no git/provider is detected
-- @param file_path string File path (relative or absolute)
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @return string Line fragment (e.g., "L5", "L5-L8", "L5-8", or "lines-5:8")
function M.get_line_fragment(file_path, line_start, line_end)
  local git = require("copy_with_context.git")
  local git_info = git.get_git_info(file_path)
  if git_info then
    local providers = require("copy_with_context.providers")
    local provider = providers.get_provider(git_info)
    if provider and provider.line_fragment then
      return provider.line_fragment(line_start, line_end)
    end
  end

  -- Fallback: GitHub-style fragment
  if line_end and line_end ~= line_start then
    return string.format("L%d-L%d", line_start, line_end)
  else
    return "L" .. tostring(line_start)
  end
end

return M
