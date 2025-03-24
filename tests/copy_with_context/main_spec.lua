_G.vim = {
  api = {
    nvim_echo = function() end,
  },
  keymap = {
    set = function() end,
  },
}

local mock = require("luassert.mock")
local stub = require("luassert.stub")

-- Reload module to avoid cached state
package.loaded["copy_with_context.main"] = nil
package.loaded["copy_with_context.utils"] = nil
package.loaded["copy_with_context.config"] = nil

local main = require("copy_with_context.main")
local utils = require("copy_with_context.utils")
local config = require("copy_with_context.config")

describe("Main Module", function()
  before_each(function()
    -- Mock dependencies
    stub(utils, "get_lines").returns({ "line 1", "line 2" }, 1, 2)
    stub(utils, "process_lines").returns({ "line 1", "line 2" })
    stub(utils, "get_file_path").returns("/fake/path.lua")
    stub(utils, "format_line_range").returns("1-2")
    stub(utils, "format_output").returns("Processed output")
    stub(utils, "copy_to_clipboard")
    stub(vim.api, "nvim_echo")
    stub(vim.keymap, "set")
  end)

  after_each(function()
    -- Restore all mocked functions
    utils.get_lines:revert()
    utils.process_lines:revert()
    utils.get_file_path:revert()
    utils.format_line_range:revert()
    utils.format_output:revert()
    utils.copy_to_clipboard:revert()
    vim.api.nvim_echo:revert()
    vim.keymap.set:revert()
  end)

  it("copies content with context (relative path, non-visual mode)", function()
    main.copy_with_context(false, false)

    assert.stub(utils.get_lines).was_called_with(false)
    assert.stub(utils.process_lines).was_called_with({ "line 1", "line 2" })
    assert.stub(utils.get_file_path).was_called_with(false)
    assert.stub(utils.format_line_range).was_called_with(1, 2)
    assert.stub(utils.format_output).was_called_with("line 1\nline 2", "/fake/path.lua", "1-2")
    assert.stub(utils.copy_to_clipboard).was_called_with("Processed output", vim_echo)
    assert.stub(vim.api.nvim_echo).was_called()
  end)

  it("copies content with context (absolute path, visual mode)", function()
    main.copy_with_context(true, true)

    assert.stub(utils.get_lines).was_called_with(true)
    assert.stub(utils.get_file_path).was_called_with(true)
    assert.stub(utils.format_output).was_called()
    assert.stub(utils.copy_to_clipboard).was_called()
    assert.stub(vim.api.nvim_echo).was_called()
  end)

  it("sets up key mappings", function()
    main.setup()

    assert
      .stub(vim.keymap.set)
      .was_called_with("n", config.options.mappings.relative, match._, { silent = false })
    assert
      .stub(vim.keymap.set)
      .was_called_with("n", config.options.mappings.absolute, match._, { silent = false })
    assert
      .stub(vim.keymap.set)
      .was_called_with("x", config.options.mappings.relative, match._, { silent = true })
    assert
      .stub(vim.keymap.set)
      .was_called_with("x", config.options.mappings.absolute, match._, { silent = true })
  end)
end)
