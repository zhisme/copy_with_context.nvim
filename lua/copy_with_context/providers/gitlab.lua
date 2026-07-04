-- GitLab provider for URL generation

local M = {}

M.name = "gitlab"

-- Check if this provider handles the given domain
-- GitLab.com or assume self-hosted GitLab as fallback
function M.matches(domain)
  return domain == "gitlab.com" or domain:match("gitlab") ~= nil
end

-- Generate GitLab-style line fragment (L5 or L5-8)
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @return string Line fragment (e.g., "L5" or "L5-8")
function M.line_fragment(line_start, line_end)
  if line_start == line_end then
    return "L" .. line_start
  else
    return "L" .. line_start .. "-" .. line_end
  end
end

-- Build URL for GitLab
-- Format: https://gitlab.com/{owner}/{repo}/-/blob/{commit_sha}/{file_path}#L{start}[-{end}]
function M.build_url(git_info, line_start, line_end)
  local base_url = string.format(
    "https://%s/%s/%s/-/blob/%s/%s",
    git_info.provider,
    git_info.owner,
    git_info.repo,
    git_info.commit,
    git_info.file_path
  )

  return base_url .. "#" .. M.line_fragment(line_start, line_end)
end

return M
