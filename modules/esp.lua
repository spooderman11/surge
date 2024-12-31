local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ESP = {
    Config = {
        Enabled = false, -- Changed default
        BoxEnabled = false, -- Changed default
        BoxColor = Color3.fromRGB(255, 255, 255),
        HealthBarEnabled = false, -- Changed default
        TextEnabled = false, -- Changed default
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        ShowEquipped = false, -- Changed default
        -- New tracer settings
        TracerEnabled = false,
        TracerColor = Color3.fromRGB(255, 255, 255),
        TracerOrigin = "Bottom", -- "Top", "Middle", "Bottom", "Mouse"
        TracerThickness = 1,
        -- New FOV circle settings
        FovEnabled = false,
        FovColor = Color3.fromRGB(255, 255, 255),
        FovSize = 100,
        FovFilled = false,
        FovTransparency = 1
    },
    PlayerData = {},
    UpdateDrawing = function(self, drawingType)
        for _, drawings in pairs(self.PlayerData) do
            if drawingType == "text" or drawingType == "all" then
                if drawings.NameText then
                    drawings.NameText.Size = self.Config.TextSize
                    drawings.NameText.Color = self.Config.TextColor
                    drawings.NameText.Visible = self.Config.Enabled and self.Config.TextEnabled
                end
                if drawings.RobloxName then
                    drawings.RobloxName.Size = self.Config.TextSize
                    drawings.RobloxName.Color = self.Config.TextColor
                    drawings.RobloxName.Visible = self.Config.Enabled and self.Config.TextEnabled
                end
                if drawings.EquipText then
                    drawings.EquipText.Size = self.Config.TextSize
                    drawings.EquipText.Color = self.Config.TextColor
                    drawings.EquipText.Visible = self.Config.Enabled and self.Config.TextEnabled and self.Config.ShowEquipped
                end
            end
            if drawingType == "box" or drawingType == "all" then
                if drawings.Box then
                    drawings.Box.Color = self.Config.BoxColor
                    drawings.Box.Visible = self.Config.Enabled and self.Config.BoxEnabled
                end
            end
            if drawingType == "health" or drawingType == "all" then
                if drawings.HealthBar then
                    drawings.HealthBar.Visible = self.Config.Enabled and self.Config.HealthBarEnabled
                    drawings.HealthBarOutline.Visible = self.Config.Enabled and self.Config.HealthBarEnabled
                end
            end
        end
    end
}

local function HasRequiredBodyParts(character)
    local requiredParts = {"Head", "Torso", "HumanoidRootPart", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}
    for _, partName in ipairs(requiredParts) do
        if not character:FindFirstChild(partName) then
            return false
        end
    end
    return true
end

local function GetEquippedItem(character)
    local equipped = "[NONE]"
    
    -- Check for tools/weapons
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then
        equipped = "[" .. tool.Name .. "]"
    end
    
    return equipped
end

local function CreateDrawings(player)
    local drawings = {
        Box = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        NameText = Drawing.new("Text"),
        RobloxName = Drawing.new("Text"),
        EquipText = Drawing.new("Text"),
        -- Add tracer
        Tracer = Drawing.new("Line")
    }
    
    -- Add FOV Circle (single instance for all players)
    if not ESP.FovCircle then
        ESP.FovCircle = Drawing.new("Circle")
        ESP.FovCircle.Thickness = 1
        ESP.FovCircle.NumSides = 60
        ESP.FovCircle.Radius = ESP.Config.FovSize
        ESP.FovCircle.Filled = ESP.Config.FovFilled
        ESP.FovCircle.Visible = ESP.Config.FovEnabled
        ESP.FovCircle.Transparency = ESP.Config.FovTransparency
        ESP.FovCircle.Color = ESP.Config.FovColor
    end
    
    -- Box settings
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    -- Healthbar settings
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Visible = false
    drawings.HealthBarOutline.Thickness = 1
    drawings.HealthBarOutline.Filled = false
    drawings.HealthBarOutline.Visible = false
    
    -- Text settings
    drawings.NameText.Center = true
    drawings.NameText.Size = ESP.Config.TextSize
    drawings.NameText.Outline = true
    drawings.NameText.Visible = false
    
    drawings.RobloxName.Center = true
    drawings.RobloxName.Size = ESP.Config.TextSize
    drawings.RobloxName.Outline = true
    drawings.RobloxName.Visible = false
    
    -- Add equipment text settings
    drawings.EquipText.Center = true
    drawings.EquipText.Size = ESP.Config.TextSize
    drawings.EquipText.Outline = true
    drawings.EquipText.Visible = false
    
    -- Tracer settings
    drawings.Tracer.Thickness = ESP.Config.TracerThickness
    drawings.Tracer.Visible = false
    
    ESP.PlayerData[player] = drawings
end

local function RemoveDrawings(player)
    if ESP.PlayerData[player] then
        for _, drawing in pairs(ESP.PlayerData[player]) do
            drawing:Remove()
        end
        ESP.PlayerData[player] = nil
    end
end

local function GetIngameName(player)
    local live = game:GetService("Workspace"):FindFirstChild("Live")
    if live then
        local playerFolder = live:FindFirstChild(player.Name)
        if playerFolder then
            -- Blacklist specific model names
            local blacklistedNames = {
                ["RightRuneArm"] = true,
                ["LeftRuneArm"] = true
            }
            
            -- Loop through children and find the first non-blacklisted model
            for _, child in pairs(playerFolder:GetChildren()) do
                if child:IsA("Model") and not blacklistedNames[child.Name] then
                    return child.Name
                end
            end
        end
    end
    return player.Name -- Fallback to regular name if no valid model found
end

local function UpdateESP()
    -- Update FOV Circle
    if ESP.FovCircle then
        ESP.FovCircle.Position = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 2)
        ESP.FovCircle.Visible = ESP.Config.FovEnabled
        ESP.FovCircle.Radius = ESP.Config.FovSize
        ESP.FovCircle.Color = ESP.Config.FovColor
        ESP.FovCircle.Filled = ESP.Config.FovFilled
        ESP.FovCircle.Transparency = ESP.Config.FovTransparency
    end

    for player, drawings in pairs(ESP.PlayerData) do
        if player.Character 
            and player.Character:FindFirstChild("HumanoidRootPart") 
            and player.Character:FindFirstChild("Humanoid")
            and HasRequiredBodyParts(player.Character) then -- Check for required body parts
            
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            
            if onScreen and ESP.Config.Enabled then
                -- Get character bounds
                local topPosition = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local bottomPosition = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = math.abs(topPosition.Y - bottomPosition.Y)
                local width = height * 0.6 -- Adjust width based on height for proper proportions
                
                -- Update box
                if ESP.Config.BoxEnabled then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    drawings.Box.Color = ESP.Config.BoxColor
                    drawings.Box.Visible = true
                end
                
                -- Update healthbar (moved to the side)
                if ESP.Config.HealthBarEnabled then
                    local healthBarWidth = 4
                    local healthBarOutlinePos = Vector2.new(vector.X + (width / 2) + 3, vector.Y - height / 2)
                    local healthPercentage = humanoid.Health / humanoid.MaxHealth
                    
                    drawings.HealthBarOutline.Size = Vector2.new(healthBarWidth, height)
                    drawings.HealthBarOutline.Position = healthBarOutlinePos
                    drawings.HealthBarOutline.Color = Color3.new(0, 0, 0)
                    drawings.HealthBarOutline.Visible = true
                    
                    drawings.HealthBar.Size = Vector2.new(healthBarWidth - 2, (height - 2) * healthPercentage)
                    drawings.HealthBar.Position = Vector2.new(healthBarOutlinePos.X + 1, healthBarOutlinePos.Y + (height - drawings.HealthBar.Size.Y) - 1)
                    drawings.HealthBar.Color = Color3.fromHSV(healthPercentage * 0.3, 1, 1)
                    drawings.HealthBar.Visible = true
                end
                
                -- Update text positions relative to new box size
                if ESP.Config.TextEnabled then
                    local ingameName = GetIngameName(player)
                    local equipped = GetEquippedItem(player.Character)
                    
                    drawings.NameText.Position = Vector2.new(vector.X, vector.Y - height / 2 - 15)
                    drawings.NameText.Color = ESP.Config.TextColor
                    drawings.NameText.Text = ingameName -- Use ingame name here
                    drawings.NameText.Size = ESP.Config.TextSize
                    drawings.NameText.Visible = true
                    
                    drawings.RobloxName.Position = Vector2.new(vector.X, vector.Y + height / 2 + 5)
                    drawings.RobloxName.Color = ESP.Config.TextColor
                    drawings.RobloxName.Text = "@" .. player.Name -- Keep Roblox username
                    drawings.RobloxName.Size = ESP.Config.TextSize
                    drawings.RobloxName.Visible = true
                    
                    -- Only show EquipText if ShowEquipped is enabled
                    if ESP.Config.ShowEquipped then
                        drawings.EquipText.Position = Vector2.new(vector.X, vector.Y + height / 2 + 20)
                        drawings.EquipText.Color = ESP.Config.TextColor
                        drawings.EquipText.Text = equipped
                        drawings.EquipText.Size = ESP.Config.TextSize
                        drawings.EquipText.Visible = true
                    else
                        drawings.EquipText.Visible = false
                    end
                end

                -- Update tracer
                if ESP.Config.TracerEnabled then
                    local tracerStart
                    local viewportSize = game.Workspace.CurrentCamera.ViewportSize
                    
                    -- Determine tracer start position based on origin setting
                    if ESP.Config.TracerOrigin == "Top" then
                        tracerStart = Vector2.new(viewportSize.X / 2, 0)
                    elseif ESP.Config.TracerOrigin == "Middle" then
                        tracerStart = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    elseif ESP.Config.TracerOrigin == "Bottom" then
                        tracerStart = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    elseif ESP.Config.TracerOrigin == "Mouse" then
                        tracerStart = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, 
                                                game:GetService("UserInputService"):GetMouseLocation().Y)
                    end
                    
                    drawings.Tracer.From = tracerStart
                    drawings.Tracer.To = Vector2.new(vector.X, vector.Y)
                    drawings.Tracer.Color = ESP.Config.TracerColor
                    drawings.Tracer.Thickness = ESP.Config.TracerThickness
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.HealthBar.Visible = false
                drawings.HealthBarOutline.Visible = false
                drawings.NameText.Visible = false
                drawings.RobloxName.Visible = false
                drawings.EquipText.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            -- Hide ESP if character isn't fully loaded
            drawings.Box.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBarOutline.Visible = false
            drawings.NameText.Visible = false
            drawings.RobloxName.Visible = false
            drawings.EquipText.Visible = false
            drawings.Tracer.Visible = false
        end
    end
end

-- Clean up FOV Circle when ESP is destroyed
local function CleanupESP()
    if ESP.FovCircle then
        ESP.FovCircle:Remove()
        ESP.FovCircle = nil
    end
end

-- Player handling
Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then
        CreateDrawings(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveDrawings(player)
end)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        CreateDrawings(player)
    end
end

-- Update loop
RunService.RenderStepped:Connect(UpdateESP)

return ESP
