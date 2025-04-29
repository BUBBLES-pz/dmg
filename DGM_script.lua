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

-- Use sandbox variable for custom balance limit
local balanceLimit = 10000 -- Default value

if SandboxVars and SandboxVars.CustomVars and SandboxVars.CustomVars.BalanceLimit then
    balanceLimit = SandboxVars.CustomVars.BalanceLimit
else
    print("Warning: SandboxVars.CustomVars or BalanceLimit is not defined. Using default balance limit: " .. balanceLimit)
end

-- Function to add money to player's account
function BetterMoneySystem.addBalance(player, amount)
    local currentBalance = BetterMoneySystem.getBalance(player)
    if currentBalance + amount > balanceLimit then
        print("Cannot add money. Balance limit reached: " .. balanceLimit)
        return
    end
    player:getModData().moneyBalance = currentBalance + amount
    print("Added " .. tostring(amount) .. " to " .. player:getUsername() .. "'s account. New balance: " .. player:getModData().moneyBalance)
end

-- Other functions remain unchanged...