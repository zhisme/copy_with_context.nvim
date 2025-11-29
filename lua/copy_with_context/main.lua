local M = {}

-- Generic copy function that works with any mapping
function M.copy_with_context(mapping_name, is_visual)
  local config = require("copy_with_context.config")
  local utils = require("copy_with_context.utils")
  local formatter = require("copy_with_context.formatter")
  local url_builder = require("copy_with_context.url_builder")

  -- Get lines and line numbers
  local lines, start_lnum, end_lnum = utils.get_lines(is_visual)
  local content = table.concat(utils.process_lines(lines), "\n")

  -- Determine file path based on mapping type
  local file_path
  if mapping_name == "relative" then
    file_path = utils.get_file_path(false)
  elseif mapping_name == "absolute" then
    file_path = utils.get_file_path(true)
  else
    -- For custom mappings, default to relative path
    file_path = utils.get_file_path(false)
  end

  -- Determine format name (relative/absolute use "default")
  local format_name = mapping_name
  if mapping_name == "relative" or mapping_name == "absolute" then
    format_name = "default"
  end

  -- Get format string (output_formats takes precedence over formats)
  local output_format = config.options.output_formats and config.options.output_formats[format_name]
  local format = config.options.formats and config.options.formats[format_name]
  local format_string = output_format or format

  -- Get remote URL if needed (check if format uses {remote_url})
  local remote_url = nil
  if format_string and format_string:match("{remote_url}") then
    remote_url = url_builder.build_url(file_path, start_lnum, end_lnum)
  end

  -- Build variables (include code for full output control)
  local vars = formatter.get_variables(file_path, start_lnum, end_lnum, remote_url, content)

  -- Generate output based on format type
  local output
  if output_format then
    -- New full output format - formatter controls entire output
    output = formatter.format(output_format, vars)
  elseif format then
    -- format - auto-prepend code with newline
    local context = formatter.format(format, vars)
    output = content .. "\n" .. context
  else
    -- Fallback if no format found
    output = content
  end

  utils.copy_to_clipboard(output)

  vim.api.nvim_echo(
    { { string.format("Copied %s with context", is_visual and "selection" or "line"), "None" } },
    false,
    {}
  )
end

function M.setup()
  local config = require("copy_with_context.config")

  -- Set up keymaps for all defined mappings
  for mapping_name, keymap in pairs(config.options.mappings) do
    -- Normal mode mapping
    vim.keymap.set("n", keymap, function()
      M.copy_with_context(mapping_name, false)
    end, { silent = false })

    -- Visual mode mapping
    vim.keymap.set(
      "x",
      keymap,
      string.format(
        ':<C-u>lua require("copy_with_context.main").copy_with_context("%s", true)<CR>',
        mapping_name
      ),
      { silent = true }
    )
  end
end

return M
