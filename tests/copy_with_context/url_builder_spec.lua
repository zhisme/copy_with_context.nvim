local url_builder = require("copy_with_context.url_builder")

describe("URL Builder", function()
  before_each(function()
    -- Clear module cache
    package.loaded["copy_with_context.git"] = nil
    package.loaded["copy_with_context.providers"] = nil
  end)

  describe("build_url", function()
    it("returns URL when git info and provider are available", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/test.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local provider_mock = {
        build_url = function(_git_info, _start, _end)
          return "https://github.com/user/repo/blob/abc123/lua/test.lua#L10-L20"
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local url = url_builder.build_url("lua/test.lua", 10, 20)
      assert.equals("https://github.com/user/repo/blob/abc123/lua/test.lua#L10-L20", url)
    end)

    it("returns nil when git info is not available", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return nil
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local url = url_builder.build_url("lua/test.lua", 10, 20)
      assert.is_nil(url)
    end)

    it("returns nil when provider is not available", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return {
            provider = "unknown.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/test.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local providers_mock = {
        get_provider = function(_git_info)
          return nil -- Unknown provider
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local url = url_builder.build_url("lua/test.lua", 10, 20)
      assert.is_nil(url)
    end)

    it("returns nil when provider build_url returns nil", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/test.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local provider_mock = {
        build_url = function(_git_info, _start, _end)
          return nil -- Provider failed to build URL
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local url = url_builder.build_url("lua/test.lua", 10, 20)
      assert.is_nil(url)
    end)

    it("handles single line numbers", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return {
            provider = "github.com",
            owner = "user",
            repo = "repo",
            commit = "abc123",
            file_path = "lua/test.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local captured_start, captured_end
      local provider_mock = {
        build_url = function(_git_info, start, end_line)
          captured_start = start
          captured_end = end_line
          return "https://github.com/user/repo/blob/abc123/lua/test.lua#L42"
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      local url = url_builder.build_url("lua/test.lua", 42, 42)
      assert.equals(42, captured_start)
      assert.equals(42, captured_end)
      assert.equals("https://github.com/user/repo/blob/abc123/lua/test.lua#L42", url)
    end)

    it("passes correct parameters to provider", function()
      local git_mock = {
        get_git_info = function(_file_path)
          return {
            provider = "gitlab.com",
            owner = "user",
            repo = "repo",
            commit = "def456",
            file_path = "src/main.lua",
          }
        end,
      }
      package.loaded["copy_with_context.git"] = git_mock

      local captured_git_info, captured_start, captured_end
      local provider_mock = {
        build_url = function(git_info, start, end_line)
          captured_git_info = git_info
          captured_start = start
          captured_end = end_line
          return "https://gitlab.com/user/repo/-/blob/def456/src/main.lua#L5-10"
        end,
      }
      local providers_mock = {
        get_provider = function(_git_info)
          return provider_mock
        end,
      }
      package.loaded["copy_with_context.providers"] = providers_mock

      url_builder.build_url("src/main.lua", 5, 10)

      assert.equals("gitlab.com", captured_git_info.provider)
      assert.equals("user", captured_git_info.owner)
      assert.equals("repo", captured_git_info.repo)
      assert.equals("def456", captured_git_info.commit)
      assert.equals("src/main.lua", captured_git_info.file_path)
      assert.equals(5, captured_start)
      assert.equals(10, captured_end)
    end)
  end)
end)
