# copy_with_context.nvim
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Build](https://github.com/zhisme/copy_with_context.nvim/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/zhisme/copy_with_context.nvim/graph/badge.svg?token=T9xjbvS1Za)](https://codecov.io/gh/zhisme/copy_with_context.nvim)
[![Hits-of-Code](https://hitsofcode.com/github/zhisme/copy_with_context.nvim)](https://hitsofcode.com/github/zhisme/copy_with_context.nvim/view)
![GitHub Tag](https://img.shields.io/github/v/tag/zhisme/copy_with_context.nvim)
![GitHub License](https://img.shields.io/github/license/zhisme/copy_with_context.nvim)

Copy lines with file path and line number metadata. Perfect for sharing code snippets with context.

## Why?

When sharing code snippets, it's often useful to include the file path and line number for context. This plugin makes it easy to copy lines with this metadata. It is easier to understand the context of the code snippet when the file path and line number are included. Otherwise you have to do it manually. Copying snippet, then adding the line number (what if it is long config file? it is boring). We can automate it and do not waste our time.

## 🤖 Very Useful for AI-Assisted Development

**Working with AI assistants on the web** (ChatGPT, Claude, Gemini, etc.)? Including line numbers and file paths gives you significantly better results.

### Why It Matters

- **Precise context**: AI knows exactly which line you mean, not "somewhere in that function"
- **Better suggestions**: File paths like `src/auth/login.ts:42` help AI understand your project structure
- **Faster workflow**: No back-and-forth clarifying which file or function you're referring to
- **Accurate responses**: AI provides solutions that fit your actual codebase, not generic answers

### Example

❌ **Without context**:
```
Here's my login function:
  def authenticate(user)
    validate_credentials(user)
  end

How do I add OAuth?
```

✅ **With context** (using this plugin):
```
Here's my login function:
  def authenticate(user)
    validate_credentials(user)
  end
  # app/controllers/auth_controller.rb:45-47

How do I add OAuth?
```

**Result**: The second prompt gives AI file location, line numbers, and project structure insight. AI provides OAuth integration that fits your exact architecture instead of generic advice.

## Installation

- Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
call plug#begin()

" Other plugins...
Plug 'zhisme/copy_with_context.nvim'

call plug#end()
```


- Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'zhisme/copy_with_context.nvim',
    config = function()
      require('copy_with_context').setup({
        -- Customize mappings
        mappings = {
          relative = '<leader>cy',
          absolute = '<leader>cY'
        },
        -- whether to trim lines or not
        trim_lines = false,
        context_format = '# %s:%s', -- Default format for context: "# Source file: filepath:line"
      })
    end
  }
```

- Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    'zhisme/copy_with_context.nvim',
    config = function()
      require('copy_with_context').setup({
        -- Customize mappings
        mappings = {
          relative = '<leader>cy',
          absolute = '<leader>cY'
        },
        -- whether to trim lines or not
        trim_lines = false,
        context_format = '# %s:%s', -- Default format for context: "# Source file: filepath:line"
      })
    end
  },
```

## Usage

1. Copy current line with relative path:
   - Press `<leader>cy` in normal mode.
   - Plugin copies line under cursor with relative path into your unnamed register.
   - Paste somewhere

Output example:
```
  <% posts.each do |post| %>
  # app/views/widgets/show.html.erb:4
```

2. Copy current line with absolute path:
   - Press `<leader>cY` in normal mode.
   - Plugin copies line under cursor with absolute path into your unnamed register.
   - Paste somewhere

Output example:
```
  <% posts.each do |post| %>
  # /Users/zh/dev/project_name/app/views/widgets/show.html.erb:4
```

3. Copy visual selection with relative path:
   - Select lines in visual mode.
   - Press `<leader>cY`.
   - Plugin copies the selected lines with relative path into your unnamed register.
   - Paste somewhere

Output example:
```
  <% posts.each do |post| %>
    <%= post.title %>
  <% end %>
  # app/views/widgets/show.html.erb:4-6
```

4. Copy visual selection with absolute path:
   - Select lines in visual mode.
   - Press `<leader>cY`.
   - Plugin copies the selected lines with absolute path into your unnamed register.
   - Paste somewhere

Output example:
```
  <% posts.each do |post| %>
    <%= post.title %>
  <% end %>
  # /Users/zh/dev/project_name/app/views/widgets/show.html.erb:4-6
```

## Configuration

There is no need to call setup if you are ok with the defaults.

```lua
-- default options
require('copy_with_context').setup({
    -- Customize mappings
    mappings = {
      relative = '<leader>cy',
      absolute = '<leader>cY'
    },
    -- whether to trim lines or not
    trim_lines = false,
    context_format = '# %s:%s',  -- Default format for context: "# Source file: filepath:line"
  -- context_format = '# Source file: %s:%s',
  -- Other format for context: "# Source file: /path/to/file:123"
})
```

## Development
Want to contribute to `copy_with_context.nvim`? Here's how to set up your local development environment:

### Prerequisites
- Neovim (version 0.7.0 or higher)
- Lua (5.1 or higher)
- Cargo (Rust build tool for running stylua) [Install](https://www.rust-lang.org/learn/get-started)

### Setup
1. Fork the repository
2. Clone your fork:
```sh
git clone https://github.com/zhisme/copy_with_context.nvim
cd copy_with_context.nvim
```
3. Install dependencies with Makefile.
```
make deps
```

### Tests
Tests are written in test framework [busted](https://lunarmodules.github.io/busted/)

How to run tests:
```sh
make test
```

### Linting
Linting is done with [luacheck](https://github.com/mpeterv/luacheck)
```sh
make lint
```

### Formatting
Formatting is done with [stylua](https://github.com/JohnnyMorganz/StyLua)

To automatically format the code, run:
```sh
make fmt
```

To check if the code is formatted correctly, run:
```sh
make fmt-check
```

### Testing Your Changes Locally
To test the plugin in your Neovim environment while developing:

With packer.nvim:
```lua
use {
  "~/path/to/copy_with_context.nvim",
  config = function()
      require('copy_with_context').setup({
              -- Customize mappings
              mappings = {
              relative = '<leader>cy',
              absolute = '<leader>cY'
              },
              -- whether to trim lines or not
              trim_lines = false,
              context_format = '# %s:%s',  -- Default format for context: "# filepath:line"
              -- context_format = '# Source file: %s:%s',
              -- Other format for context: "# Source file: /path/to/file:123"
              })
  end
}
```
Then run `:PackerSync` to load the local version

With lazy.nvim:
```lua
{
  dir = "~/path/to/copy_with_context.nvim",
  dev = true,
  opts = {
      mappings = {
          relative = '<leader>cy',
          absolute = '<leader>cY'
      },
      -- whether to trim lines or not
      trim_lines = false,
      context_format = '# %s:%s',  -- Default format for context: "# filepath:line"
      -- context_format = '# Source file: %s:%s',
      -- Other format for context: "# Source file: /path/to/file:123"
  }
}
```
Then restart Neovim or run `:Lazy` sync to load the local version

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/zhisme/copy_with_context.nvim.
Ensure to test your solution and provide a clear description of the problem you are solving.
Write new tests for your changes, and make sure the tests pass as well as linters.

## License
The plugin is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
