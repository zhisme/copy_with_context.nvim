-- GitLab provider tests

-- Clear cached modules
package.loaded["copy_with_context.providers.gitlab"] = nil

local gitlab = require("copy_with_context.providers.gitlab")

describe("GitLab provider", function()
  describe("matches", function()
    it("matches gitlab.com", function()
      assert.is_true(gitlab.matches("gitlab.com"))
    end)

    it("matches self-hosted GitLab domains", function()
      assert.is_true(gitlab.matches("gitlab.example.com"))
      assert.is_true(gitlab.matches("mygitlab.company.com"))
    end)
  end)

  describe("build_url", function()
    local git_info = {
      provider = "gitlab.com",
      owner = "user",
      repo = "repo",
      commit = "abc123def456",
      file_path = "lua/file.lua",
    }

    it("builds URL for single line", function()
      local url = gitlab.build_url(git_info, 42, 42)
      assert.equals("https://gitlab.com/user/repo/-/blob/abc123def456/lua/file.lua#L42", url)
    end)

    it("builds URL for multiple lines", function()
      local url = gitlab.build_url(git_info, 10, 20)
      assert.equals("https://gitlab.com/user/repo/-/blob/abc123def456/lua/file.lua#L10-20", url)
    end)

    it("builds URL for self-hosted GitLab", function()
      local selfhosted_info = {
        provider = "gitlab.example.com",
        owner = "team",
        repo = "project",
        commit = "xyz789",
        file_path = "src/main.py",
      }
      local url = gitlab.build_url(selfhosted_info, 5, 5)
      assert.equals("https://gitlab.example.com/team/project/-/blob/xyz789/src/main.py#L5", url)
    end)

    it("builds URL for nested groups (GitLab)", function()
      local nested_info = {
        provider = "gitlab.example.com",
        owner = "frontend/web",
        repo = "dashboard",
        commit = "abc123def456",
        file_path = "src/components/App.tsx",
      }
      local url = gitlab.build_url(nested_info, 42, 42)
      assert.equals(
        "https://gitlab.example.com/frontend/web/dashboard/-/blob/abc123def456/src/components/App.tsx#L42",
        url
      )
    end)

    it("builds URL for deeply nested groups", function()
      local deeply_nested_info = {
        provider = "gitlab.company.com",
        owner = "org/team/subteam",
        repo = "service",
        commit = "xyz789abc",
        file_path = "lib/utils.js",
      }
      local url = gitlab.build_url(deeply_nested_info, 10, 20)
      assert.equals(
        "https://gitlab.company.com/org/team/subteam/service/-/blob/xyz789abc/lib/utils.js#L10-20",
        url
      )
    end)
  end)
end)
