-- Git utilities tests

_G.vim = {
  fn = {
    system = function(_cmd) end,
    trim = function(s) return s:match("^%s*(.-)%s*$") end,
    shellescape = function(s) return "'" .. s:gsub("'", "'\\''") .. "'" end,
    fnamemodify = function(path, _mod) return path end,
  },
  v = {
    shell_error = 0,
  },
}

-- Clear cached modules
package.loaded["copy_with_context.git"] = nil

local git = require("copy_with_context.git")

describe("Git utilities", function()
  before_each(function()
    vim.v.shell_error = 0
    stub(vim.fn, "system")
    stub(vim.fn, "trim", function(s)
      return s:match("^%s*(.-)%s*$")
    end)
    stub(vim.fn, "shellescape", function(s)
      return "'" .. s:gsub("'", "'\\''") .. "'"
    end)
  end)

  after_each(function()
    vim.fn.system:revert()
    vim.fn.trim:revert()
    vim.fn.shellescape:revert()
  end)

  describe("is_git_repo", function()
    it("returns true when in a git repository", function()
      vim.fn.system:invokes(function(_cmd)
        return "true\n"
      end)
      vim.v.shell_error = 0

      local result = git.is_git_repo()
      assert.is_true(result)
    end)

    it("returns false when not in a git repository", function()
      vim.fn.system:invokes(function(_cmd)
        return "fatal: not a git repository\n"
      end)
      vim.v.shell_error = 128

      local result = git.is_git_repo()
      assert.is_false(result)
    end)
  end)

  describe("get_remote_url", function()
    it("returns origin remote URL", function()
      vim.fn.system:invokes(function(_cmd)
        return "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)\n"
      end)
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.equals("https://github.com/user/repo.git", result)
    end)

    it("returns first remote if origin not available", function()
      vim.fn.system:invokes(function(_cmd)
        return "upstream\thttps://github.com/other/repo.git (fetch)\nupstream\thttps://github.com/other/repo.git (push)\n"
      end)
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.equals("https://github.com/other/repo.git", result)
    end)

    it("returns nil when no remotes available", function()
      vim.fn.system:invokes(function(_cmd)
        return ""
      end)
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.is_nil(result)
    end)

    it("returns nil on git error", function()
      vim.fn.system:invokes(function(_cmd)
        return "fatal: not a git repository\n"
      end)
      vim.v.shell_error = 128

      local result = git.get_remote_url()
      assert.is_nil(result)
    end)
  end)

  describe("parse_remote_url", function()
    it("parses HTTPS URL with .git", function()
      local result = git.parse_remote_url("https://github.com/user/repo.git")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("parses HTTPS URL without .git", function()
      local result = git.parse_remote_url("https://github.com/user/repo")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("parses SSH URL with .git", function()
      local result = git.parse_remote_url("git@github.com:user/repo.git")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("parses SSH URL without .git", function()
      local result = git.parse_remote_url("git@github.com:user/repo")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("parses git protocol URL with .git", function()
      local result = git.parse_remote_url("git://github.com/user/repo.git")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("parses git protocol URL without .git", function()
      local result = git.parse_remote_url("git://github.com/user/repo")
      assert.same({ provider = "github.com", owner = "user", repo = "repo" }, result)
    end)

    it("returns nil for invalid URL", function()
      local result = git.parse_remote_url("invalid-url")
      assert.is_nil(result)
    end)

    it("returns nil for nil input", function()
      local result = git.parse_remote_url(nil)
      assert.is_nil(result)
    end)
  end)

  describe("get_current_commit", function()
    it("returns commit SHA", function()
      vim.fn.system:invokes(function(_cmd)
        return "abc123def456\n"
      end)
      vim.v.shell_error = 0

      local result = git.get_current_commit()
      assert.equals("abc123def456", result)
    end)

    it("returns nil on git error", function()
      vim.fn.system:invokes(function(_cmd)
        return "fatal: not a git repository\n"
      end)
      vim.v.shell_error = 128

      local result = git.get_current_commit()
      assert.is_nil(result)
    end)
  end)

  describe("get_file_git_path", function()
    it("returns repo-relative path", function()
      vim.fn.system:invokes(function(_cmd)
        return "lua/copy_with_context/git.lua\n"
      end)
      vim.v.shell_error = 0

      local result = git.get_file_git_path("/home/user/project/lua/copy_with_context/git.lua")
      assert.equals("lua/copy_with_context/git.lua", result)
    end)

    it("converts Windows backslashes to forward slashes", function()
      vim.fn.system:invokes(function(_cmd)
        return "lua\\copy_with_context\\git.lua\n"
      end)
      vim.v.shell_error = 0

      local result = git.get_file_git_path("C:\\project\\lua\\copy_with_context\\git.lua")
      assert.equals("lua/copy_with_context/git.lua", result)
    end)

    it("returns nil for untracked file", function()
      vim.fn.system:invokes(function(_cmd)
        return ""
      end)
      vim.v.shell_error = 128

      local result = git.get_file_git_path("/home/user/project/untracked.lua")
      assert.is_nil(result)
    end)
  end)

  describe("get_git_info", function()
    it("returns complete git info", function()
      -- Mock is_git_repo
      stub(git, "is_git_repo", function()
        return true
      end)

      -- Mock get_remote_url
      stub(git, "get_remote_url", function()
        return "https://github.com/user/repo.git"
      end)

      -- Mock get_current_commit
      stub(git, "get_current_commit", function()
        return "abc123def456"
      end)

      -- Mock get_file_git_path
      stub(git, "get_file_git_path", function(_path)
        return "lua/file.lua"
      end)

      local result = git.get_git_info("/home/user/project/lua/file.lua")

      assert.same({
        provider = "github.com",
        owner = "user",
        repo = "repo",
        commit = "abc123def456",
        file_path = "lua/file.lua",
      }, result)

      git.is_git_repo:revert()
      git.get_remote_url:revert()
      git.get_current_commit:revert()
      git.get_file_git_path:revert()
    end)

    it("returns nil when not in git repo", function()
      stub(git, "is_git_repo", function()
        return false
      end)

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)

      git.is_git_repo:revert()
    end)

    it("returns nil when remote URL not available", function()
      stub(git, "is_git_repo", function()
        return true
      end)
      stub(git, "get_remote_url", function()
        return nil
      end)

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)

      git.is_git_repo:revert()
      git.get_remote_url:revert()
    end)
  end)
end)
