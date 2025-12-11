_G.vim = {
  api = {
    nvim_echo = function() end,
  },
  keymap = {
    set = function() end,
  },
}

local stub = require("luassert.stub")

-- Reload module to avoid cached state
package.loaded["copy_with_context.main"] = nil
package.loaded["copy_with_context.utils"] = nil
package.loaded["copy_with_context.config"] = nil
package.loaded["copy_with_context.formatter"] = nil
package.loaded["copy_with_context.url_builder"] = nil

local main = require("copy_with_context.main")
local utils = require("copy_with_context.utils")
local config = require("copy_with_context.config")
local formatter = require("copy_with_context.formatter")
local url_builder = require("copy_with_context.url_builder")

describe("Main Module", function()
  before_each(function()
    -- Mock dependencies
    stub(utils, "get_lines").returns({ "line 1", "line 2" }, 1, 2)
    stub(utils, "process_lines").returns({ "line 1", "line 2" })
    stub(utils, "get_file_path").returns("/fake/path.lua")
    stub(utils, "copy_to_clipboard")
    stub(formatter, "get_variables").returns({
      filepath = "/fake/path.lua",
      line = "1-2",
      linenumber = "1-2",
      remote_url = "",
      copied_text = "line 1\nline 2",
    })
    stub(formatter, "format").returns("# /fake/path.lua:1-2")
    stub(url_builder, "build_url").returns(nil)
    stub(vim.api, "nvim_echo")
    stub(vim.keymap, "set")
  end)

  after_each(function()
    -- Restore all mocked functions
    utils.get_lines:revert()
    utils.process_lines:revert()
    utils.get_file_path:revert()
    utils.copy_to_clipboard:revert()
    formatter.get_variables:revert()
    formatter.format:revert()
    url_builder.build_url:revert()
    vim.api.nvim_echo:revert()
    vim.keymap.set:revert()
  end)

  it("copies content with context (relative mapping, non-visual mode)", function()
    main.copy_with_context("relative", false)

    assert.stub(utils.get_lines).was_called_with(false)
    assert.stub(utils.process_lines).was_called_with({ "line 1", "line 2" })
    assert.stub(utils.get_file_path).was_called_with(false)
    assert.stub(formatter.get_variables).was_called()
    assert.stub(formatter.format).was_called()
    assert.stub(utils.copy_to_clipboard).was_called()
    assert.stub(vim.api.nvim_echo).was_called()
  end)

  it("copies content with context (absolute mapping, visual mode)", function()
    main.copy_with_context("absolute", true)

    assert.stub(utils.get_lines).was_called_with(true)
    assert.stub(utils.get_file_path).was_called_with(true)
    assert.stub(formatter.get_variables).was_called()
    assert.stub(formatter.format).was_called()
    assert.stub(utils.copy_to_clipboard).was_called()
    assert.stub(vim.api.nvim_echo).was_called()
  end)

  it("copies content with custom mapping", function()
    -- Add custom mapping to config
    config.options.mappings.custom = "<leader>cc"
    config.options.formats.custom = "# {filepath}"

    main.copy_with_context("custom", false)

    assert.stub(utils.get_lines).was_called_with(false)
    assert.stub(utils.process_lines).was_called_with({ "line 1", "line 2" })
    assert.stub(utils.get_file_path).was_called_with(false)
    assert.stub(formatter.get_variables).was_called()
    assert.stub(formatter.format).was_called_with("# {filepath}", match._)
    assert.stub(utils.copy_to_clipboard).was_called()

    -- Cleanup
    config.options.mappings.custom = nil
    config.options.formats.custom = nil
  end)

  it("fetches remote URL only when format uses it", function()
    -- Add remote mapping that uses {remote_url}
    config.options.mappings.remote = "<leader>cr"
    config.options.formats.remote = "# {remote_url}"

    url_builder.build_url:revert()
    stub(url_builder, "build_url").returns(
      "https://github.com/user/repo/blob/abc123/path.lua#L1-L2"
    )

    main.copy_with_context("remote", false)

    -- Should call build_url because format uses {remote_url}
    assert.stub(url_builder.build_url).was_called()

    -- Cleanup
    config.options.mappings.remote = nil
    config.options.formats.remote = nil
  end)

  it("does not fetch remote URL when format doesn't use it", function()
    main.copy_with_context("relative", false)

    -- Should not call build_url because default format doesn't use {remote_url}
    assert.stub(url_builder.build_url).was_not_called()
  end)

  it("handles missing format gracefully", function()
    -- Add mapping without corresponding format to simulate edge case
    config.options.mappings.missing = "<leader>cm"
    -- Don't add format for it (this would normally be caught by validation)

    -- This should not error, just use nil format_string
    main.copy_with_context("missing", false)

    -- Should not call build_url because format_string is nil
    assert.stub(url_builder.build_url).was_not_called()

    -- Cleanup
    config.options.mappings.missing = nil
  end)

  it("sets up key mappings for all defined mappings", function()
    main.setup()

    -- Should set up normal mode mappings
    assert
      .stub(vim.keymap.set)
      .was_called_with("n", config.options.mappings.relative, match._, { silent = false })
    assert
      .stub(vim.keymap.set)
      .was_called_with("n", config.options.mappings.absolute, match._, { silent = false })

    -- Should set up visual mode mappings
    assert
      .stub(vim.keymap.set)
      .was_called_with("x", config.options.mappings.relative, match._, { silent = true })
    assert
      .stub(vim.keymap.set)
      .was_called_with("x", config.options.mappings.absolute, match._, { silent = true })
  end)

  it("sets up key mappings for custom mappings", function()
    -- Add custom mapping
    config.options.mappings.custom = "<leader>cc"
    config.options.formats.custom = "# {filepath}"

    main.setup()

    -- Should set up mappings for custom mapping too
    assert.stub(vim.keymap.set).was_called_with("n", "<leader>cc", match._, { silent = false })
    assert.stub(vim.keymap.set).was_called_with("x", "<leader>cc", match._, { silent = true })

    -- Cleanup
    config.options.mappings.custom = nil
    config.options.formats.custom = nil
  end)

  it("uses output_formats when available (takes precedence over formats)", function()
    -- Add output_formats
    config.options.output_formats = {
      default = "{copied_text}\n\n# {filepath}:{line}",
    }

    main.copy_with_context("relative", false)

    -- Should use output_format, not legacy format
    assert.stub(formatter.format).was_called_with("{copied_text}\n\n# {filepath}:{line}", match._)

    -- Cleanup
    config.options.output_formats = nil
  end)

  it("uses output_formats for custom mapping", function()
    -- Add custom mapping with output_format
    config.options.mappings.markdown = "<leader>cm"
    config.options.output_formats = {
      markdown = "```\n{copied_text}\n```\n\n*{filepath}:{line}*",
    }

    main.copy_with_context("markdown", false)

    -- Should use the output_format
    assert
      .stub(formatter.format)
      .was_called_with("```\n{copied_text}\n```\n\n*{filepath}:{line}*", match._)

    -- Cleanup
    config.options.mappings.markdown = nil
    config.options.output_formats = nil
  end)

  it("falls back to formats when output_formats not defined for mapping", function()
    -- Add custom mapping with only legacy format
    config.options.mappings.custom = "<leader>cc"
    config.options.formats.custom = "# {filepath}"
    config.options.output_formats = {} -- Empty output_formats

    main.copy_with_context("custom", false)

    -- Should use the legacy format
    assert.stub(formatter.format).was_called_with("# {filepath}", match._)

    -- Cleanup
    config.options.mappings.custom = nil
    config.options.formats.custom = nil
    config.options.output_formats = nil
  end)

  it("fetches remote URL when output_format uses it", function()
    -- Add output_format that uses {remote_url}
    config.options.output_formats = {
      default = "{copied_text}\n\n# {remote_url}",
    }

    url_builder.build_url:revert()
    stub(url_builder, "build_url").returns(
      "https://github.com/user/repo/blob/abc123/path.lua#L1-L2"
    )

    main.copy_with_context("relative", false)

    -- Should call build_url because output_format uses {remote_url}
    assert.stub(url_builder.build_url).was_called()

    -- Cleanup
    config.options.output_formats = nil
  end)
end)
