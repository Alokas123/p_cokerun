lib.locale() -- Initialize locale system

local ConfigServer = require 'config/sv_config'
local lastPickupCoord = nil
local hasStarted = false
local cooldownActive = false
local cooldownRemaining = 0

-- Cooldown Timer (Runs every minute)
CreateThread(function()
    while true do
        Wait(60000) -- 1 minute
        if cooldownRemaining > 0 then
            cooldownRemaining = cooldownRemaining - 1
            if cooldownRemaining <= 0 then
                cooldownActive = false
            end
        end
    end
end)

lib.callback.register('location', function()
    return ConfigServer.StartLocation.coords, ConfigServer.StartLocation.heading
end)

lib.callback.register('givepacket', function(source)
    if hasStarted then
        exports.ox_inventory:AddItem(source, ConfigServer.PacketItem, 1)
        return true
    end
    return false
end)

lib.callback.register('Missionstart', function(source, phonenumber)
    local money = exports.ox_inventory:GetItemCount(source, "money")

    if cooldownActive then
        return false, "cooldown"
    end

    if money >= ConfigServer.MissionCost then
        hasStarted = true
        cooldownActive = true
        cooldownRemaining = ConfigServer.CooldownTime

        lastPickupCoord = ConfigServer.PickupLocations.coords[math.random(1, #ConfigServer.PickupLocations.coords)]
        local message = ConfigServer.PickupLocations.messages[math.random(1, #ConfigServer.PickupLocations.messages)]
        local sender = exports.npwd:generatePhoneNumber()

        exports.npwd:emitMessage({
            senderNumber = sender,
            targetNumber = phonenumber,
            message = message,
            embed = {
                type = "location",
                coords = { lastPickupCoord.x, lastPickupCoord.y, lastPickupCoord.z },
                phoneNumber = sender
            }
        })
        exports.ox_inventory:RemoveItem(source, "money", ConfigServer.MissionCost)
        return true
    else
        return false, "money"
    end
end)

lib.callback.register('pickupcoords', function()
    return lastPickupCoord, ConfigServer.PacketItem
end)

lib.callback.register('getMissionCost', function()
    return ConfigServer.MissionCost
end)
