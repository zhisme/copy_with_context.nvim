local M = {}

function M.copy_with_context(absolute_path, is_visual)
  local utils = require("copy_with_context.utils")
  local config = require("copy_with_context.config")

  local lines, start_lnum, end_lnum = utils.get_lines(is_visual)
  local content = table.concat(utils.process_lines(lines), "\n")

  local output = utils.format_output(
    content,
    utils.get_file_path(absolute_path),
    utils.format_line_range(start_lnum, end_lnum)
  )

  utils.copy_to_clipboard(output, vim_echo)

  vim.api.nvim_echo(
    { { string.format("Copied %s with context", is_visual and "selection" or "line"), "None" } },
    false,
    {}
  )
end

function M.setup()
  local config = require("copy_with_context.config")

  -- Apply mappings
  vim.keymap.set("n", config.options.mappings.relative, function()
    M.copy_with_context(false, false)
  end, { silent = false })
  vim.keymap.set("n", config.options.mappings.absolute, function()
    M.copy_with_context(true, false)
  end, { silent = false })
  vim.keymap.set(
    "x",
    config.options.mappings.relative,
    ':<C-u>lua require("copy_with_context.main").copy_with_context(false, true)<CR>',
    { silent = true }
  )
  vim.keymap.set(
    "x",
    config.options.mappings.absolute,
    ':<C-u>lua require("copy_with_context.main").copy_with_context(true, true)<CR>',
    { silent = true }
  )
end

return M
