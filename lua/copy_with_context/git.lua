-- Git utilities for repository information and URL generation

local M = {}

-- Check if current file is in a git repository
function M.is_git_repo()
  local result = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  return vim.v.shell_error == 0 and vim.fn.trim(result) == "true"
end

-- Get the remote URL (prefer 'origin', fallback to first available)
function M.get_remote_url()
  local result = vim.fn.system("git remote -v 2>/dev/null")
  if vim.v.shell_error ~= 0 or result == "" then
    return nil
  end

  -- Parse remote output
  -- Format: "origin  https://github.com/user/repo.git (fetch)"
  -- Prefer 'origin' remote
  local origin_url = result:match("origin%s+([^%s]+)%s+%(fetch%)")
  if origin_url then
    return origin_url
  end

  -- Fallback to first available remote
  local first_url = result:match("^[^%s]+%s+([^%s]+)%s+%(fetch%)")
  return first_url
end

-- Parse remote URL to extract provider, owner, and repo
-- Supports HTTPS, SSH, and git:// formats
function M.parse_remote_url(url)
  if not url then
    return nil
  end

  local provider, owner, repo

  -- HTTPS: https://github.com/user/repo.git
  provider, owner, repo = url:match("https?://([^/]+)/([^/]+)/([^/]+)%.git")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  -- HTTPS without .git: https://github.com/user/repo
  provider, owner, repo = url:match("https?://([^/]+)/([^/]+)/([^/]+)$")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  -- SSH: git@github.com:user/repo.git
  provider, owner, repo = url:match("git@([^:]+):([^/]+)/([^/]+)%.git")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  -- SSH without .git: git@github.com:user/repo
  provider, owner, repo = url:match("git@([^:]+):([^/]+)/([^/]+)$")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  -- git protocol: git://github.com/user/repo.git
  provider, owner, repo = url:match("git://([^/]+)/([^/]+)/([^/]+)%.git")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  -- git protocol without .git: git://github.com/user/repo
  provider, owner, repo = url:match("git://([^/]+)/([^/]+)/([^/]+)$")
  if provider then
    return { provider = provider, owner = owner, repo = repo }
  end

  return nil
end

-- Get current commit SHA (full 40 characters)
function M.get_current_commit()
  local result = vim.fn.system("git rev-parse HEAD 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end
  return vim.fn.trim(result)
end

-- Convert absolute path to repo-relative path
function M.get_file_git_path(file_path)
  -- Get the absolute path if not already absolute
  local abs_path = file_path
  if not file_path:match("^/") and not file_path:match("^%a:") then
    abs_path = vim.fn.fnamemodify(file_path, ":p")
  end

  local result = vim.fn.system(string.format("git ls-files --full-name %s 2>/dev/null", vim.fn.shellescape(abs_path)))
  if vim.v.shell_error ~= 0 or result == "" then
    return nil
  end

  local git_path = vim.fn.trim(result)

  -- Convert Windows backslashes to forward slashes
  git_path = git_path:gsub("\\", "/")

  return git_path
end

-- Aggregate function to get all git info for a file
-- Returns: {provider="github.com", owner="user", repo="repo", commit="abc123", file_path="path/to/file"}
-- Returns nil if not in git repo or any step fails
function M.get_git_info(file_path)
  if not M.is_git_repo() then
    return nil
  end

  local remote_url = M.get_remote_url()
  if not remote_url then
    return nil
  end

  local parsed = M.parse_remote_url(remote_url)
  if not parsed then
    return nil
  end

  local commit = M.get_current_commit()
  if not commit then
    return nil
  end

  local git_path = M.get_file_git_path(file_path)
  if not git_path then
    return nil
  end

  return {
    provider = parsed.provider,
    owner = parsed.owner,
    repo = parsed.repo,
    commit = commit,
    file_path = git_path,
  }
end

return M
