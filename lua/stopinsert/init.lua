local M = {}
local config = require("stopinsert.config").config
local timer = nil

local function force_exit_insert_mode()
    vim.cmd("stopinsert")
end

function M.setup(user_config)
    if vim.fn.has("nvim-0.10.0") == 0 then
        return vim.notify("stopinsert.nvim requires Neovim >= v0.10.0")
    end

    user_config = user_config or {}
    require("stopinsert.config").set(user_config)

    vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
            timer = vim.defer_fn(force_exit_insert_mode, config.idle_time_ms)
        end,
    })

    vim.on_key(function(_, _)
        if vim.fn.mode() ~= "i" then
            return
        end

        if timer then
            timer:stop()
        end
        timer = vim.defer_fn(force_exit_insert_mode, config.idle_time_ms)
    end)
end

return M
