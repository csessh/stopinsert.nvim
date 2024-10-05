local M = {}

M.config = {
   idle_time_ms = 5000,
   disabled_filetypes = {
      "TelescopePrompt",
      "checkhealth",
      "help",
      "lspinfo",
      "mason",
      "neo%-tree*",
      "dashboard",
   },
}

---@param user_config table
---@return nil
function M.set(user_config)
   for key, value in pairs(user_config) do
      M.config[key] = value
   end
end

return M
