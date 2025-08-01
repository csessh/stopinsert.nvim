# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

stopinsert.nvim is a Neovim plugin that automatically exits Insert mode after a configurable period of inactivity. It helps users develop better vim habits by preventing them from staying in Insert mode unnecessarily.

## Development Commands

### Testing
```bash
make test
```
Uses plenary.nvim to run test specs in the `tests/` directory with `plenary.busted`.

### Code Formatting
```bash
stylua .
```
Format Lua code according to the configuration in `stylua.toml` (3-space indentation, 90 column width).

## Code Architecture

### Module Structure
The plugin follows a modular Lua architecture:

- `lua/stopinsert/init.lua` - Main entry point with setup() function and user commands
- `lua/stopinsert/config.lua` - Configuration management and default values
- `lua/stopinsert/util.lua` - Core timer logic and filetype checking
- `lua/stopinsert/popup.lua` - Popup message display functionality

### Key Components

**Timer System**: The plugin uses `vim.defer_fn()` to create a timer that triggers after idle time. The timer is reset on every keypress in Insert mode via `vim.on_key()`.

**Filetype Filtering**: Uses pattern matching against `disabled_filetypes` list to exclude specific buffer types (TelescopePrompt, help, etc.).

**Guard Function**: Optional user-provided function that can prevent the plugin from exiting Insert mode (useful for completion menus).

**User Commands**: Provides `:StopInsertPlug` command with subcommands (enable, disable, toggle, status) for runtime control.

### Event Handling
- `InsertEnter` autocmd starts the timer when entering Insert mode
- `vim.on_key()` callback resets timer on any keypress in Insert mode
- Timer callback uses `vim.cmd("stopinsert")` to exit Insert mode

## Testing Setup

Tests use plenary.nvim with a minimal Neovim configuration (`tests/minimal_init.lua`). The test suite focuses on utility functions in `tests/util_spec.lua`.