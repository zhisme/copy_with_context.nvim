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

  -- Get remote URL if needed (check if format uses {remote_url})
  local format_name = mapping_name
  if mapping_name == "relative" or mapping_name == "absolute" then
    format_name = "default"
  end

  local format_string = config.options.formats[format_name]
  local remote_url = nil

  -- Only fetch remote URL if format string uses it
  if format_string and format_string:match("{remote_url}") then
    remote_url = url_builder.build_url(file_path, start_lnum, end_lnum)
  end

  -- Build variables and format output
  local vars = formatter.get_variables(file_path, start_lnum, end_lnum, remote_url)
  local context = formatter.format(format_string, vars)

  -- Combine content and context
  local output = content .. "\n" .. context

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
