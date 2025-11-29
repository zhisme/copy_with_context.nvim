# copy_with_context.nvim
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Build](https://github.com/zhisme/copy_with_context.nvim/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/zhisme/copy_with_context.nvim/graph/badge.svg?token=T9xjbvS1Za)](https://codecov.io/gh/zhisme/copy_with_context.nvim)
[![Hits-of-Code](https://hitsofcode.com/github/zhisme/copy_with_context.nvim)](https://hitsofcode.com/github/zhisme/copy_with_context.nvim/view)
![GitHub Tag](https://img.shields.io/github/v/tag/zhisme/copy_with_context.nvim)
![GitHub License](https://img.shields.io/github/license/zhisme/copy_with_context.nvim)

Copy lines with file path, line number, and repository URL metadata. Perfect for sharing code snippets with context.

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
  # https://github.com/user/repo/blob/abc123/app/controllers/auth_controller.rb#L45-L47

How do I add OAuth?
```

**Result**: The second prompt gives AI file location, line numbers, project structure insight, and a direct link to the code. AI provides OAuth integration that fits your exact architecture instead of generic advice.

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
          absolute = '<leader>cY',
          remote = '<leader>cr',
        },
        formats = {
          default = '# {filepath}:{line}',  -- Used by relative and absolute mappings
          remote = '# {remote_url}',  -- Custom format for remote mapping
        },
        -- whether to trim lines or not
        trim_lines = false,
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
          absolute = '<leader>cY',
          remote = '<leader>cr',
        },
        formats = {
          default = '# {filepath}:{line}',  -- Used by relative and absolute mappings
          remote = '# {remote_url}',
        },
        -- whether to trim lines or not
        trim_lines = false,
      })
    end
  },
```

## Usage

### Default context

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

### Remote URL Support

5. Copy current line with remote URL:
   - Press `<leader>cr` in normal mode.
   - Plugin copies line under cursor with repository URL into your unnamed register.
   - Paste somewhere
Output example:
```
    <% posts.each do |post| %>
    # https://github.com/user/repo/blob/abc123def/app/views/widgets/show.html.erb#L4
```

6. Copy visual selection with remote URL:
   - Select lines in visual mode.
   - Press `<leader>cr`.
   - Plugin copies the selected lines with repository URL into your unnamed register.
   - Paste somewhere
Output example:
```
    <% posts.each do |post| %>
        <%= post.title %>
    <% end %>
    # https://github.com/user/repo/blob/abc123def/app/views/widgets/show.html.erb#L4-L6
```



## Configuration

There is no need to call setup if you are ok with the defaults.

```lua
-- default options
require('copy_with_context').setup({
    -- Customize mappings
    mappings = {
      relative = '<leader>cy',
      absolute = '<leader>cY',
    },
    -- Define format strings for each mapping
    formats = {
      default = '# {filepath}:{line}',  -- Used by relative and absolute mappings
    },
    -- whether to trim lines or not
    trim_lines = false,
})
```

### Format Variables

You can use the following variables in format strings:

- `{filepath}` - The file path (relative or absolute depending on mapping)
- `{line}` - Line number or range (e.g., "42" or "10-20")
- `{linenumber}` - Alias for `{line}`
- `{remote_url}` - Repository URL (GitHub, GitLab, Bitbucket)
- `{code}` - The selected code content (used with `output_formats`)

### Custom Mappings and Formats

You can define unlimited custom mappings with their own format strings:

```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    absolute = '<leader>cY',
    remote = '<leader>cr',
    full = '<leader>cx', -- Custom mapping with everything
  },
  formats = {
    default = '# {filepath}:{line}',
    remote = '# {remote_url}',
    full = '# {filepath}:{line}\n# {remote_url}',
  },
})
```

**Important**: Every mapping name must have a matching format name. The special mappings `relative` and `absolute` use the `default` format.

In case it fails to find the format for a mapping, it will fail during config load time with an error message. Check your config if that happens, whether everything specified in mappings is also present in formats.

### Full Output Control with `output_formats`

For complete control over the output structure, use `output_formats` instead of `formats`. The `output_formats` option allows you to place the code content anywhere in your output using the `{code}` variable.

```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    markdown = '<leader>cm',
  },
  output_formats = {
    default = "{code}\n\n# {filepath}:{line}",  -- Code first, then context
    markdown = "```lua\n{code}\n```\n\n*{filepath}:{line}*",  -- Wrap in markdown code block
  },
})
```

**Key differences:**
- `formats`: The code is automatically prepended with a newline. Format string only controls the context line.
- `output_formats`: You control the entire output. Typically includes `{code}` token, but it's optional (omit it if you only want to copy metadata without the code content).

When both `formats` and `output_formats` define the same format name, `output_formats` takes precedence.

Example with mixed configuration:
```lua
require('copy_with_context').setup({
  mappings = {
    relative = '<leader>cy',
    markdown = '<leader>cm',
  },
  formats = {
    default = '# {filepath}:{line}',  -- Code is auto-prepended
  },
  output_formats = {
    markdown = "```\n{code}\n```\n\n*{filepath}:{line}*",  -- Code token must be specified
  },
})
```

### Repository URL Support

When you use `{remote_url}` in a format string, the plugin automatically generates permalink URLs for your code snippets. This feature works with:

- **GitHub** (github.com and GitHub Enterprise)
- **GitLab** (gitlab.com and self-hosted instances containing "gitlab" in the domain)
- **Bitbucket** (bitbucket.org and *.bitbucket.org)

The URLs always use the current commit SHA for stable permalinks. If you're not in a git repository or the repository provider is not recognized, the URL will simply be omitted (graceful degradation)

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
              absolute = '<leader>cY',
              remote = '<leader>cr',
              },
              formats = {
                default = '# {filepath}:{line}',
                remote = '# {remote_url}',
              },
              -- whether to trim lines or not
              trim_lines = false,
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
          absolute = '<leader>cY',
          remote = '<leader>cr',
      },
      formats = {
        default = '# {filepath}:{line}',
        remote = '# {remote_url}',
      },
      -- whether to trim lines or not
      trim_lines = false,
  }
}
```
Then restart Neovim or run `:Lazy` sync to load the local version

### Releasing

For maintainers: see [RELEASING.md](./RELEASING.md) for the complete release process.

The guide covers:
- Version numbering (Semantic Versioning)
- Generating release notes from git history
- Creating and publishing releases
- Publishing to LuaRocks

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/zhisme/copy_with_context.nvim.
Ensure to test your solution and provide a clear description of the problem you are solving.
Write new tests for your changes, and make sure the tests pass as well as linters.

## License
The plugin is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
