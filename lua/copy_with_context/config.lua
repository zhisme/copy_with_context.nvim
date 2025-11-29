local user_config_validation = require("copy_with_context.user_config_validation")

local M = {}

-- Default configuration
M.options = {
  mappings = {
    relative = "<leader>cy",
    absolute = "<leader>cY",
  },
  -- Legacy formats: code is automatically prepended with a newline
  formats = {
    default = "# {filepath}:{line}",
  },
  -- Full output formats: use {code} token for complete control over output
  -- Example: output_formats = { default = "{code}\n\n# {filepath}:{line}" }
  output_formats = {},
  trim_lines = false,
}

-- Setup function to merge user config with defaults
function M.setup(opts)
  if opts then
    M.options = vim.tbl_deep_extend("force", M.options, opts)
  end

  -- Validate configuration
  local valid, err = user_config_validation.validate(M.options)
  if not valid then
    error(string.format("Invalid configuration: %s", err))
  end

  -- Validate each legacy format string (is_output_format = false)
  for format_name, format_string in pairs(M.options.formats or {}) do
    local format_valid, format_err = user_config_validation.validate_format_string(format_string, false)
    if not format_valid then
      error(string.format("Invalid format '%s': %s", format_name, format_err))
    end
  end

  -- Validate each output_format string (is_output_format = true, requires {code})
  for format_name, format_string in pairs(M.options.output_formats or {}) do
    local format_valid, format_err = user_config_validation.validate_format_string(format_string, true)
    if not format_valid then
      error(string.format("Invalid output_format '%s': %s", format_name, format_err))
    end
  end
end

return M
