-- Script: MoneyToWallet.lua
-- Description: Adds functionality to transfer BMSATM.Money into Base.Wallet in Project Zomboid version 41.78.
-- Assigns BMSATM.Money as Base.Money for compatibility.

local function putMoneyInWallet(player)
    -- Ensure the player exists
    if player == nil then
        print("Player does not exist.")
        return
    end

    -- Get the player's inventory
    local inventory = player:getInventory()

    -- Check if the player has BMSATM.Money
    local moneyItem = inventory:FindAndReturn("BMSATM.Money")
    if moneyItem == nil then
        player:Say("I don't have any money to put in the wallet.")
        return
    end

    -- Treat BMSATM.Money as Base.Money for compatibility
    local baseMoneyItem = inventory:FindAndReturn("Base.Money")
    if baseMoneyItem == nil then
        -- If no Base.Money exists, assign BMSATM.Money to it
        inventory:AddItem("Base.Money")
        baseMoneyItem = inventory:FindAndReturn("Base.Money")
    end

    -- Check if the player has a Base.Wallet
    local walletItem = inventory:FindAndReturn("Base.Wallet")
    if walletItem == nil then
        player:Say("I don't have a wallet.")
        return
    end

    -- Get the amount of money
    local moneyAmount = moneyItem:getCount()
    if moneyAmount <= 0 then
        player:Say("No money to transfer.")
        return
    end

    -- Add money to the wallet
    local walletData = walletItem:getModData()
    walletData.money = (walletData.money or 0) + moneyAmount

    -- Remove money from inventory
    inventory:Remove(moneyItem)

    -- Notify the player
    player:Say("Transferred " .. tostring(moneyAmount) .. " money to the wallet.")
end

-- Hook into the game to add a "Put Money in Wallet" option in the context menu
Events.OnFillWorldObjectContextMenu.Add(function(playerIndex, context, worldObjects)
    local player = getSpecificPlayer(playerIndex)
    if player then
        local inventory = player:getInventory()
        if inventory:FindAndReturn("BMSATM.Money") and inventory:FindAndReturn("Base.Wallet") then
            context:addOption("Put BMSATM.Money in Wallet", player, putMoneyInWallet)
        end
    end
end)