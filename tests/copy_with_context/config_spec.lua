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
package.loaded["copy_with_context.user_config_validation"] = nil

local config = require("copy_with_context.config")

describe("Config Module", function()
  before_each(function()
    -- Reset config.options to defaults before each test
    config.options = {
      mappings = {
        relative = "<leader>cy",
        absolute = "<leader>cY",
      },
      formats = {
        default = "# {filepath}:{line}",
      },
      trim_lines = false,
    }
  end)

  it("has default options", function()
    assert.same({
      mappings = {
        relative = "<leader>cy",
        absolute = "<leader>cY",
      },
      formats = {
        default = "# {filepath}:{line}",
      },
      trim_lines = false,
    }, config.options)
  end)

  it("can be called without arguments", function()
    config.setup()
    -- Should not error and keep default options
    assert.is_not_nil(config.options.mappings)
    assert.is_not_nil(config.options.formats)
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
      formats = {
        default = "# {filepath}:{line}",
      },
      trim_lines = true,
    }, config.options)
  end)

  it("validates configuration on setup", function()
    local success = pcall(config.setup, {
      mappings = {
        custom = "<leader>cc",
      },
      formats = {
        default = "# {filepath}:{line}",
        -- missing 'custom' format
      },
    })

    assert.is_false(success)
  end)

  it("validates format strings on setup", function()
    local success = pcall(config.setup, {
      mappings = {
        relative = "<leader>cy",
      },
      formats = {
        default = "# {invalid_variable}",
      },
    })

    assert.is_false(success)
  end)

  it("validates custom format strings with invalid variables", function()
    -- This test covers the error on line 33 of config.lua
    local success = pcall(config.setup, {
      mappings = {
        relative = "<leader>cy",
        custom = "<leader>cc",
      },
      formats = {
        default = "# {filepath}:{line}",
        custom = "# {invalid_custom_var}", -- Invalid variable in custom format
      },
    })

    assert.is_false(success)
  end)

  it("handles missing formats gracefully", function()
    -- Setup with just mappings, no formats table
    local success = pcall(config.setup, {
      mappings = {
        relative = "<leader>cy",
      },
      formats = nil, -- Explicitly nil
    })

    -- Should fail validation because no default format
    assert.is_false(success)
  end)

  it("validates multiple format strings", function()
    local success = pcall(config.setup, {
      mappings = {
        relative = "<leader>cy",
        custom1 = "<leader>c1",
        custom2 = "<leader>c2",
      },
      formats = {
        default = "# {filepath}:{line}",
        custom1 = "# {remote_url}",
        custom2 = "# {filepath}",
      },
    })

    -- All formats are valid, should succeed
    assert.is_true(success)
  end)
end)
