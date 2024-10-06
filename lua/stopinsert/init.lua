local M = {}
local util = require("stopinsert.util")
M.enable = true

local commands = {
   enable = function()
      M.enable = true
   end,
   disable = function()
      M.enable = false
   end,
   toggle = function()
      M.enable = not M.enable
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
         if not M.enable and not util.is_filetype_disabled(vim.bo.ft) then
            return
         end
         util.reset_timer()
      end,
   })

   vim.on_key(function(_, _)
      if not M.enable and not util.is_filetype_disabled(vim.bo.ft) then
         return
      end

      if vim.fn.mode() ~= "i" then
         return
      end

      util.reset_timer()
   end)

   vim.api.nvim_create_user_command("StopInsertPlug", function(cmd)
      if commands[cmd.args] then
         commands[cmd.args]()
      end
   end, {
      nargs = 1,
      complete = function()
         return { "enable", "disable", "toggle" }
      end,
   })
end

return M
