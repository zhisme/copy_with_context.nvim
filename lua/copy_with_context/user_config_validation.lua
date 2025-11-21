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

  -- Special cases that map to "default" format
  local default_mappings = {
    relative = true,
    absolute = true,
  }

  -- Check: every mapping must have a format
  for mapping_name, _ in pairs(mappings) do
    -- relative/absolute use "default" format
    if default_mappings[mapping_name] then
      if not formats.default then
        return false,
          string.format("Mapping '%s' requires 'formats.default' to be defined", mapping_name)
      end
    else
      -- All other mappings need matching format
      if not formats[mapping_name] then
        return false,
          string.format(
            "Mapping '%s' has no matching format. Add 'formats.%s'",
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

  return true, nil
end

-- Validate format string has valid variables
-- @param format_string string Format string to validate
-- @return boolean, string|nil Success status and error message
function M.validate_format_string(format_string)
  if not format_string then
    return false, "Format string cannot be nil"
  end

  local valid_vars = {
    filepath = true,
    line = true,
    linenumber = true,
    remote_url = true,
  }

  -- Extract all variables from format string
  for var in format_string:gmatch("{([^}]+)}") do
    if not valid_vars[var] then
      return false,
        string.format(
          "Unknown variable '{%s}' in format string. Valid variables: filepath, line, linenumber, remote_url",
          var
        )
    end
  end

  return true, nil
end

return M
