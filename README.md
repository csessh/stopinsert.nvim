## Intro

`stopinsert` is a vim command (see [vimdoc](https://vimdoc.sourceforge.net/htmldoc/insert.html)) that works like hitting `<Esc>` in Insert mode.

This plugin automatically kicks you out of Insert mode after certain amount of time of inactivity.

<!-- panvimdoc-ignore-start -->
<h1 align="center">
    <a href="https://dotfyle.com/plugins/csessh/stopinsert.nvim">
        <img src="https://dotfyle.com/plugins/csessh/stopinsert.nvim/shield?style=for-the-badge" />
    </a>
</h1>
<!-- panvimdoc-ignore-end -->

## Installation

1. Let your favourite package manager do the work:

```lua
-- lazy.nvim
{
    "csessh/stopinsert.nvim",
    dependencies = {
        -- "hrsh7th/nvim-cmp",
        "saghen/blink.cmp",
    },
    opts = {
        -- Configuration options (see Configuration section below for details)
        idle_time_ms = 5000, -- Maximum time (in milliseconds) before you are forced out of Insert mode
        show_popup_msg = true, -- Enable/disable popup message
        clear_popup_ms = 5000, -- Maximum time (in milliseconds) for which the popup message hangs around
        disabled_filetypes = { -- List of filetypes to exclude the effect of this plugin.
            "TelescopePrompt",
            "checkhealth",
            "help",
            "lspinfo",
            "mason",
            "neo%-tree*",
        },
        guard_func = function() -- Optional function that returns a boolean. If true, prevents stopinsert.
          -- return require('cmp').visible_docs()
          return require("blink.cmp").is_documentation_visible()
        end,
    }
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
| `show_popup_msg`      | boolean   | `true`            | Enable/disable popup message" |
| `clear_popup_ms`      | number   | `5000`            | Maximum time (in milliseconds) for which the popup message hangs around |
| `disabled_filetypes`  | list     | `{ "TelescopePrompt", "checkhealth", "help", "lspinfo", "mason", "neo%-tree*", }` | List of filetypes to exclude the effect of this plugin. |
| `guard_func` | function | `nil` | Optional function that returns a boolean. If true, prevents stopinsert. |

**NOTE:**
By default, `stopinsert.nvim` excludes a list of filetypes, as shown in the table above.

If you configure this attribute in `opts` with your package manager, like so, your list will replace `stopinsert.nvim` defaults.

Filetypes can also be listed as regex, such as `neo%-tree*`.

## User command

`stopinsert.nvim` is enabled by default. You can toggle its state on the fly with the following commands:

```
:StopInsertPlug enable
:StopInsertPlug disable
:StopInsertPlug toggle
:StopInsertPlug status
```

Each of them does exactly what it says on the tin.

## Contribution

All contributions are most welcome! Please open a PR or create an [issue](https://github.com/csessh/stopinsert.nvim/issues).

### Coding Style

- Follow the coding style of [LuaRocks](https://github.com/luarocks/lua-style-guide).
- Make sure you format the code with [StyLua](https://github.com/JohnnyMorganz/StyLua) before PR.
