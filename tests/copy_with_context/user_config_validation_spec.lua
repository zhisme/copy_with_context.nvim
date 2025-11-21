local validation = require("copy_with_context.user_config_validation")

describe("User Config Validation", function()
  describe("validate", function()
    it("accepts nil config", function()
      local valid, err = validation.validate(nil)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts empty config", function()
      local valid, err = validation.validate({})
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid config with default mapping", function()
      local config = {
        mappings = {
          relative = "<leader>cy",
          absolute = "<leader>cY",
        },
        formats = {
          default = "# {filepath}:{line}",
        },
      }

      local valid, err = validation.validate(config)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid config with custom mappings", function()
      local config = {
        mappings = {
          relative = "<leader>cy",
          custom = "<leader>cc",
        },
        formats = {
          default = "# {filepath}:{line}",
          custom = "# {remote_url}",
        },
      }

      local valid, err = validation.validate(config)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("rejects mapping without matching format", function()
      local config = {
        mappings = {
          custom = "<leader>cc",
        },
        formats = {
          default = "# {filepath}:{line}",
          -- missing 'custom' format
        },
      }

      local valid, err = validation.validate(config)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("custom", err)
    end)

    it("rejects format without matching mapping", function()
      local config = {
        mappings = {
          relative = "<leader>cy",
        },
        formats = {
          default = "# {filepath}:{line}",
          orphan = "# {filepath}",
        },
      }

      local valid, err = validation.validate(config)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("orphan", err)
    end)

    it("requires default format for relative mapping", function()
      local config = {
        mappings = {
          relative = "<leader>cy",
        },
        formats = {
          -- missing default format
        },
      }

      local valid, err = validation.validate(config)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("relative", err)
      assert.matches("default", err)
    end)

    it("requires default format for absolute mapping", function()
      local config = {
        mappings = {
          absolute = "<leader>cY",
        },
        formats = {
          -- missing default format
        },
      }

      local valid, err = validation.validate(config)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("absolute", err)
      assert.matches("default", err)
    end)

    it("allows default format without explicit mapping", function()
      local config = {
        mappings = {
          relative = "<leader>cy",
        },
        formats = {
          default = "# {filepath}:{line}",
        },
      }

      local valid, err = validation.validate(config)
      assert.is_true(valid)
      assert.is_nil(err)
    end)
  end)

  describe("validate_format_string", function()
    it("accepts valid format with filepath", function()
      local valid, err = validation.validate_format_string("# {filepath}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid format with line", function()
      local valid, err = validation.validate_format_string("# {line}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid format with linenumber", function()
      local valid, err = validation.validate_format_string("# {linenumber}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid format with remote_url", function()
      local valid, err = validation.validate_format_string("# {remote_url}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid format with multiple variables", function()
      local valid, err = validation.validate_format_string("# {filepath}:{line} - {remote_url}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts format with no variables", function()
      local valid, err = validation.validate_format_string("# No variables here")
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("rejects nil format string", function()
      local valid, err = validation.validate_format_string(nil)
      assert.is_false(valid)
      assert.is_not_nil(err)
    end)

    it("rejects unknown variable", function()
      local valid, err = validation.validate_format_string("# {invalid_var}")
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("invalid_var", err)
    end)

    it("rejects format with multiple unknown variables", function()
      local valid, err = validation.validate_format_string("# {filepath} {unknown1} {unknown2}")
      assert.is_false(valid)
      assert.is_not_nil(err)
      -- Should error on first unknown variable
      assert.matches("unknown", err)
    end)

    it("accepts repeated valid variables", function()
      local valid, err = validation.validate_format_string("# {filepath} - {filepath}")
      assert.is_true(valid)
      assert.is_nil(err)
    end)
  end)
end)
