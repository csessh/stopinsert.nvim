local M = {}

--- Create a simple popup message, positioned in the bottom right corner of the buffer
--- Automatically close this popup after 5 seconds
--- Courtersy of encourage.nvim
---@param message string
---@return nil
function M.show(message)
   local width = #message
   local height = 1
   local buf = vim.api.nvim_create_buf(false, true)
   local current_win = vim.api.nvim_get_current_win()
   local win_config = vim.api.nvim_win_get_config(current_win)
   local win_width = win_config.width
   local win_height = win_config.height

   local opts = {
      style = "minimal",
      relative = "win",
      win = current_win,
      width = width,
      height = height,
      row = win_height - height - 2,
      col = win_width - width - 2,
      border = "rounded",
   }

   local win = vim.api.nvim_open_win(buf, false, opts)
   vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })
   vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")

   vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
         vim.api.nvim_win_close(win, true)
      end
   end, 5000)
end

return M
