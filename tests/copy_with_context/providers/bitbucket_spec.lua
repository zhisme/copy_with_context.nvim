-- Bitbucket provider tests

-- Clear cached modules
package.loaded["copy_with_context.providers.bitbucket"] = nil

local bitbucket = require("copy_with_context.providers.bitbucket")

describe("Bitbucket provider", function()
  describe("matches", function()
    it("matches bitbucket.org", function()
      assert.is_true(bitbucket.matches("bitbucket.org"))
    end)

    it("matches Bitbucket Enterprise domains", function()
      assert.is_true(bitbucket.matches("bitbucket.example.com"))
      assert.is_true(bitbucket.matches("code.bitbucket.org"))
    end)

    it("does not match non-Bitbucket domains", function()
      assert.is_false(bitbucket.matches("github.com"))
      assert.is_false(bitbucket.matches("gitlab.com"))
      assert.is_false(bitbucket.matches("example.com"))
    end)
  end)

  describe("build_url", function()
    local git_info = {
      provider = "bitbucket.org",
      owner = "user",
      repo = "repo",
      commit = "abc123def456",
      file_path = "lua/file.lua",
    }

    it("builds URL for single line", function()
      local url = bitbucket.build_url(git_info, 42, 42)
      assert.equals("https://bitbucket.org/user/repo/src/abc123def456/lua/file.lua#lines-42", url)
    end)

    it("builds URL for multiple lines", function()
      local url = bitbucket.build_url(git_info, 10, 20)
      assert.equals("https://bitbucket.org/user/repo/src/abc123def456/lua/file.lua#lines-10:20", url)
    end)

    it("builds URL for Bitbucket Enterprise", function()
      local enterprise_info = {
        provider = "bitbucket.example.com",
        owner = "team",
        repo = "project",
        commit = "xyz789",
        file_path = "src/main.rb",
      }
      local url = bitbucket.build_url(enterprise_info, 5, 5)
      assert.equals("https://bitbucket.example.com/team/project/src/xyz789/src/main.rb#lines-5", url)
    end)
  end)
end)
