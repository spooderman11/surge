local Misc = {}

--[[
    [DOCS FOR SERVERHOP]:
    <function> Misc.Serverhop()
    usage example:
    Misc.Serverhop()
]]--

function Misc.Serverhop()
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    
    local API_URL = "https://games.roblox.com/v1/games/"
    local PLACE_ID = game.PlaceId
    local MAX_SERVERS = 10
    
    local function FetchServers(cursor)
        local url = string.format(
            "%s%s/servers/Public?sortOrder=Asc&limit=%d%s",
            API_URL,
            PLACE_ID,
            MAX_SERVERS,
            cursor and "&cursor="..cursor or ""
        )
        
        local success, result = pcall(function()
            local response = game:HttpGet(url)
            return HttpService:JSONDecode(response)
        end)
        
        if not success then
            warn("Failed to fetch servers:", result)
            return nil
        end
        
        return result
    end
    
    local function TeleportToRandomServer()
        local servers = FetchServers()
        if not servers or #servers.data == 0 then
            warn("No available servers found")
            return false
        end
        
        local randomServer = servers.data[math.random(1, #servers.data)]
        
        local success, error = pcall(function()
            TeleportService:TeleportToPlaceInstance(
                PLACE_ID,
                randomServer.id,
                Players.LocalPlayer
            )
        end)
        
        if not success then
            warn("Teleport failed:", error)
            return false
        end
        
        return true
    end
    
    return TeleportToRandomServer()
end

--[[
    [DOCS FOR REJOIN]:
    <function> Misc.Rejoin()
    usage example:
    Misc.Rejoin()
]]--

function Misc.Rejoin()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlaceId = game.PlaceId
    local success, error = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)
    if not success then
        warn("Rejoin failed:", error)
        return false
    end
    return true
end

--[[
    [DOCS FOR JOIN HIGHEST SERVER]:
    <function> Misc.JoinHighestServer()
    usage example:
    Misc.JoinHighestServer()

    Starts at 35 players and if there isnt one with that many it goes down and retrys
]]

function Misc.JoinHighestServer()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlaceId = game.PlaceId
    local success, error = pcall(function()
        for i = 35, 1, -1 do
            local servers = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local servers = game:GetService("HttpService"):JSONDecode(servers)
            for i,v in pairs(servers.data) do
                if v.playing == i then
                    TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                end
            end
        end
    end)
    if not success then
        warn("Joining highest server failed:", error)
        return false
    end
    return true
end

--[[
    [DOCS FOR JOIN LOWEST SERVER]:
    <function> Misc.JoinLowestServer()
    usage example:
    Misc.JoinLowestServer()

    Starts at 1 player and if there isnt one with that many it goes up and retrys
]]

function Misc.JoinLowestServer()
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlaceId = game.PlaceId
    local success, error = pcall(function()
        for i = 1, 35 do
            local servers = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local servers = game:GetService("HttpService"):JSONDecode(servers)
            for i,v in pairs(servers.data) do
                if v.playing == i then
                    TeleportService:TeleportToPlaceInstance(PlaceId, v.id, LocalPlayer)
                end
            end
        end
    end)
    if not success then
        warn("Joining lowest server failed:", error)
        return false
    end
    return true
end

return Misc