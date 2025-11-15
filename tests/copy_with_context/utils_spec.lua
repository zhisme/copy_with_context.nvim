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

  describe("get_remote_url_line", function()
    local config_mock = {
      options = {
        include_remote_url = true,
      },
    }

    before_each(function()
      package.loaded["copy_with_context.config"] = config_mock
      package.loaded["copy_with_context.git"] = nil
      package.loaded["copy_with_context.providers"] = nil
    end)

    it("returns URL line when git info is available", function()
      local git_mock = {
        get_git_info = function(_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/file.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local provider_mock = {
        build_url = function(_git_info, _start, _end)
          return "https://github.com/user/repo/blob/abc123/lua/file.lua#L42"
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local result = utils.get_remote_url_line("/path/to/file.lua", 42, 42)
      assert.equals("# https://github.com/user/repo/blob/abc123/lua/file.lua#L42", result)
    end)

    it("returns nil when include_remote_url is false", function()
      config_mock.options.include_remote_url = false

      local result = utils.get_remote_url_line("/path/to/file.lua", 42, 42)
      assert.is_nil(result)

      config_mock.options.include_remote_url = true
    end)

    it("returns nil when git info is not available", function()
      local git_mock = {
        get_git_info = function(_path)
          return nil
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local result = utils.get_remote_url_line("/path/to/file.lua", 42, 42)
      assert.is_nil(result)
    end)

    it("returns nil when provider is not available", function()
      local git_mock = {
        get_git_info = function(_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/file.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local providers_mock = {
        get_provider = function(_git_info)
          return nil
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local result = utils.get_remote_url_line("/path/to/file.lua", 42, 42)
      assert.is_nil(result)
    end)

    it("returns nil when build_url returns nil", function()
      local git_mock = {
        get_git_info = function(_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/file.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local provider_mock = {
        build_url = function(_git_info, _start, _end)
          return nil
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local result = utils.get_remote_url_line("/path/to/file.lua", 42, 42)
      assert.is_nil(result)
    end)
  end)

  describe("format_output", function()
    local config_mock = {
      options = {
        context_format = "-- %s (lines: %s)",
        include_remote_url = false,
      },
    }

    before_each(function()
      package.loaded["copy_with_context.config"] = config_mock
    end)

    it("formats output correctly without URL", function()
      local result = utils.format_output("content here", "file.lua", "5-10")
      assert.equals("content here\n-- file.lua (lines: 5-10)", result)
    end)

    it("formats output with URL when available", function()
      config_mock.options.include_remote_url = true

      stub(utils, "get_remote_url_line", function(_path, _start, _end)
        return "# https://github.com/user/repo/blob/abc123/file.lua#L5-L10"
      end)

      local result = utils.format_output("content here", "file.lua", "5-10")
      assert.equals(
        "content here\n-- file.lua (lines: 5-10)\n# https://github.com/user/repo/blob/abc123/file.lua#L5-L10",
        result
      )

      utils.get_remote_url_line:revert()
      config_mock.options.include_remote_url = false
    end)

    it("formats output without URL when get_remote_url_line returns nil", function()
      config_mock.options.include_remote_url = true

      stub(utils, "get_remote_url_line", function(_path, _start, _end)
        return nil
      end)

      local result = utils.format_output("content here", "file.lua", "5-10")
      assert.equals("content here\n-- file.lua (lines: 5-10)", result)

      utils.get_remote_url_line:revert()
      config_mock.options.include_remote_url = false
    end)

    it("parses single line number from line_range", function()
      config_mock.options.include_remote_url = true

      local captured_start, captured_end
      stub(utils, "get_remote_url_line", function(_path, start, _end)
        captured_start = start
        captured_end = _end
        return "# https://example.com#L42"
      end)

      local result = utils.format_output("content", "file.lua", "42")
      assert.equals(42, captured_start)
      assert.equals(42, captured_end)
      assert.truthy(result:match("https://example.com#L42"))

      utils.get_remote_url_line:revert()
      config_mock.options.include_remote_url = false
    end)

    it("parses line range from line_range", function()
      config_mock.options.include_remote_url = true

      local captured_start, captured_end
      stub(utils, "get_remote_url_line", function(_path, start, _end)
        captured_start = start
        captured_end = _end
        return "# https://example.com#L10-L20"
      end)

      local result = utils.format_output("content", "file.lua", "10-20")
      assert.equals(10, captured_start)
      assert.equals(20, captured_end)
      assert.truthy(result:match("https://example.com#L10%-L20"))

      utils.get_remote_url_line:revert()
      config_mock.options.include_remote_url = false
    end)
  end)
end)
