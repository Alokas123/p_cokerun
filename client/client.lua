lib.locale() -- Initialize locale system

local ConfigClient = require 'config/cl_config'
local hasStarted = false
local TookPackets = 0
local pickupZone = nil

local function RemovePickupZone()
    if pickupZone then
        exports.ox_target:removeZone(pickupZone)
        pickupZone = nil
        hasStarted = false
    end
end

local function Pickup()
    if hasStarted then
        TookPackets = 0
        lib.callback('pickupcoords', false, function(coords, packetItem)
            pickupZone = exports.ox_target:addBoxZone({
                coords = coords,
                size = vec3(1.5, 1.5, 1.5),
                rotation = 90,
                debug = ConfigClient.Debug,
                options = { {
                    name = 'pickup_package',
                    icon = 'fa-solid fa-cube',
                    label = locale("pickup_package"),
                    distance = 2,
                    onSelect = function()
                        local packets = exports.ox_inventory:Search('count', packetItem)
                        if packets < 1 and TookPackets < 5 then
                            if lib.progressBar({ duration = 2000, label = locale("picking_up_packet"), disable = { car = true, move = true, combat = true, mouse = false}}) then
                                lib.callback('givepacket', false, function(success)
                                    if success then
                                        TookPackets = TookPackets + 1
                                        lib.notify({ description = locale("packet_received", 5 - TookPackets), type = 'success' })
                                        if TookPackets >= 5 then
                                            RemovePickupZone()
                                            lib.notify({ description = locale("all_packets_received"), type = 'success' })
                                        end
                                    end
                                end)
                            end 
                        else
                            lib.notify({ title = 'Error', description = locale("pickup_warning"), type = 'error' })
                        end
                    end
                }}
            })
        end)
    end
end

CreateThread(function()
    local model = GetHashKey(ConfigClient.Model)
    lib.requestModel(model)

    lib.callback('location', false, function(coords, heading)
        if not HasModelLoaded(model) then return end
        
        local ped = CreatePed(1, model, coords.x, coords.y, coords.z, heading, false, false, 0)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)

        exports.ox_target:addBoxZone({
            coords = vec3(coords.x, coords.y, coords.z + 1),
            size = vec3(1.5, 1.5, 1.5),
            rotation = 90,
            debug = ConfigClient.Debug,
            options = { {
                name = 'start_mission',
                icon = 'fa-solid fa-cube',
                label = locale("start_mission"),
                distance = 2,
                onSelect = function()
                    local phonenumber = exports.npwd:getPhoneNumber()
                    if hasStarted then
                        lib.notify({ type = 'info', description = locale("already_havemission") })
                    else
                        -- Fetch mission cost
                        lib.callback('getMissionCost', false, function(cost)
                            local question = lib.alertDialog({
                                header = locale("hello"),
                                content = string.format(locale("mission_start_alert"), cost),
                                centered = true,
                                cancel = true
                            })
                            
                            if question == "confirm" then
                                lib.callback('Missionstart', false, function(success, reason)
                                    if success then
                                        hasStarted = true
                                        Pickup()
                                        lib.notify({ type = 'info', description = locale("mission_start_message") })
                                    else
                                        if reason == "cooldown" then
                                            lib.notify({ type = 'error', description = locale("cooldown_wait") })
                                        elseif reason == "money" then
                                            lib.notify({ type = 'error', description = locale("not_enough_money") })
                                        else
                                            lib.notify({ type = 'error', description = locale("unknown_error") })
                                        end
                                    end
                                end, phonenumber)
                            else
                                lib.notify({ type = 'info', description = locale("didintwanttostart") })
                            end
                        end)
                    end
                end
            }}
        })
    end)

    SetModelAsNoLongerNeeded(model)
end)
