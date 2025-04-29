-- Integration Script for pz-shops-and-traders and BetterMoneySystem in Project Zomboid

-- Ensure both mods are loaded
if not getActivatedMods():contains("pz-shops-and-traders") or not getActivatedMods():contains("BetterMoneySystem") then
    print("pz-shops-and-traders or BetterMoneySystem mod is not active. Integration script will not load.")
    return
end

-- Set BetterMoneySystem to BMSATM or BMSATM.Money
if not (BMSATM or BMSATM.Money) then
    print("Error: BetterMoneySystem is not correctly initialized.")
    return
end
local BetterMoneySystem = BMSATM or BMSATM.Money

-- Function to get player's balance
function BetterMoneySystem.getBalance(player)
    if player:getModData().moneyBalance then
        return player:getModData().moneyBalance
    else
        player:getModData().moneyBalance = 0 -- Initialize balance if not set
        return 0
    end
end

-- Function to add money to player's account
function BetterMoneySystem.addBalance(player, amount)
    local currentBalance = BetterMoneySystem.getBalance(player)
    player:getModData().moneyBalance = currentBalance + amount
    print("Added " .. tostring(amount) .. " to " .. player:getUsername() .. "'s account. New balance: " .. player:getModData().moneyBalance)
end

-- Function to deduct money from player's account
function BetterMoneySystem.deductBalance(player, amount)
    local currentBalance = BetterMoneySystem.getBalance(player)
    if currentBalance >= amount then
        player:getModData().moneyBalance = currentBalance - amount
        print("Deducted " .. tostring(amount) .. " from " .. player:getUsername() .. "'s account. New balance: " .. player:getModData().moneyBalance)
        return true
    else
        print(player:getUsername() .. " does not have enough balance to complete the transaction.")
        return false
    end
end

-- Hook into pz-shops-and-traders transaction events
local ShopsAndTraders = {}

-- Function to handle buying items
function ShopsAndTraders.onBuyItem(player, item, price)
    if not player or not player:getInventory() then
        print("Error: Player or player inventory is nil.")
        return
    end
    if not item or not item.getDisplayName then
        print("Error: Invalid item provided.")
        return
    end

    if BetterMoneySystem.deductBalance(player, price) then
        -- Grant the item to the player
        player:getInventory():AddItem(item)
        print(player:getUsername() .. " successfully purchased " .. item:getDisplayName() .. " for " .. tostring(price) .. " currency.")
    else
        -- Notify the player of insufficient funds
        player:Say("I don't have enough money for this!")
    end
end

-- Function to handle selling items
function ShopsAndTraders.onSellItem(player, item, price)
    if not player or not player:getInventory() then
        print("Error: Player or player inventory is nil.")
        return
    end
    if not item or not item.getDisplayName then
        print("Error: Invalid item provided.")
        return
    end

    -- Remove the item from the player's inventory
    if player:getInventory():contains(item) then
        player:getInventory():Remove(item)
        -- Add money to the player's account
        BetterMoneySystem.addBalance(player, price)
        print(player:getUsername() .. " successfully sold " .. item:getDisplayName() .. " for " .. tostring(price) .. " currency.")
    else
        -- Notify the player if the item is missing
        player:Say("I can't sell what I don't have!")
    end
end

-- Event registration
if not Events.OnPlayerBuyItem or not Events.OnPlayerSellItem then
    print("Error: Required events are not available.")
    return
end

Events.OnPlayerBuyItem.Add(ShopsAndTraders.onBuyItem) -- Triggered when a player buys an item
Events.OnPlayerSellItem.Add(ShopsAndTraders.onSellItem) -- Triggered when a player sells an item

-- Debugging helper
print("pz-shops-and-traders - BetterMoneySystem integration script loaded successfully.")

-- "If this script breaks, just blame it on the zombies stealing the money. 🧟‍♂️💰"