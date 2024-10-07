local M = {}
local timer = nil
local config = require("stopinsert.config").config
local popup = require("stopinsert.popup")

---@return nil
function M.force_exit_insert_mode()
   if vim.fn.mode() == "i" then
      vim.cmd("stopinsert")

      if config.show_popup_msg then
         popup.show("StopInsertPlug: You were idling in Insert mode. Remeber to <Esc> when you finish editing.")
      end
   end
end

---@return nil
function M.reset_timer()
   if timer then
      timer:stop()
   end
   timer = vim.defer_fn(M.force_exit_insert_mode, config.idle_time_ms)
end

---@param ft string
---@return boolean
function M.is_filetype_disabled(ft)
   for _, value in pairs(config.disabled_filetypes) do
      if ft:match(value) then
         return true
      end
   end
   return false
end

return M
