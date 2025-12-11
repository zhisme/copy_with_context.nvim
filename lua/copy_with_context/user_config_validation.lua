-- User configuration validation module

local M = {}

-- Validate that mappings and formats match
-- @param config table User configuration
-- @return boolean, string|nil Success status and error message
function M.validate(config)
  if not config then
    return true, nil
  end

  local mappings = config.mappings or {}
  local formats = config.formats or {}
  local output_formats = config.output_formats or {}

  -- Special cases that map to "default" format
  local default_mappings = {
    relative = true,
    absolute = true,
  }

  -- Check: every mapping must have a format (in either formats or output_formats)
  for mapping_name, _ in pairs(mappings) do
    -- relative/absolute use "default" format
    if default_mappings[mapping_name] then
      if not formats.default and not output_formats.default then
        return false,
          string.format(
            "Mapping '%s' requires 'formats.default' or 'output_formats.default' to be defined",
            mapping_name
          )
      end
    else
      -- All other mappings need matching format in either formats or output_formats
      if not formats[mapping_name] and not output_formats[mapping_name] then
        return false,
          string.format(
            "Mapping '%s' has no matching format. Add 'formats.%s' or 'output_formats.%s'",
            mapping_name,
            mapping_name,
            mapping_name
          )
      end
    end
  end

  -- Check: every format (except default) should have a mapping
  for format_name, _ in pairs(formats) do
    if format_name ~= "default" then
      if not mappings[format_name] then
        return false,
          string.format(
            "Format '%s' has no matching mapping. Add 'mappings.%s' or remove the format",
            format_name,
            format_name
          )
      end
    end
  end

  -- Check: every output_format (except default) should have a mapping
  for format_name, _ in pairs(output_formats) do
    if format_name ~= "default" then
      if not mappings[format_name] then
        return false,
          string.format(
            "Output format '%s' has no matching mapping. Add 'mappings.%s' or remove the output_format",
            format_name,
            format_name
          )
      end
    end
  end

  return true, nil
end

-- Validate format string has valid variables
-- @param format_string string Format string to validate
-- @param _is_output_format boolean Whether this is an output_format (reserved for future use)
-- @return boolean, string|nil Success status and error message
function M.validate_format_string(format_string, _is_output_format)
  if not format_string then
    return false, "Format string cannot be nil"
  end

  local valid_vars = {
    filepath = true,
    line = true,
    linenumber = true,
    remote_url = true,
    copied_text = true,
  }

  -- Extract all variables from format string
  for var in format_string:gmatch("{([^}]+)}") do
    if not valid_vars[var] then
      return false,
        string.format(
          "Unknown variable '{%s}'. Valid: filepath, line, linenumber, remote_url, copied_text",
          var
        )
    end
  end

  return true, nil
end

return M
