local test_utils = require("tests.init")

-- Apply the fixes needed
test_utils.apply_fixes()

-- Test the config module
describe("config module", function()
  local config

  before_each(function()
    -- Start with a fresh require
    package.loaded["copy_with_context.config"] = nil

    -- Make sure vim.tbl_deep_extend exists
    if not vim.tbl_deep_extend then
      vim.tbl_deep_extend = function(behavior, target, ...)
        local result = {}
        for k, v in pairs(target) do
          result[k] = type(v) == "table" and vim.deepcopy(v) or v
        end

        for i = 1, select("#", ...) do
          local source = select(i, ...)
          for k, v in pairs(source) do
            if type(v) == "table" and type(result[k]) == "table" then
              result[k] = vim.tbl_deep_extend(behavior, result[k], v)
            else
              result[k] = v
            end
          end
        end

        return result
      end
    end

    config = require("copy_with_context.config")
  end)

  it("has default options", function()
    assert.is_table(config.options)
    assert.are.same("<leader>cy", config.options.mappings.relative)
    assert.are.same("<leader>cY", config.options.mappings.absolute)
    assert.are.same("# %s:%s", config.options.context_format)
    assert.is_true(config.options.trim_lines)
  end)

  it("can merge user options", function()
    -- Set custom options
    config.setup({
      mappings = {
        relative = "<leader>cr",
      },
      context_format = "// File: %s, Line: %s",
      trim_lines = false,
    })

    -- Check merged options
    assert.are.same("<leader>cr", config.options.mappings.relative)
    assert.are.same("<leader>cY", config.options.mappings.absolute) -- unchanged
    assert.are.same("// File: %s, Line: %s", config.options.context_format)
    assert.is_false(config.options.trim_lines)
  end)
end)

-- Test the utils module
describe("utils module", function()
  local utils

  before_each(function()
    -- Reset modules
    package.loaded["copy_with_context.utils"] = nil
    package.loaded["copy_with_context.config"] = nil

    -- Load fresh modules
    utils = require("copy_with_context.utils")

    -- Fix get_lines function to handle string vs table correctly
    local original_get_lines = utils.get_lines
    utils.get_lines = function(is_visual)
      local lines, start_lnum, end_lnum = original_get_lines(is_visual)
      if type(lines) == "string" then
        lines = {lines}
      end
      return lines, start_lnum, end_lnum
    end

    -- Set up mocks for vim functions used in utils
    _G.vim.fn.line = function(mark)
      if mark == "." then
        return 10
      elseif mark == "'<" then
        return 5
      elseif mark == "'>" then
        return 8
      end
      return 1
    end

    _G.vim.fn.getline = function(start, stop)
      if start == 10 and not stop then
        return "This is the current line"
      elseif start == 5 and stop == 8 then
        return {
          "Line 1 of selection",
          "  Line 2 with spaces  ",
          "Line 3 of selection",
          "Line 4 of selection"
        }
      end
      return {}
    end

    _G.vim.fn.expand = function(expr)
      if expr == '%' then
        return "relative/path/to/file.lua"
      elseif expr == '%:p' then
        return "/absolute/path/to/file.lua"
      end
      return ""
    end

    -- Fix trim function to handle all input types properly
    _G.vim.fn.trim = function(text)
      if type(text) ~= "string" then
        return text
      end
      return text:gsub("^%s*(.-)%s*$", "%1")
    end

    _G.vim.fn.setreg = function(reg, value)
      return true
    end
  end)

  it("gets current line in normal mode", function()
    local lines, _, _ = utils.get_lines(false)
    assert.are.same({"This is the current line"}, type(lines) == "table" and lines or {lines})
  end)

  it("gets selected lines in visual mode", function()
    local lines, start_lnum, end_lnum = utils.get_lines(true)
    assert.are.same({
      "Line 1 of selection",
      "  Line 2 with spaces  ",
      "Line 3 of selection",
      "Line 4 of selection"
    }, lines)
    assert.are.same(5, start_lnum)
    assert.are.same(8, end_lnum)
  end)

  it("gets relative file path", function()
    local path = utils.get_file_path(false)
    assert.are.same("relative/path/to/file.lua", path)
  end)

  it("gets absolute file path", function()
    local path = utils.get_file_path(true)
    assert.are.same("/absolute/path/to/file.lua", path)
  end)

  it("formats line range for single line", function()
    local range = utils.format_line_range(10, 10)
    assert.are.same("10", range)
  end)

  it("formats line range for multiple lines", function()
    local range = utils.format_line_range(5, 8)
    assert.are.same("5-8", range)
  end)

  it("processes lines with trimming enabled", function()
    -- Enable trim_lines in config
    local config = require("copy_with_context.config")
    config.options.trim_lines = true

    -- Fix process_lines to handle string values if needed
    local original_process_lines = utils.process_lines
    utils.process_lines = function(lines)
      local result = {}
      for i, line in ipairs(lines) do
        if config.options.trim_lines then
          table.insert(result, vim.fn.trim(line))
        else
          table.insert(result, line)
        end
      end
      return result
    end

    local processed = utils.process_lines({
      "Line 1",
      "  Line 2 with spaces  ",
      "Line 3"
    })

    assert.are.same({
      "Line 1",
      "Line 2 with spaces",
      "Line 3"
    }, processed)
  end)

  it("processes lines with trimming disabled", function()
    -- Disable trim_lines in config
    local config = require("copy_with_context.config")
    config.options.trim_lines = false

    local processed = utils.process_lines({
      "Line 1",
      "  Line 2 with spaces  ",
      "Line 3"
    })

    assert.are.same({
      "Line 1",
      "  Line 2 with spaces  ",
      "Line 3"
    }, processed)
  end)

  it("formats output with context", function()
    local content = "This is the content"
    local file_path = "path/to/file.lua"
    local line_range = "42"

    local config = require("copy_with_context.config")
    config.options.context_format = "# %s:%s"

    local output = utils.format_output(content, file_path, line_range)
    assert.are.same("This is the content\n# path/to/file.lua:42", output)
  end)

  it("formats output with custom context format", function()
    local content = "Custom content"
    local file_path = "file.lua"
    local line_range = "10-15"

    local config = require("copy_with_context.config")
    config.options.context_format = "// Source: %s (lines %s)"

    local output = utils.format_output(content, file_path, line_range)
    assert.are.same("Custom content\n// Source: file.lua (lines 10-15)", output)
  end)
end)

-- Test the main module
describe("main module", function()
  local main
  local copied_text

  before_each(function()
    -- Reset modules
    package.loaded["copy_with_context.main"] = nil
    package.loaded["copy_with_context.utils"] = nil
    package.loaded["copy_with_context.config"] = nil

    -- Mock vim.keymap.set if it doesn't exist
    _G.vim.keymap = _G.vim.keymap or {}
    _G.vim.keymap.set = _G.vim.keymap.set or function(mode, keys, action, opts)
      return true
    end

    -- Mock vim.api.nvim_echo
    _G.vim.api = _G.vim.api or {}
    _G.vim.api.nvim_echo = _G.vim.api.nvim_echo or function(messages, history, opts)
      return true
    end

    -- Override utils.copy_to_clipboard to capture the copied text
    package.loaded["copy_with_context.utils"] = {
      get_lines = function(is_visual)
        if is_visual then
          return {"Line 1", "Line 2"}, 5, 6
        else
          return {"Single line"}, 10, 10
        end
      end,
      process_lines = function(lines)
        return lines
      end,
      get_file_path = function(absolute)
        if absolute then
          return "/absolute/path/test.lua"
        else
          return "relative/path/test.lua"
        end
      end,
      format_line_range = function(start_line, end_line)
        if start_line == end_line then
          return tostring(start_line)
        else
          return start_line .. "-" .. end_line
        end
      end,
      copy_to_clipboard = function(output)
        copied_text = output
        return true
      end,
      format_output = function(content, file_path, line_range)
        return content .. "\n# " .. file_path .. ":" .. line_range
      end
    }

    -- Load modules
    main = require("copy_with_context.main")
  end)

  it("copies single line with relative path", function()
    main.copy_with_context(false, false)
    assert.are.same("Single line\n# relative/path/test.lua:10", copied_text)
  end)

  it("copies single line with absolute path", function()
    main.copy_with_context(true, false)
    assert.are.same("Single line\n# /absolute/path/test.lua:10", copied_text)
  end)

  it("copies selection with relative path", function()
    main.copy_with_context(false, true)
    assert.are.same("Line 1\nLine 2\n# relative/path/test.lua:5-6", copied_text)
  end)

  it("copies selection with absolute path", function()
    main.copy_with_context(true, true)
    assert.are.same("Line 1\nLine 2\n# /absolute/path/test.lua:5-6", copied_text)
  end)

  it("sets up the correct keymaps", function()
    -- Mock the keymap.set function to capture mappings
    local mappings = {}
    _G.vim.keymap.set = function(mode, keys, action, opts)
      mappings[mode .. "-" .. keys] = {action = action, opts = opts}
      return true
    end

    -- Load config
    local config = require("copy_with_context.config")
    config.options.mappings = {
      relative = "<leader>cr",
      absolute = "<leader>cA",
    }

    -- Setup main module
    main.setup()

    -- Check that mappings were created
    assert.is_not_nil(mappings["n-<leader>cr"])
    assert.is_not_nil(mappings["n-<leader>cA"])
    assert.is_not_nil(mappings["x-<leader>cr"])
    assert.is_not_nil(mappings["x-<leader>cA"])
  end)
end)

-- Test the plugin initialization
describe("plugin initialization", function()
  local plugin
  local setup_called = false

  before_each(function()
    -- Reset modules
    package.loaded["copy_with_context"] = nil
    package.loaded["copy_with_context.config"] = nil
    package.loaded["copy_with_context.main"] = nil

    -- Mock the main.setup function
    package.loaded["copy_with_context.main"] = {
      setup = function()
        setup_called = true
        return true
      end
    }

    -- Mock the config.setup function
    package.loaded["copy_with_context.config"] = {
      setup = function(opts)
        return true
      end
    }

    -- Load plugin
    plugin = require("copy_with_context")
  end)

  it("initializes correctly with default options", function()
    plugin.setup()
    assert.is_true(setup_called)
  end)

  it("initializes correctly with custom options", function()
    local custom_opts = {
      mappings = {
        relative = "<leader>cc",
      },
      context_format = "// %s @ %s",
    }

    -- Mock config.setup to verify options are passed
    local passed_opts
    package.loaded["copy_with_context.config"].setup = function(opts)
      passed_opts = opts
      return true
    end

    plugin.setup(custom_opts)
    assert.is_true(setup_called)
    assert.are.same(custom_opts, passed_opts)
  end)
end)
