-- Bitbucket provider for URL generation

local M = {}

M.name = "bitbucket"

-- Check if this provider handles the given domain
function M.matches(domain)
  return domain == "bitbucket.org" or domain:match("%.bitbucket%.org$") ~= nil
end

-- Generate Bitbucket-style line fragment, including the leading separator
-- @param line_start number Starting line number
-- @param line_end number|nil Ending line number (nil for single line)
-- @return string Line fragment (e.g., "#lines-5" or "#lines-5:8")
function M.line_fragment(line_start, line_end)
  if not line_end or line_start == line_end then
    return "#lines-" .. line_start
  else
    return "#lines-" .. line_start .. ":" .. line_end
  end
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

  return base_url .. M.line_fragment(line_start, line_end)
end

return M
