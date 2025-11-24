-- vim functions to be stubbed later, here only signatures defined.
_G.vim = {
  fn = {
    line = function(_mark) end,
    getline = function(_a, _b) end,
    expand = function(_expr) end,
    trim = function(_s) end,
    setreg = function(_reg, _val) end,
  },
}

-- Clear cached modules to ensure our mocks are used.
package.loaded["copy_with_context.utils"] = nil
package.loaded["copy_with_context.config"] = nil

local utils = require("copy_with_context.utils")

describe("Utility Functions", function()
  before_each(function()
    stub(vim.fn, "line", function(mark)
      if mark == "." then
        return 1
      elseif mark == "'<" then
        return 1
      elseif mark == "'>" then
        return 3
      end
      return 1
    end)

    stub(vim.fn, "getline", function(a, b)
      if type(a) == "string" and a == "." then
        -- Called in non-visual mode
        return "sample line"
      elseif type(a) == "number" and type(b) == "number" then
        -- Called in visual mode; a should be 1 and b should be 3
        return { "line 1", "line 2", "line 3" }
      end
    end)

    stub(vim.fn, "expand", function(expr)
      if expr == "%:p" then
        return "absolute_test_file.lua"
      end
      return "test_file.lua"
    end)

    stub(vim.fn, "trim", function(s)
      return s:match("^%s*(.-)%s*$")
    end)

    stub(vim.fn, "setreg", function(_reg, _val) end)
  end)

  after_each(function()
    vim.fn.line:revert()
    vim.fn.getline:revert()
    vim.fn.expand:revert()
    vim.fn.trim:revert()
    vim.fn.setreg:revert()
  end)

  describe("get_lines", function()
    it("returns the current line when not in visual mode", function()
      local lines, start_lnum, end_lnum = utils.get_lines(false)
      if type(lines) == "string" then
        lines = { lines }
      end
      assert.same({ "sample line" }, lines)
      assert.equals(1, start_lnum)
      assert.equals(1, end_lnum)
    end)

    it("returns multiple lines when in visual mode", function()
      local lines, start_lnum, end_lnum = utils.get_lines(true)
      assert.same({ "line 1", "line 2", "line 3" }, lines)
      assert.equals(1, start_lnum)
      assert.equals(3, end_lnum)
    end)
  end)

  describe("get_file_path", function()
    it("returns the absolute file path", function()
      local path = utils.get_file_path(true)
      assert.equals("absolute_test_file.lua", path)
    end)

    it("returns the relative file path", function()
      local path = utils.get_file_path(false)
      assert.equals("test_file.lua", path)
    end)
  end)

  describe("process_lines", function()
    local config_mock = {
      options = { trim_lines = false },
    }

    before_each(function()
      package.loaded["copy_with_context.config"] = config_mock
    end)

    it("keeps lines unchanged if trim is disabled", function()
      local result = utils.process_lines({ "  hello  ", " world " })
      assert.same({ "  hello  ", " world " }, result)
    end)

    it("trims lines if config option is enabled", function()
      config_mock.options.trim_lines = true
      local result = utils.process_lines({ "  hello  ", " world " })
      assert.same({ "hello", "world" }, result)
    end)
  end)

  describe("copy_to_clipboard", function()
    it("sets the clipboard registers", function()
      local setreg_calls = {}
      stub(vim.fn, "setreg", function(reg, val)
        setreg_calls[reg] = val
      end)

      utils.copy_to_clipboard("copied text", false)
      assert.equals("copied text", setreg_calls["*"])
      assert.equals("copied text", setreg_calls["+"])
    end)
  end)
end)
