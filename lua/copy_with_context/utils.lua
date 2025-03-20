-- utility functions

local M = {}

function M.get_lines(is_visual)
  local lines, start_lnum, end_lnum

  if is_visual then
    start_lnum = vim.fn.line("'<")
    end_lnum = vim.fn.line("'>")
    lines = vim.fn.getline(start_lnum, end_lnum)
  else
    start_lnum = vim.fn.line('.')
    end_lnum = start_lnum
    lines = {vim.fn.getline('.')}
  end

  return lines, start_lnum, end_lnum
end

function M.get_file_path(absolute)
  return absolute and vim.fn.expand('%:p') or vim.fn.expand('%')
end

function M.format_line_range(start_line, end_line)
  return start_line == end_line and tostring(start_line) or string.format("%d-%d", start_line, end_line)
end

function M.process_lines(lines)
  local config = require('copy_with_context.config')
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

function M.copy_to_clipboard(output, echo_text)
  vim.fn.setreg('*', output)
  vim.fn.setreg('+', output)
end

function M.format_output(content, file_path, line_range)
  local comment_line = string.format('# %s:%s', file_path, line_range)

  return string.format("%s\n%s", content, comment_line)
end

return M
