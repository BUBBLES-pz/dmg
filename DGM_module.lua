-- Script: DGM_module.lua
-- Description: Handles client commands and interactions with the shop module.

-- Event Registration
Events.OnClientCommand.Add(onClientCommand)

local itemDictionaryUpdated = false -- Needed for better sorting to work in multiplayer
local _internal = require "shop-shared"

local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "shop" then return end
    _data = _data or {}

    -- Use sandbox variable for custom behavior
    local useCustomWallet = SandboxVars.CustomVars.EnableCustomWallet or false

    if _command == "updateItemDictionary" then
        if itemDictionaryUpdated then return end
        itemDictionaryUpdated = true
        local itemsToCategories = _data.itemsToCategories
        local scriptManager = getScriptManager()
        for moduleType, displayCategory in pairs(itemsToCategories) do
            local scriptFound = scriptManager:getItem(moduleType)
            if scriptFound then scriptFound:DoParam("DisplayCategory = " .. displayCategory) end
        end
    end

    -- Other commands remain unchanged...
end