-- Bitbucket provider for URL generation

local M = {}

M.name = "bitbucket"

-- Check if this provider handles the given domain
function M.matches(domain)
  return domain == "bitbucket.org" or domain:match("%.bitbucket%.org$") ~= nil
end

-- Build URL for Bitbucket
-- Format: https://bitbucket.org/{owner}/{repo}/src/{commit_sha}/{file_path}#lines-{start}[:{end}]
function M.build_url(git_info, line_start, line_end)
  local base_url = string.format(
    "https://%s/%s/%s/src/%s/%s",
    git_info.provider,
    git_info.owner,
    git_info.repo,
    git_info.commit,
    git_info.file_path
  )

  -- Add line fragment
  if line_start == line_end then
    return base_url .. "#lines-" .. line_start
  else
    return base_url .. "#lines-" .. line_start .. ":" .. line_end
  end
end

return M
