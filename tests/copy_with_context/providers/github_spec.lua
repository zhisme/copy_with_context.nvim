-- GitHub provider tests

-- Clear cached modules
package.loaded["copy_with_context.providers.github"] = nil

local github = require("copy_with_context.providers.github")

describe("GitHub provider", function()
  describe("matches", function()
    it("matches github.com", function()
      assert.is_true(github.matches("github.com"))
    end)

    it("matches GitHub Enterprise domains", function()
      assert.is_true(github.matches("github.example.com"))
      assert.is_true(github.matches("code.github.com"))
    end)

    it("does not match non-GitHub domains", function()
      assert.is_false(github.matches("gitlab.com"))
      assert.is_false(github.matches("bitbucket.org"))
      assert.is_false(github.matches("example.com"))
    end)
  end)

  describe("build_url", function()
    local git_info = {
      provider = "github.com",
      owner = "user",
      repo = "repo",
      commit = "abc123def456",
      file_path = "lua/file.lua",
    }

    it("builds URL for single line", function()
      local url = github.build_url(git_info, 42, 42)
      assert.equals("https://github.com/user/repo/blob/abc123def456/lua/file.lua#L42", url)
    end)

    it("builds URL for multiple lines", function()
      local url = github.build_url(git_info, 10, 20)
      assert.equals("https://github.com/user/repo/blob/abc123def456/lua/file.lua#L10-L20", url)
    end)

    it("builds URL for GitHub Enterprise", function()
      local enterprise_info = {
        provider = "github.example.com",
        owner = "user",
        repo = "repo",
        commit = "abc123",
        file_path = "src/main.js",
      }
      local url = github.build_url(enterprise_info, 5, 5)
      assert.equals("https://github.example.com/user/repo/blob/abc123/src/main.js#L5", url)
    end)

    it("builds URL for GitHub with nested paths (org structure)", function()
      local nested_info = {
        provider = "github.com",
        owner = "myorg/team",
        repo = "project",
        commit = "def456abc",
        file_path = "packages/core/index.ts",
      }
      local url = github.build_url(nested_info, 15, 25)
      assert.equals(
        "https://github.com/myorg/team/project/blob/def456abc/packages/core/index.ts#L15-L25",
        url
      )
    end)
  end)
end)
