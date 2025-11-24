local formatter = require("copy_with_context.formatter")

describe("Formatter", function()
  describe("get_variables", function()
    it("creates variables table with single line", function()
      local vars = formatter.get_variables("/path/to/file.lua", 42, nil, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "42",
        linenumber = "42",
        remote_url = "",
      }, vars)
    end)

    it("creates variables table with line range", function()
      local vars = formatter.get_variables("/path/to/file.lua", 10, 20, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "10-20",
        linenumber = "10-20",
        remote_url = "",
      }, vars)
    end)

    it("creates variables table with remote URL", function()
      local vars = formatter.get_variables(
        "/path/to/file.lua",
        5,
        5,
        "https://github.com/user/repo/blob/abc123/file.lua#L5"
      )

      assert.same({
        filepath = "/path/to/file.lua",
        line = "5",
        linenumber = "5",
        remote_url = "https://github.com/user/repo/blob/abc123/file.lua#L5",
      }, vars)
    end)

    it("handles line_end same as line_start", function()
      local vars = formatter.get_variables("/path/to/file.lua", 7, 7, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "7",
        linenumber = "7",
        remote_url = "",
      }, vars)
    end)
  end)

  describe("format", function()
    it("replaces variables in format string", function()
      local vars = {
        filepath = "src/main.lua",
        line = "42",
        linenumber = "42",
        remote_url = "https://github.com/user/repo/blob/abc/main.lua#L42",
      }

      local result = formatter.format("# {filepath}:{line}", vars)
      assert.equals("# src/main.lua:42", result)
    end)

    it("replaces multiple instances of same variable", function()
      local vars = {
        filepath = "test.lua",
        line = "1",
        linenumber = "1",
        remote_url = "",
      }

      local result = formatter.format("{filepath} - {filepath}", vars)
      assert.equals("test.lua - test.lua", result)
    end)

    it("replaces all available variables", function()
      local vars = {
        filepath = "file.lua",
        line = "10-20",
        linenumber = "10-20",
        remote_url = "https://example.com",
      }

      local result = formatter.format("# {filepath}:{line} - {remote_url}", vars)
      assert.equals("# file.lua:10-20 - https://example.com", result)
    end)

    it("handles empty remote_url", function()
      local vars = {
        filepath = "file.lua",
        line = "5",
        linenumber = "5",
        remote_url = "",
      }

      local result = formatter.format("# {filepath}:{line} {remote_url}", vars)
      assert.equals("# file.lua:5 ", result)
    end)

    it("returns empty string for nil format string", function()
      local vars = { filepath = "test.lua", line = "1", linenumber = "1", remote_url = "" }
      local result = formatter.format(nil, vars)
      assert.equals("", result)
    end)

    it("leaves unknown variables unchanged", function()
      local vars = {
        filepath = "test.lua",
        line = "1",
        linenumber = "1",
        remote_url = "",
      }

      local result = formatter.format("# {filepath} {unknown}", vars)
      assert.equals("# test.lua {unknown}", result)
    end)

    it("uses linenumber as alias for line", function()
      local vars = {
        filepath = "test.lua",
        line = "42",
        linenumber = "42",
        remote_url = "",
      }

      local result = formatter.format("# {filepath}:{linenumber}", vars)
      assert.equals("# test.lua:42", result)
    end)
  end)
end)
