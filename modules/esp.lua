-- Remove the loadstring require and use direct loading
local Utils = {
    CalculateBox = function(character)
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        
        local size = character:GetExtentsSize()
        local position = hrp.Position
        
        local topRight = game.Workspace.CurrentCamera:WorldToViewportPoint(position + Vector3.new(size.X/2, size.Y/2, 0))
        local bottomLeft = game.Workspace.CurrentCamera:WorldToViewportPoint(position - Vector3.new(size.X/2, size.Y/2, 0))
        
        return {
            TopRight = Vector2.new(topRight.X, topRight.Y),
            BottomLeft = Vector2.new(bottomLeft.X, bottomLeft.Y)
        }
    end
}

local FontStyles = {
    ["Default"] = 0,    -- Legacy/Default font
    ["UI"] = 1,         -- Roblox UI font
    ["System"] = 2,     -- System font
    ["Monospace"] = 3,  -- Monospace/Code font
    ["Bold"] = 4        -- Bold version
}

local function CalculateStaticBox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local size = Vector2.new(4, 6) -- Static size in studs
    local pos = hrp.Position
    
    local headPos = game.Workspace.CurrentCamera:WorldToViewportPoint(pos + Vector3.new(0, size.Y/2, 0))
    local feetPos = game.Workspace.CurrentCamera:WorldToViewportPoint(pos - Vector3.new(0, size.Y/2, 0))
    
    local height = math.abs(headPos.Y - feetPos.Y)
    local width = height * 0.6 -- Maintain aspect ratio
    
    return {
        TopRight = Vector2.new(headPos.X + width/2, headPos.Y),
        BottomLeft = Vector2.new(headPos.X - width/2, feetPos.Y)
    }
end

local ESPObjects = {}
local FOVCircle

-- Add new customization options
local ESPSettings = {
    BoxThickness = 1,
    BoxTransparency = 1,
    TracerThickness = 1,
    TracerTransparency = 1,
    TextSize = 13,
    TextOutline = true,
    HealthBarThickness = 2,
    HealthBarOffset = 6,
    ChamsEnabled = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5,
    ChamsFillColor = Color3.fromRGB(255, 0, 0),
    ChamsFillTransparency = 0.8
}

-- Remove old ChamsFolder creation and replace with this:
local ChamsFolder = (function()
    local folder = Instance.new("Folder")
    folder.Name = "ChamsFolder"
    folder.Parent = game:GetService("CoreGui")
    return folder
end)()

local function CreateChams(player)
    if not player or not player.Character then return nil end
    
    -- Remove any existing chams
    local existingHighlight = ChamsFolder:FindFirstChild(player.Name .. "_Chams")
    if existingHighlight then
        existingHighlight:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = player.Name .. "_Chams"
    highlight.FillColor = ESPSettings.ChamsFillColor
    highlight.FillTransparency = ESPSettings.ChamsFillTransparency
    highlight.OutlineColor = ESPSettings.ChamsColor
    highlight.OutlineTransparency = ESPSettings.ChamsTransparency
    highlight.Adornee = player.Character
    highlight.Parent = ChamsFolder
    
    return highlight
end

local function CreateESP(player)
    local esp = Drawing.new("Text")
    esp.Visible = false
    esp.Center = true
    esp.Outline = true
    esp.Font = 2 -- Default font
    esp.Size = ESPSettings.TextSize
    esp.Color = Color3.new(1, 1, 1)
    return esp
end

local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 1, 1)
    box.Thickness = ESPSettings.BoxThickness
    box.Transparency = ESPSettings.BoxTransparency
    box.Filled = false
    return box
end

local function CreateLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(1, 1, 1)
    line.Thickness = ESPSettings.TracerThickness
    line.Transparency = ESPSettings.TracerTransparency
    return line
end

local function InitESP(player)
    ESPObjects[player] = {
        name = CreateESP(player),
        box = CreateBox(),
        tracer = CreateLine(),
        distance = CreateESP(player),
        healthBar = CreateBox(),
        healthBarOutline = CreateBox(),
        chams = CreateChams(player)
    }
end

local function CleanupESP(player)
    if ESPObjects[player] then
        for key, object in pairs(ESPObjects[player]) do
            pcall(function()
                if key == "chams" then
                    if object and object.Parent then
                        object:Destroy()
                    end
                elseif type(object) == "table" then
                    for _, subObject in pairs(object) do
                        if subObject and subObject.Remove then
                            subObject:Remove()
                        end
                    end
                else
                    if object and object.Remove then
                        object:Remove()
                    end
                end
            end)
        end
        ESPObjects[player] = nil
    end
end

local function CleanupAllESP()
    for player, _ in pairs(ESPObjects) do
        pcall(function()
            CleanupESP(player)
        end)
    end
end

local function UpdateESP(Options)
    -- Early return if no options
    if not Options then return end

    -- Update ESP objects based on settings first
    for _, objects in pairs(ESPObjects) do
        -- Update box properties
        if objects.box then
            objects.box.Thickness = ESPSettings.BoxThickness
            objects.box.Transparency = ESPSettings.BoxTransparency
        end
        -- Update tracer properties
        if objects.tracer then
            objects.tracer.Thickness = ESPSettings.TracerThickness
            objects.tracer.Transparency = ESPSettings.TracerTransparency
        end
        -- Update text properties
        if objects.name then
            objects.name.Size = Options.FontSize.Value
            objects.name.Outline = ESPSettings.TextOutline
        end
        if objects.distance then
            objects.distance.Size = Options.FontSize.Value
            objects.distance.Outline = ESPSettings.TextOutline
        end
    end

    -- If ESP is disabled, hide all objects
    if not Options.ESPEnabled.Value then
        for _, objects in pairs(ESPObjects) do
            for key, object in pairs(objects) do
                if type(object) ~= "table" then
                    object.Visible = false
                end
            end
        end
        return
    end

    -- Update Chams settings
    if Options.ChamsEnabled then
        ESPSettings.ChamsEnabled = Options.ChamsEnabled.Value
    end
    if Options.ChamsColor then
        ESPSettings.ChamsColor = Options.ChamsColor.Value
    end
    if Options.ChamsTransparency then
        ESPSettings.ChamsTransparency = Options.ChamsTransparency.Value
    end
    if Options.ChamsFillColor then
        ESPSettings.ChamsFillColor = Options.ChamsFillColor.Value
    end
    if Options.ChamsFillTransparency then
        ESPSettings.ChamsFillTransparency = Options.ChamsFillTransparency.Value
    end

    -- Main ESP update loop
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player == game:GetService("Players").LocalPlayer then continue end

        -- Initialize ESP objects if they don't exist
        if not ESPObjects[player] then
            InitESP(player)
        end

        local character = player.Character
        if not character then 
            -- Hide ESP if character doesn't exist
            if ESPObjects[player] then
                for _, object in pairs(ESPObjects[player]) do
                    if type(object) ~= "table" then
                        object.Visible = false
                    end
                end
            end
            continue 
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then continue end

        local vector, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
        local distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

        -- Hide ESP if player is too far or offscreen
        if not onScreen or distance > Options.ESPDistance.Value then
            for _, object in pairs(ESPObjects[player]) do
                if type(object) ~= "table" then
                    object.Visible = false
                end
            end
            continue
        end

        local espColor = Options.ESPColor.Value

        -- Box ESP
        if Options.BoxESP.Value and Options.ESPType.Value == "Box" then
            local box = ESPObjects[player].box
            local boxCoordinates = Options.StaticESP.Value and CalculateStaticBox(character) or Utils.CalculateBox(character)
            
            if boxCoordinates then
                box.Size = boxCoordinates.TopRight - boxCoordinates.BottomLeft
                box.Position = boxCoordinates.BottomLeft
                box.Color = espColor
                box.Visible = true
            end
        else
            ESPObjects[player].box.Visible = false
        end

        -- Name ESP
        if Options.NameESP.Value then
            local nameEsp = ESPObjects[player].name
            nameEsp.Text = player.Name
            nameEsp.Position = Vector2.new(vector.X, vector.Y - 40)
            nameEsp.Color = espColor
            nameEsp.Visible = true
        else
            ESPObjects[player].name.Visible = false
        end

        -- Distance ESP
        if Options.DistanceESP.Value then
            local distanceEsp = ESPObjects[player].distance
            distanceEsp.Text = math.floor(distance) .. " studs"
            distanceEsp.Position = Vector2.new(vector.X, vector.Y + 20)
            distanceEsp.Color = espColor
            distanceEsp.Visible = true
        else
            ESPObjects[player].distance.Visible = false
        end

        -- Tracers
        if Options.TracerESP.Value then
            local tracer = ESPObjects[player].tracer
            local startPos = Vector2.new()
            
            if Options.TracerPosition.Value == "Mouse" then
                startPos = game:GetService("UserInputService"):GetMouseLocation()
            else
                local viewportSize = game.Workspace.CurrentCamera.ViewportSize
                if Options.TracerPosition.Value == "Top" then
                    startPos = Vector2.new(viewportSize.X/2, 0)
                elseif Options.TracerPosition.Value == "Middle" then
                    startPos = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
                else -- Bottom
                    startPos = Vector2.new(viewportSize.X/2, viewportSize.Y)
                end
            end
            
            tracer.From = startPos
            tracer.To = Vector2.new(vector.X, vector.Y)
            tracer.Color = espColor
            tracer.Visible = true
        else
            ESPObjects[player].tracer.Visible = false
        end

        -- Health Bar
        if Options.HealthBarESP.Value then
            local healthBar = ESPObjects[player].healthBar
            local healthBarOutline = ESPObjects[player].healthBarOutline
            local boxCoordinates = Utils.CalculateBox(character)
            
            if boxCoordinates then
                local health = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barHeight = boxCoordinates.TopRight.Y - boxCoordinates.BottomLeft.Y

                healthBarOutline.Size = Vector2.new(4, barHeight)
                healthBarOutline.Position = Vector2.new(boxCoordinates.BottomLeft.X - 6, boxCoordinates.BottomLeft.Y)
                healthBarOutline.Visible = true
                healthBarOutline.Color = Color3.new(0, 0, 0)

                healthBar.Size = Vector2.new(2, barHeight * health)
                healthBar.Position = Vector2.new(boxCoordinates.BottomLeft.X - 5, boxCoordinates.BottomLeft.Y + (barHeight * (1 - health)))
                healthBar.Visible = true
                healthBar.Color = Color3.fromHSV(health * 0.3, 1, 1)
            end
        else
            ESPObjects[player].healthBar.Visible = false
            ESPObjects[player].healthBarOutline.Visible = false
        end

        -- Chams update section
        if Options.ChamsEnabled and Options.ChamsEnabled.Value then
            if not ESPObjects[player].chams or not ESPObjects[player].chams.Parent then
                ESPObjects[player].chams = CreateChams(player)
            end
            
            if ESPObjects[player].chams then
                ESPObjects[player].chams.FillColor = Options.ChamsFillColor.Value
                ESPObjects[player].chams.FillTransparency = Options.ChamsFillTransparency.Value
                ESPObjects[player].chams.OutlineColor = Options.ChamsColor.Value
                ESPObjects[player].chams.OutlineTransparency = Options.ChamsTransparency.Value
                ESPObjects[player].chams.Adornee = player.Character
            end
        else
            if ESPObjects[player] and ESPObjects[player].chams then
                ESPObjects[player].chams:Destroy()
                ESPObjects[player].chams = nil
            end
        end
    end
end

-- Add cleanup function for ChamsFolder
game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "ChamsFolder" then
        ChamsFolder:Destroy()
        ChamsFolder = Instance.new("Folder")
        ChamsFolder.Name = "ChamsFolder"
        ChamsFolder.Parent = game:GetService("CoreGui")
    end
end)

local function CreateFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 1
    FOVCircle.NumSides = 100
    FOVCircle.Radius = 100
    FOVCircle.Filled = false
end

local function RemoveFOVCircle()
    pcall(function()
        if FOVCircle then
            FOVCircle:Remove()
            FOVCircle = nil
        end
    end)
end

game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    ChamsFolder:Destroy()
end)

return {
    InitESP = InitESP,
    CleanupESP = CleanupESP,
    CleanupAllESP = CleanupAllESP,  -- Add new function
    UpdateESP = UpdateESP,
    CreateFOVCircle = CreateFOVCircle,
    RemoveFOVCircle = RemoveFOVCircle,
    Settings = ESPSettings
}
