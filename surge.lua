local VERSION = "S101.1"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "surge.lua v." .. VERSION,
    SubTitle = "by Spoody",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ESP Storage
local ESPObjects = {}

-- Add after ESP Storage section
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false

-- ESP Creation Functions (Moved to top)
local function CreateESP(player)
    local esp = Drawing.new("Text")
    esp.Visible = false
    esp.Center = true
    esp.Outline = true
    esp.Font = 2
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

-- Add new ESP types
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

-- Initialize ESP for a player
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

-- Cleanup ESP
local function CleanupESP(player)
    if ESPObjects[player] then
        for _, object in pairs(ESPObjects[player]) do
            object:Remove()
        end
        ESPObjects[player] = nil
    end
end

-- Calculate 3D box corners
local function CalculateBox(character)
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

-- ESP Settings
do
    local ESPEnabled = Tabs.ESP:AddToggle("ESPEnabled", {
        Title = "Enable ESP",
        Default = false
    })

    local BoxESP = Tabs.ESP:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false
    })

    local NameESP = Tabs.ESP:AddToggle("NameESP", {
        Title = "Name ESP",
        Default = false
    })

    local DistanceESP = Tabs.ESP:AddToggle("DistanceESP", {
        Title = "Distance ESP",
        Default = false
    })

    local TracerESP = Tabs.ESP:AddToggle("TracerESP", {
        Title = "Tracers",
        Default = false
    })

    local ESPColor = Tabs.ESP:AddColorpicker("ESPColor", {
        Title = "ESP Color",
        Default = Color3.fromRGB(255, 255, 255)
    })

    local ESPDistance = Tabs.ESP:AddSlider("ESPDistance", {
        Title = "ESP Distance",
        Description = "Maximum distance to render ESP",
        Default = 1000,
        Min = 0,
        Max = 2000,
        Rounding = 0
    })

    -- Add after existing ESP Settings but before the ESP Update Loop
    local TracerPosition = Tabs.ESP:AddDropdown("TracerPosition", {
        Title = "Tracer Position",
        Description = "Choose tracer start position",
        Values = {"Down", "Middle", "Up", "Mouse"},
        Default = "Down"
    })

    local ESPType = Tabs.ESP:AddDropdown("ESPType", {
        Title = "ESP Style",
        Description = "Choose ESP box style",
        Values = {"Box", "Corner", "Off"},
        Default = "Box"
    })

    local FontSize = Tabs.ESP:AddSlider("FontSize", {
        Title = "Font Size",
        Description = "Size for name and distance ESP",
        Default = 13,
        Min = 8,
        Max = 24,
        Rounding = 0
    })

    local HealthBarESP = Tabs.ESP:AddToggle("HealthBarESP", {
        Title = "Health Bar",
        Default = false
    })

    local FOVSettings = Tabs.ESP:AddSection("FOV Settings")

    local FOVEnabled = FOVSettings:AddToggle("FOVEnabled", {
        Title = "Enable FOV Circle",
        Default = false
    })

    local FOVFollowMouse = FOVSettings:AddToggle("FOVFollowMouse", {
        Title = "Follow Mouse",
        Default = false
    })

    local FOVRadius = FOVSettings:AddSlider("FOVRadius", {
        Title = "FOV Radius",
        Description = "Adjust FOV circle size",
        Default = 100,
        Min = 0,
        Max = 500,
        Rounding = 0
    })

    local FOVColor = FOVSettings:AddColorpicker("FOVColor", {
        Title = "FOV Color",
        Default = Color3.fromRGB(255, 255, 255)
    })
end

-- ESP Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if not Options.ESPEnabled.Value then
        -- Hide all ESP objects
        for _, objects in pairs(ESPObjects) do
            for _, object in pairs(objects) do
                if type(object) == "table" then -- For corners
                    for _, corner in pairs(object) do
                        corner.Visible = false
                    end
                else
                    object.Visible = false
                end
            end
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
                        local boxCoordinates = CalculateBox(character)
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
                            local boxCoordinates = CalculateBox(character)
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
                        local boxCoordinates = CalculateBox(character)
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
end)

-- Cleanup on player removal
game:GetService("Players").PlayerRemoving:Connect(function(player)
    CleanupESP(player)
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    FOVCircle:Remove()
end)

-- Add FOV Circle recreation on character spawn
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.new(1, 1, 1)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 1
    FOVCircle.NumSides = 100
    FOVCircle.Radius = 100
    FOVCircle.Filled = false
end)

-- Setup SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SurgeESP")
SaveManager:SetFolder("SurgeESP/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
/
Window:SelectTab(1)

Fluent:Notify({
    Title = "surge.lua v." .. VERSION,
    Content = "Script has been loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
