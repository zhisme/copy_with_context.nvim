-- Git utilities tests
-- luacheck: globals vim

-- Set up vim mock before requiring the module
_G.vim = {
  fn = {},
  v = {
    shell_error = 0,
  },
}

-- Clear cached modules
package.loaded["copy_with_context.git"] = nil

local git = require("copy_with_context.git")

describe("Git utilities", function()
  local original_system, original_trim, original_shellescape, original_fnamemodify

  before_each(function()
    -- Save originals
    original_system = vim.fn.system
    original_trim = vim.fn.trim
    original_shellescape = vim.fn.shellescape
    original_fnamemodify = vim.fn.fnamemodify

    -- Set defaults
    vim.v.shell_error = 0
    vim.fn.system = function(_cmd)
      return ""
    end
    vim.fn.trim = function(s)
      if not s then return "" end
      return s:match("^%s*(.-)%s*$") or s
    end
    vim.fn.shellescape = function(s)
      return "'" .. s:gsub("'", "'\\''") .. "'"
    end
    vim.fn.fnamemodify = function(path, _mod)
      return path
    end
  end)

  after_each(function()
    -- Restore originals
    vim.fn.system = original_system
    vim.fn.trim = original_trim
    vim.fn.shellescape = original_shellescape
    vim.fn.fnamemodify = original_fnamemodify
  end)

  describe("is_git_repo", function()
    it("returns true when in a git repository", function()
      vim.fn.system = function(_cmd)
        return "true\n"
      end
      vim.v.shell_error = 0

      local result = git.is_git_repo()
      assert.is_true(result)
    end)

    it("returns false when not in a git repository", function()
      vim.fn.system = function(_cmd)
        return "fatal: not a git repository\n"
      end
      vim.v.shell_error = 128

      local result = git.is_git_repo()
      assert.is_false(result)
    end)
  end)

  describe("get_remote_url", function()
    it("returns origin remote URL", function()
      vim.fn.system = function(_cmd)
        return "origin\thttps://github.com/user/repo.git (fetch)\norigin\thttps://github.com/user/repo.git (push)\n"
      end
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.equals("https://github.com/user/repo.git", result)
    end)

    it("returns first remote if origin not available", function()
      vim.fn.system = function(_cmd)
        return "upstream\thttps://github.com/other/repo.git (fetch)\n"
          .. "upstream\thttps://github.com/other/repo.git (push)\n"
      end
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.equals("https://github.com/other/repo.git", result)
    end)

    it("returns nil when no remotes available", function()
      vim.fn.system = function(_cmd)
        return ""
      end
      vim.v.shell_error = 0

      local result = git.get_remote_url()
      assert.is_nil(result)
    end)

    it("returns nil on git error", function()
      vim.fn.system = function(_cmd)
        return "fatal: not a git repository\n"
      end
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
      vim.fn.system = function(_cmd)
        return "abc123def456\n"
      end
      vim.v.shell_error = 0

      local result = git.get_current_commit()
      assert.equals("abc123def456", result)
    end)

    it("returns nil on git error", function()
      vim.fn.system = function(_cmd)
        return "fatal: not a git repository\n"
      end
      vim.v.shell_error = 128

      local result = git.get_current_commit()
      assert.is_nil(result)
    end)
  end)

  describe("get_file_git_path", function()
    it("returns repo-relative path", function()
      vim.fn.system = function(_cmd)
        return "lua/copy_with_context/git.lua\n"
      end
      vim.v.shell_error = 0

      local result = git.get_file_git_path("/home/user/project/lua/copy_with_context/git.lua")
      assert.equals("lua/copy_with_context/git.lua", result)
    end)

    it("converts Windows backslashes to forward slashes", function()
      vim.fn.system = function(_cmd)
        return "lua\\copy_with_context\\git.lua\n"
      end
      vim.v.shell_error = 0

      local result = git.get_file_git_path("C:\\project\\lua\\copy_with_context\\git.lua")
      assert.equals("lua/copy_with_context/git.lua", result)
    end)

    it("returns nil for untracked file", function()
      vim.fn.system = function(_cmd)
        return ""
      end
      vim.v.shell_error = 128

      local result = git.get_file_git_path("/home/user/project/untracked.lua")
      assert.is_nil(result)
    end)
  end)

  describe("get_git_info", function()
    local orig_is_git_repo, orig_get_remote_url, orig_get_current_commit, orig_get_file_git_path

    before_each(function()
      -- Save originals
      orig_is_git_repo = git.is_git_repo
      orig_get_remote_url = git.get_remote_url
      orig_get_current_commit = git.get_current_commit
      orig_get_file_git_path = git.get_file_git_path
    end)

    after_each(function()
      -- Restore originals
      git.is_git_repo = orig_is_git_repo
      git.get_remote_url = orig_get_remote_url
      git.get_current_commit = orig_get_current_commit
      git.get_file_git_path = orig_get_file_git_path
    end)

    it("returns complete git info", function()
      -- Mock functions
      git.is_git_repo = function()
        return true
      end
      git.get_remote_url = function()
        return "https://github.com/user/repo.git"
      end
      git.get_current_commit = function()
        return "abc123def456"
      end
      git.get_file_git_path = function(_path)
        return "lua/file.lua"
      end

      local result = git.get_git_info("/home/user/project/lua/file.lua")

      assert.same({
        provider = "github.com",
        owner = "user",
        repo = "repo",
        commit = "abc123def456",
        file_path = "lua/file.lua",
      }, result)
    end)

    it("returns nil when not in git repo", function()
      git.is_git_repo = function()
        return false
      end

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)
    end)

    it("returns nil when remote URL not available", function()
      git.is_git_repo = function()
        return true
      end
      git.get_remote_url = function()
        return nil
      end

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)
    end)

    it("returns nil when remote URL cannot be parsed", function()
      git.is_git_repo = function()
        return true
      end
      git.get_remote_url = function()
        return "invalid-url-format"
      end

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)
    end)

    it("returns nil when commit is not available", function()
      git.is_git_repo = function()
        return true
      end
      git.get_remote_url = function()
        return "https://github.com/user/repo.git"
      end
      git.get_current_commit = function()
        return nil
      end

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)
    end)

    it("returns nil when file git path is not available", function()
      git.is_git_repo = function()
        return true
      end
      git.get_remote_url = function()
        return "https://github.com/user/repo.git"
      end
      git.get_current_commit = function()
        return "abc123"
      end
      git.get_file_git_path = function(_path)
        return nil
      end

      local result = git.get_git_info("/home/user/project/file.lua")
      assert.is_nil(result)
    end)
  end)

  describe("get_file_git_path with relative paths", function()
    it("converts relative path to absolute before calling git", function()
      local fnamemodify_called = false
      local mod_value = nil
      vim.fn.fnamemodify = function(path, mod)
        fnamemodify_called = true
        mod_value = mod
        return "/home/user/project/" .. path
      end
      vim.fn.system = function(_cmd)
        return "lua/file.lua\n"
      end
      vim.v.shell_error = 0

      local result = git.get_file_git_path("lua/file.lua")
      assert.is_true(fnamemodify_called)
      assert.equals(":p", mod_value)
      assert.equals("lua/file.lua", result)
    end)
  end)
end)
