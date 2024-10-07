local M = {}
local util = require("stopinsert.util")
M.enable = true

local user_cmds = {
   enable = function()
      M.enable = true
   end,
   disable = function()
      M.enable = false
   end,
   toggle = function()
      M.enable = not M.enable
   end,
   status = function()
      if M.enable then
         print("StopInsert is active")
      else
         print("StopInsert is inactive")
      end
   end,
}

---@param opts table
---@return nil
function M.setup(opts)
   opts = opts or {}
   require("stopinsert.config").set(opts)

   vim.api.nvim_create_autocmd("InsertEnter", {
      group = vim.api.nvim_create_augroup("InsertEnterListener", { clear = true }),
      callback = function()
         if not M.enable then
            return
         end

         if util.is_filetype_disabled(vim.bo.ft) then
            return
         end

         util.reset_timer()
      end,
   })

   vim.on_key(function(_, _)
      if vim.fn.mode() ~= "i" then
         return
      end

      if not M.enable then
         return
      end

      if util.is_filetype_disabled(vim.bo.ft) then
         return
      end

      util.reset_timer()
   end)

   vim.api.nvim_create_user_command("StopInsertPlug", function(cmd)
      if user_cmds[cmd.args] then
         user_cmds[cmd.args]()
      end
   end, {
      nargs = 1,
      complete = function()
         return {
            "enable",
            "disable",
            "toggle",
            "status",
         }
      end,
   })
end

return M
