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

function M.set(user_config)
    for option, value in pairs(user_config) do
        if type(value) == "table" and #value == 0 then
            for k, v in pairs(value) do
                if next(v) == nil then
                    M.config[option][k] = nil
                else
                    M.config[option][k] = v
                end
            end
        else
            M.config[option] = value
        end
    end
end

return M
