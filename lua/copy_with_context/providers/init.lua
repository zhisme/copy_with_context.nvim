-- Provider detection and factory

local M = {}

-- Lazy-loaded provider modules
local providers = {
  "copy_with_context.providers.github",
  "copy_with_context.providers.gitlab",
  "copy_with_context.providers.bitbucket",
}

-- Detect which provider handles the given domain
function M.detect_provider(domain)
  if not domain then
    return nil
  end

  -- Try each provider in order
  for _, provider_path in ipairs(providers) do
    local ok, provider = pcall(require, provider_path)
    if ok and provider.matches and provider.matches(domain) then
      return provider
    end
  end

  -- Fallback to GitLab for unknown domains (assume self-hosted GitLab)
  local ok, gitlab = pcall(require, "copy_with_context.providers.gitlab")
  if ok then
    return gitlab
  end

  return nil
end

-- Factory method to get provider from git info
function M.get_provider(git_info)
  if not git_info or not git_info.provider then
    return nil
  end

  return M.detect_provider(git_info.provider)
end

return M
