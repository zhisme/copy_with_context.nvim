local M = {}

-- Default configuration
M.options = {
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY'
  },
  trim_lines = true,
}

-- Setup function to merge user config with defaults
function M.setup(opts)
  if opts then
    M.options = vim.tbl_deep_extend('force', M.options, opts)
  end
end

return M
