ConfigServer = {}

ConfigServer.StartLocation = {
    coords = vec3(-741.6971, -982.3508, 16.4376),
    heading = 16.5588
}

ConfigServer.PickupLocations = {
    coords = {
        vec3(902.8273, -615.6377, 58.4533),
        vec3(1250.9819, -621.0458, 69.5721),
        vec3(206.3862, -86.0212, 69.3822),
        vec3(340.9753, -214.9338, 54.2218),
        vec3(313.2799, -198.0992, 54.2218),
        vec3(906.1393, -489.4741, 59.4363)
    },
    messages = {
        "Come here. Keep eye on cops",
        "l have somthing for you. Keep eye on cops",
        "l have packet for you. Keep eye on cops",
    }
}

ConfigServer.PacketItem = "coke_brick"
ConfigServer.CoolDown = 5 
ConfigServer.MaxPackets = 5
ConfigServer.MissionCost = 13000 

return ConfigServer
