## Intro

`stopinsert` is a vim command (see [vimdoc](https://vimdoc.sourceforge.net/htmldoc/insert.html)) that works like typing `<Esc>` in Insert mode.

This plugin automatically kicks you out of Insert mode after certain amount of time of inactivity.

## Installation

1. Let your favourite package manager do the work:

```lua
-- lazy.nvim
{
    "csessh/stopinsert.nvim",
    opts = {}
},
```

2. Setup the plugin in your `init.lua`. This step is not needed with lazy.nvim if `opts` is set.

```lua
require("stopinsert").setup()
```

## Configuration

| Items                 | Type      | Default Value      | Description    |
| --------------------- | --------- | ------------------ | -------------- |
| `idle_time_ms`        | number    | `5000` (5 seconds) | Maximum time (in milliseconds) before you are forced out of Insert mode back to Normal mode. |
| `disabled_filetypes`  | list     | `{ "TelescopePrompt", "checkhealth", "help", "lspinfo", "mason", "neo%-tree*", }` | List of filetypes to exclude the effect of this plugin. |

**NOTE:**
By default, `stopinsert.nvim` excludes a list of filetypes, as shown in the table above. 

If you configure this attribute in `opts` with your package manager, like so, your list will replace `stopinsert.nvim` defaults.

<!-- panvimdoc-ignore-start -->
## Contribution

See [CONTRIBUTING.md](./CONTRIBUTING.md).
<!-- panvimdoc-ignore-end -->
