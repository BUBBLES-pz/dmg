-- Script: DGM_localMoney.lua
-- Description: Adds BMSATM.Money as a local money type with unique functionality.

local LocalMoneySystem = {}

-- Initialize the local money type
function LocalMoneySystem.initialize()
    -- Create a mapping for local money type
    if not getActivatedMods():contains("BetterMoneySystem") then
        print("BetterMoneySystem mod is not active. Local money type script will not load.")
        return
    end

    -- Define a local money type table
    LocalMoneySystem.moneyType = {
        name = "BMSATM.Money",
        displayName = "Local Money",
        description = "A local currency used exclusively in specific shops.",
        icon = "media/textures/Item_BMSATMMoney.png"
    }

    -- Add money type to the system
    if not getScriptManager():FindItem(LocalMoneySystem.moneyType.name) then
        getScriptManager():AddItem(LocalMoneySystem.moneyType.name, LocalMoneySystem.moneyType)
        print("Added local money type: " .. LocalMoneySystem.moneyType.name)
    end
end

-- Hook into the game to initialize the local money type
Events.OnGameBoot.Add(LocalMoneySystem.initialize)