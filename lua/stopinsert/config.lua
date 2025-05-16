local M = {}

--- Configuration options for StopInsert
M.config = {
   --- Time in milliseconds after which insert mode will be exited if no keys are pressed.
   idle_time_ms = 5000,

   --- Whether to show a popup message when exiting insert mode due to inactivity.
   show_popup_msg = true,

   --- Time in milliseconds after which the popup message will be cleared.
   clear_popup_ms = 5000,

   --- List of filetypes where StopInsert should be disabled.
   disabled_filetypes = {
      "TelescopePrompt",
      "checkhealth",
      "help",
      "lspinfo",
      "mason",
      "neo%-tree*",
   },

   --- Optional function that returns a boolean. If true, prevents stopinsert.
   stopinsert_guard = nil,
}

---@param user_config table
---@return nil
function M.set(user_config)
   for key, value in pairs(user_config) do
      M.config[key] = value
   end
end

return M
