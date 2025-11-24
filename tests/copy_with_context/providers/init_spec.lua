-- Provider detection and factory tests

-- Clear cached modules
package.loaded["copy_with_context.providers.init"] = nil
package.loaded["copy_with_context.providers.github"] = nil
package.loaded["copy_with_context.providers.gitlab"] = nil
package.loaded["copy_with_context.providers.bitbucket"] = nil

local providers = require("copy_with_context.providers")

describe("Provider detection and factory", function()
  describe("detect_provider", function()
    it("detects GitHub provider", function()
      local provider = providers.detect_provider("github.com")
      assert.is_not_nil(provider)
      assert.equals("github", provider.name)
    end)

    it("detects GitHub Enterprise provider", function()
      local provider = providers.detect_provider("github.example.com")
      assert.is_not_nil(provider)
      assert.equals("github", provider.name)
    end)

    it("detects GitLab provider", function()
      local provider = providers.detect_provider("gitlab.com")
      assert.is_not_nil(provider)
      assert.equals("gitlab", provider.name)
    end)

    it("detects Bitbucket provider", function()
      local provider = providers.detect_provider("bitbucket.org")
      assert.is_not_nil(provider)
      assert.equals("bitbucket", provider.name)
    end)

    it("returns nil for unknown domains", function()
      local provider = providers.detect_provider("unknown.example.com")
      assert.is_nil(provider)
    end)

    it("returns nil for nil domain", function()
      local provider = providers.detect_provider(nil)
      assert.is_nil(provider)
    end)
  end)

  describe("get_provider", function()
    it("returns provider from git info", function()
      local git_info = {
        provider = "github.com",
        owner = "user",
        repo = "repo",
        commit = "abc123",
        file_path = "lua/file.lua",
      }

      local provider = providers.get_provider(git_info)
      assert.is_not_nil(provider)
      assert.equals("github", provider.name)
    end)

    it("returns nil for nil git info", function()
      local provider = providers.get_provider(nil)
      assert.is_nil(provider)
    end)

    it("returns nil for git info without provider", function()
      local git_info = {
        owner = "user",
        repo = "repo",
        commit = "abc123",
        file_path = "lua/file.lua",
      }

      local provider = providers.get_provider(git_info)
      assert.is_nil(provider)
    end)
  end)
end)
