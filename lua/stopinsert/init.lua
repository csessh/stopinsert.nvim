local M = {}
local config = require("stopinsert.config").config
local timer = nil

---@return nil
local function force_exit_insert_mode()
   vim.cmd("stopinsert")
end

---@return nil
local function reset_timer()
   if timer then
      timer:stop()
   end
   timer = vim.defer_fn(force_exit_insert_mode, config.idle_time_ms)
end

---@param user_config table
---@return nil
function M.setup(user_config)
   user_config = user_config or {}
   require("stopinsert.config").set(user_config)

   vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
         reset_timer()
      end,
   })

   vim.on_key(function(_, _)
      if vim.fn.mode() ~= "i" then
         return
      end
      reset_timer()
   end)
end

return M
