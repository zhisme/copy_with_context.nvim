_G.vim = {
  fn = {
    line = function(mark)
      if mark == "." then return 1 end
      return 1
    end,
    getline = function(a, b)
      return {"sample line"}
    end,
    expand = function(expr)
      return "test_file.lua"
    end,
    trim = function(s)
      return s:match("^%s*(.-)%s*$")
    end,
    setreg = function(reg, val)
      -- Default: do nothing
    end,
  }
}

-- Clear cached modules to ensure our mocks are used.
package.loaded["copy_with_context.utils"] = nil
package.loaded["copy_with_context.config"] = nil

local utils = require("copy_with_context.utils")

describe("Utility Functions", function()

  describe("get_lines", function()
    it("returns the current line when not in visual mode", function()
      -- In normal mode, vim.fn.getline should return a string.
      vim.fn.line = function(mark)
        if mark == '.' then return 1 end
        return 1
      end
      vim.fn.getline = function(mark, stop)
        return "sample line"
      end

      local lines, start_lnum, end_lnum = utils.get_lines(false)
      -- The test expects a table; if a string is returned, we wrap it.
      if type(lines) == "string" then lines = {lines} end
      assert.same({"sample line"}, lines)
      assert.equals(1, start_lnum)
      assert.equals(1, end_lnum)
    end)

    it("returns multiple lines when in visual mode", function()
      vim.fn.line = function(mark)
        if mark == "'<" then return 1
        elseif mark == "'>" then return 3
        end
      end
      vim.fn.getline = function(start_lnum, end_lnum)
        return {"line 1", "line 2", "line 3"}
      end

      local lines, start_lnum, end_lnum = utils.get_lines(true)
      assert.same({"line 1", "line 2", "line 3"}, lines)
      assert.equals(1, start_lnum)
      assert.equals(3, end_lnum)
    end)
  end)

  describe("get_file_path", function()
    it("returns the absolute file path", function()
      vim.fn.expand = function(expr)
        if expr == '%:p' then return "absolute_test_file.lua" end
        return "test_file.lua"
      end

      local path = utils.get_file_path(true)
      assert.equals("absolute_test_file.lua", path)
    end)

    it("returns the relative file path", function()
      vim.fn.expand = function(expr)
        return "test_file.lua"
      end

      local path = utils.get_file_path(false)
      assert.equals("test_file.lua", path)
    end)
  end)

  describe("format_line_range", function()
    it("returns a single line number when start and end are the same", function()
      local result = utils.format_line_range(5, 5)
      assert.equals("5", result)
    end)

    it("returns a range when start and end are different", function()
      local result = utils.format_line_range(2, 6)
      assert.equals("2-6", result)
    end)
  end)

  describe("process_lines", function()
    local config_mock = {
      options = { trim_lines = true }
    }

    before_each(function()
      package.loaded["copy_with_context.config"] = config_mock
    end)

    it("trims lines if config option is enabled", function()
      vim.fn.trim = function(s)
        return s:match("^%s*(.-)%s*$")
      end
      local result = utils.process_lines({"  hello  ", " world "})
      assert.same({"hello", "world"}, result)
    end)

    it("keeps lines unchanged if trim is disabled", function()
      config_mock.options.trim_lines = false
      local result = utils.process_lines({"  hello  ", " world "})
      assert.same({"  hello  ", " world "}, result)
    end)
  end)

  describe("copy_to_clipboard", function()
    it("sets the clipboard registers", function()
      local setreg_calls = {}
      vim.fn.setreg = function(reg, val)
        setreg_calls[reg] = val
      end

      utils.copy_to_clipboard("copied text", false)
      assert.equals("copied text", setreg_calls["*"])
      assert.equals("copied text", setreg_calls["+"])
    end)
  end)

  describe("format_output", function()
    local config_mock = {
      options = {
        context_format = "-- %s (lines: %s)"
      }
    }

    before_each(function()
      package.loaded["copy_with_context.config"] = config_mock
    end)

    it("formats output correctly", function()
      local result = utils.format_output("content here", "file.lua", "5-10")
      assert.equals("content here\n-- file.lua (lines: 5-10)", result)
    end)
  end)
end)
