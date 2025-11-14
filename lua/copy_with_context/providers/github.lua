-- GitHub provider for URL generation

local M = {}

M.name = "github"

-- Check if this provider handles the given domain
function M.matches(domain)
  return domain == "github.com" or domain:match("%.github%.com$") ~= nil
end

-- Build URL for GitHub
-- Format: https://github.com/{owner}/{repo}/blob/{commit_sha}/{file_path}#L{start}[-L{end}]
function M.build_url(git_info, line_start, line_end)
  local base_url = string.format(
    "https://%s/%s/%s/blob/%s/%s",
    git_info.provider,
    git_info.owner,
    git_info.repo,
    git_info.commit,
    git_info.file_path
  )

  -- Add line fragment
  if line_start == line_end then
    return base_url .. "#L" .. line_start
  else
    return base_url .. "#L" .. line_start .. "-L" .. line_end
  end
end

return M
