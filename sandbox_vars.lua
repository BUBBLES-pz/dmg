-- File: sandbox_vars.lua
-- Description: Defines custom sandbox variables for the mod.

if not SandboxVars then SandboxVars = {} end

-- Define the CustomVars table if it doesn't exist
SandboxVars.CustomVars = SandboxVars.CustomVars or {}

-- Example variables for the mod (customize these as needed)
SandboxVars.CustomVars.LocalMoneyName = SandboxVars.CustomVars.LocalMoneyName or "BMSATM.Money"
SandboxVars.CustomVars.LocalMoneyDisplayName = SandboxVars.CustomVars.LocalMoneyDisplayName or "Local Money"
SandboxVars.CustomVars.LocalMoneyDescription = SandboxVars.CustomVars.LocalMoneyDescription or "A local currency used exclusively in specific shops."
SandboxVars.CustomVars.EnableCustomWallet = SandboxVars.CustomVars.EnableCustomWallet or false
SandboxVars.CustomVars.BalanceLimit = SandboxVars.CustomVars.BalanceLimit or 10000
SandboxVars.CustomVars.WalletName = SandboxVars.CustomVars.WalletName or "Base.Wallet"

-- Add additional variables as needed
-- Example:
-- SandboxVars.CustomVars.ExampleVariable = SandboxVars.CustomVars.ExampleVariable or "DefaultValue"

-- Debugging helper: Print all custom sandbox vars when the game boots
Events.OnGameBoot.Add(function()
    print("Custom Sandbox Variables:")
    for k, v in pairs(SandboxVars.CustomVars) do
        print(k .. " = " .. tostring(v))
    end
end)