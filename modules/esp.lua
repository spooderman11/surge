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
    ["Default"] = 2,      -- SourceSans (Default Roblox font)
    ["Monospace"] = 3,    -- Code/Monospace font
    ["Cartoony"] = 1,     -- Comic-style font
    ["Modern"] = 0,       -- Thinner, cleaner font
    ["Bold"] = 4          -- Heavy/Bold font
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

local function CreateESP(player)
    local esp = Drawing.new("Text")
    esp.Visible = false
    esp.Center = true
    esp.Outline = true
    esp.Font = FontStyles["Default"] -- Default font
    esp.Size = 13
    esp.Color = Color3.new(1, 1, 1)
    return esp
end

local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 1, 1)
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false
    return box
end

local function CreateLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.new(1, 1, 1)
    line.Thickness = 1
    return line
end

local function CreateCorners()
    local corners = {
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line"),
        Drawing.new("Line")
    }
    for _, corner in pairs(corners) do
        corner.Visible = false
        corner.Color = Color3.new(1, 1, 1)
        corner.Thickness = 1
    end
    return corners
end

local function InitESP(player)
    ESPObjects[player] = {
        name = CreateESP(player),
        box = CreateBox(),
        corners = CreateCorners(),
        tracer = CreateLine(),
        distance = CreateESP(player),
        healthBar = CreateBox(),
        healthBarOutline = CreateBox()
    }
end

local function CleanupESP(player)
    if ESPObjects[player] then
        for _, object in pairs(ESPObjects[player]) do
            if type(object) == "table" then
                -- Handle corners
                for _, corner in pairs(object) do
                    pcall(function()
                        if corner and corner.Remove then
                            corner:Remove()
                        end
                    end)
                end
            else
                -- Handle single objects
                pcall(function()
                    if object and object.Remove then
                        object:Remove()
                    end
                end)
            end
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
    if not Options or not Options.ESPEnabled then return end
    
    -- Hide ESP if disabled
    if not Options.ESPEnabled.Value then
        for _, objects in pairs(ESPObjects) do
            pcall(function()
                for _, object in pairs(objects) do
                    if type(object) == "table" then
                        for _, corner in pairs(object) do
                            if corner and corner.Visible ~= nil then
                                corner.Visible = false
                            end
                        end
                    elseif object and object.Visible ~= nil then
                        object.Visible = false
                    end
                end
            end)
        end
        return
    end

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game:GetService("Players").LocalPlayer then
            if not ESPObjects[player] then
                InitESP(player)
            end

            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local humanoidRootPart = character.HumanoidRootPart
                local humanoid = character.Humanoid
                local head = character:FindFirstChild("Head")
                local vector, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)

                -- Calculate distance
                local distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude

                if onScreen and distance <= Options.ESPDistance.Value then
                    local espColor = Options.ESPColor.Value

                    -- Box ESP
                    if Options.BoxESP.Value then
                        local box = ESPObjects[player].box
                        local boxCoordinates
                        
                        if Options.StaticESP.Value then
                            boxCoordinates = CalculateStaticBox(character)
                        else
                            boxCoordinates = Utils.CalculateBox(character)
                        end
                        
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
                        nameEsp.Size = Options.FontSize.Value
                        nameEsp.Font = FontStyles[Options.FontStyle.Value]
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
                        distanceEsp.Size = Options.FontSize.Value
                        distanceEsp.Font = FontStyles[Options.FontStyle.Value]
                        distanceEsp.Visible = true
                    else
                        ESPObjects[player].distance.Visible = false
                    end

                    -- Tracers
                    if Options.TracerESP.Value then
                        local tracer = ESPObjects[player].tracer
                        local startPos = Vector2.new()

                        -- Set tracer start position based on selection
                        if Options.TracerPosition.Value == "Down" then
                            startPos = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y)
                        elseif Options.TracerPosition.Value == "Middle" then
                            startPos = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 2)
                        elseif Options.TracerPosition.Value == "Up" then
                            startPos = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, 0)
                        elseif Options.TracerPosition.Value == "Mouse" then
                            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                            startPos = Vector2.new(mousePos.X, mousePos.Y)
                        end

                        tracer.From = startPos
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = espColor
                        tracer.Visible = true
                    else
                        ESPObjects[player].tracer.Visible = false
                    end

                    -- ESP Type handling
                    if Options.ESPType.Value == "Box" then
                        ESPObjects[player].box.Visible = Options.BoxESP.Value
                        -- Hide corners
                        for _, corner in pairs(ESPObjects[player].corners) do
                            corner.Visible = false
                        end
                    elseif Options.ESPType.Value == "Corner" then
                        ESPObjects[player].box.Visible = false
                        if Options.BoxESP.Value then
                            local corners = ESPObjects[player].corners
                            local boxCoordinates = Utils.CalculateBox(character)
                            if boxCoordinates then
                                local size = boxCoordinates.TopRight - boxCoordinates.BottomLeft
                                local cornerSize = math.min(size.X, size.Y) * 0.2
                                local TL = boxCoordinates.BottomLeft
                                local TR = Vector2.new(boxCoordinates.TopRight.X, boxCoordinates.BottomLeft.Y)
                                local BL = Vector2.new(boxCoordinates.BottomLeft.X, boxCoordinates.TopRight.Y)
                                local BR = boxCoordinates.TopRight

                                -- Top Left
                                corners[1].From = TL
                                corners[1].To = TL + Vector2.new(cornerSize, 0)
                                corners[2].From = TL
                                corners[2].To = TL + Vector2.new(0, cornerSize)

                                -- Top Right
                                corners[3].From = TR
                                corners[3].To = TR + Vector2.new(-cornerSize, 0)
                                corners[4].From = TR
                                corners[4].To = TR + Vector2.new(0, cornerSize)

                                -- Bottom Left
                                corners[5].From = BL
                                corners[5].To = BL + Vector2.new(cornerSize, 0)
                                corners[6].From = BL
                                corners[6].To = BL + Vector2.new(0, -cornerSize)

                                -- Bottom Right
                                corners[7].From = BR
                                corners[7].To = BR + Vector2.new(-cornerSize, 0)
                                corners[8].From = BR
                                corners[8].To = BR + Vector2.new(0, -cornerSize)

                                for _, corner in pairs(corners) do
                                    corner.Visible = true
                                    corner.Color = espColor
                                end
                            end
                        else
                            for _, corner in pairs(ESPObjects[player].corners) do
                                corner.Visible = false
                            end
                        end
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
                else
                    -- Hide ESP if player is off screen or too far
                    for _, object in pairs(ESPObjects[player]) do
                        if type(object) == "table" then
                            for _, subObject in pairs(object) do
                                subObject.Visible = false
                            end
                        else
                            object.Visible = false
                        end
                    end
                end
            end
        end
    end

    -- Update FOV Circle
    if FOVCircle then
        FOVCircle.Visible = Options.FOVEnabled.Value
        if Options.FOVEnabled.Value then
            if Options.FOVFollowMouse.Value then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
            else
                FOVCircle.Position = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 2)
            end
            FOVCircle.Radius = Options.FOVRadius.Value
            FOVCircle.Color = Options.FOVColor.Value
        end
    end
end

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

return {
    InitESP = InitESP,
    CleanupESP = CleanupESP,
    CleanupAllESP = CleanupAllESP,  -- Add new function
    UpdateESP = UpdateESP,
    CreateFOVCircle = CreateFOVCircle,
    RemoveFOVCircle = RemoveFOVCircle
}
