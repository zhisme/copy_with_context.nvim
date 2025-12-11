-- Formatter module for variable replacement in format strings

local M = {}

-- Build variables table from file and line information
-- @param file_path string File path to use
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @param remote_url string|nil Remote repository URL (nil if not available)
-- @param copied_text string|nil Copied text content (visual selection or current line)
-- @return table Variables table
function M.get_variables(file_path, line_start, line_end, remote_url, copied_text)
  local line_range
  if line_end and line_end ~= line_start then
    line_range = string.format("%d-%d", line_start, line_end)
  else
    line_range = tostring(line_start)
  end

  return {
    filepath = file_path,
    line = line_range,
    linenumber = line_range, -- alias for 'line'
    remote_url = remote_url or "",
    copied_text = copied_text or "",
  }
end

-- Replace {variable} placeholders in format string with actual values
-- @param format_string string Format string with {variable} placeholders
-- @param vars table Variables table (from get_variables)
-- @return string Formatted string with variables replaced
function M.format(format_string, vars)
  if not format_string then
    return ""
  end

  -- Replace each {variable} with its value
  local result = format_string:gsub("{([^}]+)}", function(var_name)
    local value = vars[var_name]
    if value == nil then
      -- Return placeholder unchanged if variable not found
      return "{" .. var_name .. "}"
    end
    return tostring(value)
  end)

  return result
end

return M
