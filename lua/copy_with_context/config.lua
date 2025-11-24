local user_config_validation = require("copy_with_context.user_config_validation")

local M = {}

-- Default configuration
M.options = {
  mappings = {
    relative = "<leader>cy",
    absolute = "<leader>cY",
  },
  formats = {
    default = "# {filepath}:{line}",
  },
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

  -- Validate each format string
  for format_name, format_string in pairs(M.options.formats or {}) do
    local format_valid, format_err = user_config_validation.validate_format_string(format_string)
    if not format_valid then
      error(string.format("Invalid format '%s': %s", format_name, format_err))
    end
  end
end

return M
