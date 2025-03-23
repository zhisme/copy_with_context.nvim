# copy_with_context.nvim
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
[![Hits-of-Code](https://hitsofcode.com/github/zhisme/copy_with_context.nvim)](https://hitsofcode.com/github/zhisme/copy_with_context.nvim/view)
![GitHub Tag](https://img.shields.io/github/v/tag/zhisme/copy_with_context.nvim)
![GitHub License](https://img.shields.io/github/license/zhisme/copy_with_context.nvim)

Copy lines with file path and line number metadata. Perfect for sharing code snippets with context.

## Why?

When sharing code snippets, it's often useful to include the file path and line number for context. This plugin makes it easy to copy lines with this metadata. It is easier to understand the context of the code snippet when the file path and line number are included. Otherwise you have to do it manually. Copying snippet, then adding the line number (what if it is long config file? it is boring). We can automate it and do not waste our time.

## Installation

- Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  'zhisme/copy_with_context.nvim'
})
```

- Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
call plug#begin()

" Other plugins...
Plug 'zhisme/copy_with_context.nvim'

call plug#end()
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
    trim_lines = true,
    context_format = '# %s:%s',  -- Default format for context: "# Source file: filepath:line"
  -- context_format = '# Source file: %s:%s',
  -- Other format for context: "# Source file: /path/to/file:123"
})
```

## Testing
After cloning the repository, run the following command to run the tests:
```
make test
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/zhisme/copy_with_context.nvim. Ensure to test your solution and provide a clear description of the problem you are solving.

## License
The plugin is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
