--[[
    Snaily Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = true,
    pluginName = "wraithv2", -- name your plugin here
    pluginAuthor = "TaylorMcGaw-LARP", -- author
    configVersion = "1.0"
    -- alert if no registration was found on scan?
    ,alertNoRegistration = true 
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end