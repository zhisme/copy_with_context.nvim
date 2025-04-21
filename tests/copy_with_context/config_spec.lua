-- Define a global vim table before requiring the module
_G.vim = {
  tbl_deep_extend = function(_, default, user_opts)
    local function merge(t1, t2)
      for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k] or false) == "table" then
          merge(t1[k], v)
        else
          t1[k] = v
        end
      end
      return t1
    end
    return merge(default, user_opts)
  end,
}

-- Ensure fresh module loading
package.loaded["copy_with_context.config"] = nil

local config = require("copy_with_context.config")

describe("Config Module", function()
  it("has default options", function()
    assert.same({
      mappings = {
        relative = "<leader>cy",
        absolute = "<leader>cY",
      },
      context_format = "# %s:%s",
      trim_lines = false,
    }, config.options)
  end)

  it("merges user options with defaults", function()
    config.setup({
      mappings = { relative = "<leader>new" },
      trim_lines = true,
    })

    assert.same({
      mappings = {
        relative = "<leader>new",
        absolute = "<leader>cY",
      },
      context_format = "# %s:%s",
      trim_lines = true,
    }, config.options)
  end)
end)
