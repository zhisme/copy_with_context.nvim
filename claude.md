# copy_with_context.nvim

## Project Overview

copy_with_context.nvim is a Neovim plugin that simplifies sharing code snippets by automatically copying selected lines along with their file path and line number metadata. This eliminates the manual process of adding context information when sharing code, making collaboration and code review more efficient.

## Purpose

When sharing code snippets with teammates, in documentation, or during code reviews, it's essential to provide context about where the code is located. This plugin automates that process by:
- Copying the selected code/line(s)
- Automatically appending file path and line number(s) as a comment
- Supporting both relative and absolute file paths
- Working with both single lines and visual selections

## Key Features

- **Single Line Copy**: Copy the current line with context using a simple keymap
- **Visual Selection**: Copy multiple lines with a line range indicator
- **Flexible Path Options**: Choose between relative or absolute file paths
- **Customizable Format**: Configure the context comment format to match your needs
- **Optional Line Trimming**: Choose whether to trim whitespace from copied lines
- **Configurable Keymaps**: Set your own preferred key mappings

## Architecture

### File Structure

```
copy_with_context.nvim/
├── lua/copy_with_context/
│   ├── init.lua       # Plugin entry point and setup function
│   ├── config.lua     # Configuration management and defaults
│   ├── main.lua       # Core copy functionality and keymap setup
│   └── utils.lua      # Utility functions (line extraction, formatting, clipboard)
├── plugin/
│   └── copy_with_context.lua  # Plugin loader
├── doc/
│   └── copy_with_context.txt  # Vim help documentation
└── tests/
    └── copy_with_context/     # Test suite using busted
```

### Module Responsibilities

**init.lua** (lua/copy_with_context/init.lua:1)
- Entry point for the plugin
- Delegates to config and main modules
- Provides the `setup()` function users call

**config.lua** (lua/copy_with_context/config.lua:1)
- Stores default configuration
- Merges user-provided options with defaults
- Manages:
  - Key mappings (relative/absolute path shortcuts)
  - Context format string
  - Line trimming preference

**main.lua** (lua/copy_with_context/main.lua:1)
- Core functionality: `copy_with_context(absolute_path, is_visual)`
- Sets up keymaps for normal and visual modes
- Orchestrates the copy operation
- Provides user feedback via `nvim_echo`

**utils.lua** (lua/copy_with_context/utils.lua:1)
- `get_lines(is_visual)`: Extracts lines from buffer
- `get_file_path(absolute)`: Gets file path (relative or absolute)
- `format_line_range(start, end)`: Formats line numbers (e.g., "5" or "5-10")
- `process_lines(lines)`: Applies trim_lines setting if enabled
- `copy_to_clipboard(output)`: Copies to both `*` and `+` registers
- `format_output(content, path, range)`: Combines code and context comment

## Configuration

### Default Settings

```lua
{
  mappings = {
    relative = "<leader>cy",  -- Copy with relative path
    absolute = "<leader>cY",  -- Copy with absolute path
  },
  context_format = "# %s:%s", -- Comment format: "# filepath:line"
  trim_lines = false,         -- Preserve leading/trailing whitespace
}
```

### Setup Example

```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY'
  },
  trim_lines = false,
  context_format = '# %s:%s',  -- Can be customized to any format
})
```

## Usage

### Normal Mode
- `<leader>cy`: Copy current line with relative path
- `<leader>cY`: Copy current line with absolute path

### Visual Mode
- Select lines, then `<leader>cy`: Copy selection with relative path
- Select lines, then `<leader>cY`: Copy selection with absolute path

### Output Format Examples

**Single line with relative path:**
```
  <% posts.each do |post| %>
  # app/views/widgets/show.html.erb:4
```

**Multiple lines with absolute path:**
```
  <% posts.each do |post| %>
    <%= post.title %>
  <% end %>
  # /Users/zh/dev/project_name/app/views/widgets/show.html.erb:4-6
```

## Development

### Prerequisites
- Neovim 0.7.0+
- Lua 5.1+
- Cargo (for stylua)

### Setup
```bash
git clone https://github.com/zhisme/copy_with_context.nvim
cd copy_with_context.nvim
make deps  # Install development dependencies
```

### Testing
The project uses [busted](https://lunarmodules.github.io/busted/) for testing:
```bash
make test          # Run test suite
```

Test files are located in `tests/copy_with_context/`:
- `config_spec.lua`: Configuration tests
- `main_spec.lua`: Core functionality tests
- `utils_spec.lua`: Utility function tests

### Code Quality
```bash
make lint          # Run luacheck
make fmt           # Format code with stylua
make fmt-check     # Check formatting
```

### Local Testing

**With packer.nvim:**
```lua
use {
  "~/path/to/copy_with_context.nvim",
  config = function()
    require('copy_with_context').setup({
      mappings = {
        relative = '<leader>cy',
        absolute = '<leader>cY'
      },
      trim_lines = false,
      context_format = '# %s:%s',
    })
  end
}
```

**With lazy.nvim:**
```lua
{
  dir = "~/path/to/copy_with_context.nvim",
  dev = true,
  opts = {
    mappings = {
      relative = '<leader>cy',
      absolute = '<leader>cY'
    },
    trim_lines = false,
    context_format = '# %s:%s',
  }
}
```

## Technical Details

### Clipboard Integration
The plugin copies to both the `*` (system selection) and `+` (system clipboard) registers for maximum compatibility across different systems.

### Visual Mode Support
Uses Vim's marks `'<` and `'>` to get the visual selection range, ensuring accurate line extraction even after exiting visual mode.

### Path Handling
- Relative path: Uses `vim.fn.expand("%")`
- Absolute path: Uses `vim.fn.expand("%:p")`

## Contributing

Contributions are welcome! Please:
1. Write tests for new features
2. Ensure all tests pass (`make test`)
3. Run linters (`make lint`)
4. Format code (`make fmt`)
5. Provide clear descriptions in PRs
6. Use conventional commit messages for consistency. Each commit message should contain the following (feat:, fix:, docs:, style:, refactor:, test:, chore:)

## License

MIT License

## Links

- Repository: https://github.com/zhisme/copy_with_context.nvim
- Issues: https://github.com/zhisme/copy_with_context.nvim/issues
- Author: Evgeny Zhdanov (evdev34@gmail.com)
