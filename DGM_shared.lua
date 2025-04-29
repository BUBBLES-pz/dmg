-- Shared functions and utilities

-- Function to safely floor currency amounts
local _internal = {}

function _internal.floorCurrency(amount)
    return math.floor(amount * 100) / 100
end

function _internal.copyAgainst(target, source)
    if not target or not source then return end
    for k, v in pairs(source) do
        target[k] = v
    end
end

return _internal