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
]]--

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
blub blub blub blub 
    Starts at 1 player and if there isnt one with that many it goes up and retrys 
]]--

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

function Misc.DeleteTextures()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    return true
end

function Misc.LowGraphics()
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = 1
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    return true
end

function Misc.AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    local Players = game:GetService("Players")
    local connection
    connection = Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    return connection
end

function Misc.FindPlayer(partial)
    local players = game:GetService("Players"):GetPlayers()
    for i, player in pairs(players) do
        if player.Name:lower():sub(1, #partial) == partial:lower() then
            return player
        end
    end
    return nil
end

-- Popular Scripts
function Misc.LoadDex()
    local dexScript = [[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDex.lua"))()
    ]]
    return loadstring(dexScript)()
end

function Misc.LoadInfiniteYield()
    local iyScript = [[
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    ]]
    return loadstring(iyScript)()
end

-- Environment Functions
function Misc.CheckExecutor()
    local supported = {}
    
    supported.Synapse = syn and not KRNL_LOADED
    supported.KRNL = KRNL_LOADED
    supported.ScriptWare = getgenv().IS_SCRIPTWARE
    supported.Fluxus = getgenv().IS_FLUXUS
    
    return supported
end

function Misc.IsSecure()
    return (getgenv().secure_loaded or syn or KRNL_LOADED) and true or false
end

-- Performance & Graphics
function Misc.UnlockFPS()
    local success, error = pcall(function()
        setfpscap(999)
    end)
    return success
end

function Misc.RemoveEffects()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v:Destroy()
        end
    end
    return true
end

function Misc.DisableParticles()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    return true
end

-- Character Utilities
function Misc.Noclip(enabled)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    if enabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Misc.InvisibleCharacter()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local savePos = character.HumanoidRootPart.CFrame
    
    -- Load invisible character
    local invisibleCharacter = game:GetObjects("rbxassetid://4819740796")[1]
    invisibleCharacter.Parent = workspace
    
    -- Set position
    local invisibleHRP = invisibleCharacter.HumanoidRootPart
    invisibleHRP.CFrame = savePos
    
    -- Remove old character
    character:Destroy()
    
    -- Set new character
    invisibleCharacter.Parent = workspace
    player.Character = invisibleCharacter
    
    return true
end

-- Game Utilities
function Misc.Screenshot()
    if syn and syn.screenshot then
        return syn.screenshot()
    elseif KRNL_LOADED then
        return screenshot()
    end
    return false
end

function Misc.CopyGameInfo()
    local placeId = game.PlaceId
    local jobId = game.JobId
    local info = string.format("Place ID: %d\nJob ID: %s", placeId, jobId)
    setclipboard(info)
    return true
end

-- Network Stats
function Misc.GetPing()
    local stats = game:GetService("Stats")
    return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end

function Misc.GetFPS()
    return math.floor(1/game:GetService("RunService").RenderStepped:Wait())
end

return Misc