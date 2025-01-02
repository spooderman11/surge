local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Obfuscated configuration
local config = {
    _a = true, -- Enabled
    _b = math.random(95, 120), -- FOV
    _c = math.random(85, 95), -- HitChance
    _d = "Head" -- TargetPart
}

-- Memory safety
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index
local protected = {}

-- Randomization helpers
local function addNoise(vector, amount)
    return vector + Vector3.new(
        math.random(-amount, amount),
        math.random(-amount, amount),
        math.random(-amount, amount)
    )
end

local function getRandomPart(character)
    local parts = {config._d, "UpperTorso", "LowerTorso"}
    return character:FindFirstChild(parts[math.random(1, #parts)])
end

local function getClosestPlayer()
    local closest, dist = nil, config._b
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not protected[p] then
            local part = p.Character:FindFirstChild(config._d)
            if part then
                local pos = Camera:WorldToScreenPoint(part.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if mag < dist then
                    closest, dist = p, mag
                end
            end
        end
    end
    
    return closest
end

local function isTargetValid(target)
    if not target or not target.Character then return false end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local part = getRandomPart(target.Character)
    local direction = addNoise((part.Position - Camera.CFrame.Position).Unit, 0.001)
    local dist = math.random(950, 1050)
    
    return workspace:Raycast(Camera.CFrame.Position, direction * dist, params) ~= nil
end

-- Hook with anti-detection measures
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FindPartOnRayWithIgnoreList" and config._a then
        local target = getClosestPlayer()
        
        if target and isTargetValid(target) and math.random(1, 100) <= config._c then
            local part = getRandomPart(target.Character)
            local noise = math.random() < 0.3 and 0.015 or 0.001
            local direction = addNoise((part.Position - Camera.CFrame.Position).Unit, noise)
            args[1] = Ray.new(Camera.CFrame.Position, direction * math.random(950, 1050))
        end
    end
    
    return oldNameCall(self, unpack(args))
end))

mt.__index = newcclosure(function(t, k)
    if protected[t] then return nil end
    return oldIndex(t, k)
end)

return setmetatable({}, {
    __index = function() return config._a end,
    __newindex = function() return nil end
})