lib.locale() -- Initialize locale system
local ConfigServer = require 'config/sv_config'
local lastPickupCoord = nil
local hasStarted = false
local cooldownEndTime = 0

local function isCooldownActive()
    return os.time() < cooldownEndTime
end


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

    if isCooldownActive() then
        return false, "cooldown"
    end

    if money >= ConfigServer.MissionCost then
        hasStarted = true
        cooldownEndTime = os.time() + (ConfigServer.CoolDown * 60) 

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
