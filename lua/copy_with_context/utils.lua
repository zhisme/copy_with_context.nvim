-- utility functions

local M = {}

function M.get_lines(is_visual)
  local lines, start_lnum, end_lnum

  if is_visual then
    start_lnum = vim.fn.line("'<")
    end_lnum = vim.fn.line("'>")
    lines = vim.fn.getline(start_lnum, end_lnum)
  else
    start_lnum = vim.fn.line(".")
    end_lnum = start_lnum
    lines = { vim.fn.getline(".") }
  end

  return lines, start_lnum, end_lnum
end

function M.get_file_path(absolute)
  return absolute and vim.fn.expand("%:p") or vim.fn.expand("%")
end

function M.format_line_range(start_line, end_line)
  return start_line == end_line and tostring(start_line)
    or string.format("%d-%d", start_line, end_line)
end

function M.process_lines(lines)
  local config = require("copy_with_context.config")
  local processed = {}

  for _, line in ipairs(lines) do
    if config.options.trim_lines then
      table.insert(processed, vim.fn.trim(line))
    else
      table.insert(processed, line)
    end
  end

  return processed
end

function M.copy_to_clipboard(output)
  vim.fn.setreg("*", output)
  vim.fn.setreg("+", output)
end

-- Get remote URL line for the given file and line range
-- Returns: "# {url}" or nil if not available
function M.get_remote_url_line(file_path, line_start, line_end)
  local config = require("copy_with_context.config")

  -- Check if remote URL feature is enabled
  if not config.options.include_remote_url then
    return nil
  end

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
  if not url then
    return nil
  end

  return "# " .. url
end

function M.format_output(content, file_path, line_range)
  local config = require("copy_with_context.config")
  local comment_line = string.format(config.options.context_format, file_path, line_range)

  -- Try to get remote URL line
  local url_line = nil
  if config.options.include_remote_url then
    -- Extract line numbers from line_range
    local line_start, line_end
    if line_range:match("-") then
      line_start, line_end = line_range:match("(%d+)%-(%d+)")
      line_start = tonumber(line_start)
      line_end = tonumber(line_end)
    else
      line_start = tonumber(line_range)
      line_end = line_start
    end

    if line_start and line_end then
      url_line = M.get_remote_url_line(file_path, line_start, line_end)
    end
  end

  if url_line then
    return string.format("%s\n%s\n%s", content, comment_line, url_line)
  else
    return string.format("%s\n%s", content, comment_line)
  end
end

return M
