-- This script is designed to override any existing code for handling client commands in the "shop" module.
-- Ensure it is loaded last in the runtime sequence to take priority over similar scripts.

-- Event Registration
Events.OnClientCommand.Add(onClientCommand)

local itemDictionaryUpdated = false ---NEEDED FOR BETTER SORTING TO WORK IN MP
local _internal = require "shop-shared"

local function onClientCommand(_module, _command, _player, _data)
    if _module ~= "shop" then return end
    _data = _data or {}

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

    if _command == "grabShop" then
        local storeObj = STORE_HANDLER.getStoreByID(_data.storeID)
        if storeObj then
            if isServer() then
                sendServerCommand(_player, "shop", "grabShop", { store = storeObj })
            else
                CLIENT_STORES[_data.storeID] = storeObj
            end
        end
    end

    if _command == "ImportStores" then
        if isServer() then
            if _data.stores then _internal.copyAgainst(GLOBAL_STORES, _data.stores) end
            sendServerCommand(_player, "shop", "incomingImport", { stores = GLOBAL_STORES })
        else
            if _data.stores then
                _internal.copyAgainst(CLIENT_STORES, _data.stores)
                _internal.copyAgainst(GLOBAL_STORES, _data.stores)
            end
        end
    end

    if _command == "getOrSetWallet" then
        local playerID, steamID, playerUsername = _data.playerID, _data.steamID, _data.playerUsername
        WALLET_HANDLER.getOrSetPlayerWallet(playerID, steamID, playerUsername, _player)
    end

    if _command == "scrubWallet" then
        local playerID = _data.playerID
        WALLET_HANDLER.scrubWallet(playerID)
    end

    -- Transfer Funds Command (with BMSATM.Money handling)
    if _command == "transferFunds" then
        local playerWalletID, amount, toStoreID, forceCash, bmsMoney = _data.playerWalletID, _data.amount, _data.toStoreID, _data.forceCash, _data.bmsMoney

        if toStoreID then
            local storeObj = STORE_HANDLER.getStoreByID(toStoreID)
            if storeObj then
                local newValue = math.max(0, (storeObj.cash or 0) - amount)
                storeObj.cash = _internal.floorCurrency(newValue)
                STORE_HANDLER.updateStore(storeObj, toStoreID)
            end
        end

        local playerWallet
        if playerWalletID then playerWallet = WALLET_HANDLER.getOrSetPlayerWallet(playerWalletID) end
        if playerWallet and amount then
            WALLET_HANDLER.validateMoneyOrWallet(playerWallet, _player, amount)
            if forceCash then
                WALLET_HANDLER.validateMoneyOrWallet(playerWallet, _player, 0 - amount, true)
            end
        end

        -- Deduct BMSATM.Money from Base.Wallet
        if bmsMoney and bmsMoney > 0 then
            local baseWallet = WALLET_HANDLER.getOrSetPlayerWallet("Base.Wallet")
            if baseWallet and baseWallet.balance >= bmsMoney then
                baseWallet.balance = baseWallet.balance - bmsMoney
                print("Deducted BMSATM.Money (" .. tostring(bmsMoney) .. ") from Base.Wallet.")
            else
                print("ERROR: Insufficient BMSATM.Money in Base.Wallet.")
            end
        end
    end

    -- Exchange Funds Command (with BMSATM.Money handling)
    if _command == "exchangeFunds" then
        local playerA, playerObjA = { offer = _data.offerA }, _data.playerA
        local playerB, playerObjB = { offer = _data.offerB }, _data.playerB

        if playerA then playerA.walletID = playerObjA and playerObjA:getModData().wallet_UUID end
        if playerB then playerB.walletID = playerObjB and playerObjB:getModData().wallet_UUID end

        local walletA, walletB

        if playerA and playerA.walletID then walletA = WALLET_HANDLER.getOrSetPlayerWallet(playerA.walletID) end
        if playerB and playerB.walletID then walletB = WALLET_HANDLER.getOrSetPlayerWallet(playerB.walletID) end

        if walletA then
            if playerA.offer then WALLET_HANDLER.validateMoneyOrWallet(walletA, playerObjA, 0 - playerA.offer) end
            if playerB.offer then WALLET_HANDLER.validateMoneyOrWallet(walletA, playerObjA, playerB.offer) end
        else
            print("ERR: walletA not found for exchange.")
        end

        if walletB then
            if playerA.offer then WALLET_HANDLER.validateMoneyOrWallet(walletB, playerObjB, playerA.offer) end
            if playerB.offer then WALLET_HANDLER.validateMoneyOrWallet(walletB, playerObjB, 0 - playerB.offer) end
        else
            print("ERR: walletB not found for exchange.")
        end

        -- Handle BMSATM.Money exchanges
        if _data.bmsMoneyA and _data.bmsMoneyB then
            local baseWallet = WALLET_HANDLER.getOrSetPlayerWallet("Base.Wallet")
            if baseWallet and baseWallet.balance >= _data.bmsMoneyA then
                baseWallet.balance = baseWallet.balance - _data.bmsMoneyA
                print("Exchanged BMSATM.Money: " .. tostring(_data.bmsMoneyA))
            else
                print("ERROR: Insufficient BMSATM.Money in Base.Wallet for exchange.")
            end
        end
    end

    -- Process Order Command (with BMSATM.Money handling)
    if _command == "processOrder" then
        local storeID, buying, selling, playerID, money, bmsMoney = _data.storeID, _data.buying, _data.selling, _data.playerID, _data.money, _data.bmsMoney
        STORE_HANDLER.validateOrder(_player, playerID, storeID, buying, selling, money)

        -- Handle BMSATM.Money in orders
        if bmsMoney and bmsMoney > 0 then
            local baseWallet = WALLET_HANDLER.getOrSetPlayerWallet("Base.Wallet")
            if baseWallet and baseWallet.balance >= bmsMoney then
                baseWallet.balance = baseWallet.balance - bmsMoney
                print("Processed order with BMSATM.Money: " .. tostring(bmsMoney))
            else
                print("ERROR: Insufficient BMSATM.Money in Base.Wallet for order.")
            end
        end
    end

    -- Other commands remain unchanged...
end