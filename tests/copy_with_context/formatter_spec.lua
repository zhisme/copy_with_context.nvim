local formatter = require("copy_with_context.formatter")

describe("Formatter", function()
  describe("get_variables", function()
    it("creates variables table with single line", function()
      local vars = formatter.get_variables("/path/to/file.lua", 42, nil, nil, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "42",
        linenumber = "42",
        remote_url = "",
        copied_text = "",
      }, vars)
    end)

    it("creates variables table with line range", function()
      local vars = formatter.get_variables("/path/to/file.lua", 10, 20, nil, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "10-20",
        linenumber = "10-20",
        remote_url = "",
        copied_text = "",
      }, vars)
    end)

    it("creates variables table with remote URL", function()
      local vars = formatter.get_variables(
        "/path/to/file.lua",
        5,
        5,
        "https://github.com/user/repo/blob/abc123/file.lua#L5",
        nil
      )

      assert.same({
        filepath = "/path/to/file.lua",
        line = "5",
        linenumber = "5",
        remote_url = "https://github.com/user/repo/blob/abc123/file.lua#L5",
        copied_text = "",
      }, vars)
    end)

    it("handles line_end same as line_start", function()
      local vars = formatter.get_variables("/path/to/file.lua", 7, 7, nil, nil)

      assert.same({
        filepath = "/path/to/file.lua",
        line = "7",
        linenumber = "7",
        remote_url = "",
        copied_text = "",
      }, vars)
    end)

    it("creates variables table with copied_text content", function()
      local vars = formatter.get_variables("/path/to/file.lua", 10, 12, nil, "function hello()\n  print('hello')\nend")

      assert.same({
        filepath = "/path/to/file.lua",
        line = "10-12",
        linenumber = "10-12",
        remote_url = "",
        copied_text = "function hello()\n  print('hello')\nend",
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
        copied_text = "",
      }

      local result = formatter.format("# {filepath}:{linenumber}", vars)
      assert.equals("# test.lua:42", result)
    end)

    it("replaces copied_text variable", function()
      local vars = {
        filepath = "test.lua",
        line = "1-3",
        linenumber = "1-3",
        remote_url = "",
        copied_text = "local x = 1\nlocal y = 2\nreturn x + y",
      }

      local result = formatter.format("{copied_text}\n\n# {filepath}:{line}", vars)
      assert.equals("local x = 1\nlocal y = 2\nreturn x + y\n\n# test.lua:1-3", result)
    end)

    it("handles copied_text with special characters", function()
      local vars = {
        filepath = "test.lua",
        line = "1",
        linenumber = "1",
        remote_url = "",
        copied_text = "print('Hello {world}')",
      }

      local result = formatter.format("{copied_text}\n# {filepath}", vars)
      assert.equals("print('Hello {world}')\n# test.lua", result)
    end)

    it("allows copied_text variable anywhere in format string", function()
      local vars = {
        filepath = "test.lua",
        line = "5",
        linenumber = "5",
        remote_url = "",
        copied_text = "x = 1",
      }

      local result = formatter.format("```lua\n{copied_text}\n```\n\n_{filepath}:{line}_", vars)
      assert.equals("```lua\nx = 1\n```\n\n_test.lua:5_", result)
    end)
  end)
end)
