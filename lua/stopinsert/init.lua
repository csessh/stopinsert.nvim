local M = {}
local util = require("stopinsert.util")

---@param opts table
---@return nil
function M.setup(opts)
   opts = opts or {}
   require("stopinsert.config").set(opts)

   vim.api.nvim_create_autocmd("InsertEnter", {
      group = vim.api.nvim_create_augroup("InsertEnterListener", { clear = true }),
      callback = function()
         if not util.is_filetype_disabled(vim.bo.ft) then
            util.reset_timer()
         end
      end,
   })

   vim.on_key(function(_, _)
      if vim.fn.mode() == "i" and not util.is_filetype_disabled(vim.bo.ft) then
         util.reset_timer()
      end
   end)
end

return M
