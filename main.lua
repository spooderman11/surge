local VERSION = "S-101.2"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Fix module loading with proper error handling
local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Failed to load module from: " .. url)
        return nil
    end
    return result
end

-- Load modules
local ESP = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/esp.lua")
local SpeedModule = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/speed.lua")
local Aimbot = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/aimbot.lua")
local FlyModule = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/fly.lua")

local function kick(reason)
    game.Players.LocalPlayer:Kick(reason)
end

-- Error checking
if not ESP or not SpeedModule or not Aimbot or not FlyModule then
    kick("Failed to load one or more required modules!")
    return
end

-- Initialize modules if needed
ESP.CreateFOVCircle() -- Initialize FOV circle

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
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user-round" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "folder-open" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ESP Settings
do
    local ESPEnabled = Tabs.ESP:AddToggle("ESPEnabled", {
        Title = "Enable ESP",
        Description = "Master toggle - required for all ESP features to work",
        Default = false
    })

    local BoxESP = Tabs.ESP:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = false
    })

    local StaticESP = Tabs.ESP:AddToggle("StaticESP", {
        Title = "Static Box Size",
        Description = "Use fixed size for ESP boxes",
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

    local TracerPosition = Tabs.ESP:AddDropdown("TracerPosition", {
        Title = "Tracer Position",
        Description = "Choose tracer start position",
        Values = {"Down", "Middle", "Up", "Mouse"},
        Default = "Down"
    })

    local ESPType = Tabs.ESP:AddDropdown("ESPType", {
        Title = "ESP Style",
        Description = "Choose ESP box style",
        Values = {"Box", "Off"},
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

    local ESPCustomization = Tabs.ESP:AddSection("ESP Customization")

    local BoxThickness = ESPCustomization:AddSlider("BoxThickness", {
        Title = "Box Thickness",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 1
    })

    local BoxTransparency = ESPCustomization:AddSlider("BoxTransparency", {
        Title = "Box Transparency",
        Default = 1,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    local TracerThickness = ESPCustomization:AddSlider("TracerThickness", {
        Title = "Tracer Thickness",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 1
    })

    local TracerTransparency = ESPCustomization:AddSlider("TracerTransparency", {
        Title = "Tracer Transparency",
        Default = 1,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    local TextOutline = ESPCustomization:AddToggle("TextOutline", {
        Title = "Text Outline",
        Default = true
    })

    BoxThickness:OnChanged(function(Value)
        ESP.Settings.BoxThickness = Value
    end)

    BoxTransparency:OnChanged(function(Value)
        ESP.Settings.BoxTransparency = Value
    end)

    TracerThickness:OnChanged(function(Value)
        ESP.Settings.TracerThickness = Value
    end)

    TracerTransparency:OnChanged(function(Value)
        ESP.Settings.TracerTransparency = Value
    end)

    TextOutline:OnChanged(function(Value)
        ESP.Settings.TextOutline = Value
    end)

    -- Update Chams section
    local ChamsSection = Tabs.ESP:AddSection("Chams")

    local ChamsEnabled = ChamsSection:AddToggle("ChamsEnabled", {
        Title = "Enable Chams",
        Description = "Highlights players through walls",
        Default = false
    })

    local ChamsColor = ChamsSection:AddColorpicker("ChamsColor", {
        Title = "Chams Outline Color",
        Default = Color3.fromRGB(255, 0, 0)
    })

    local ChamsTransparency = ChamsSection:AddSlider("ChamsTransparency", {
        Title = "Chams Transparency",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    local ChamsFillColor = ChamsSection:AddColorpicker("ChamsFillColor", {
        Title = "Chams Fill Color",
        Default = Color3.fromRGB(255, 0, 0)
    })

    local ChamsFillTransparency = ChamsSection:AddSlider("ChamsFillTransparency", {
        Title = "Fill Transparency",
        Default = 0.8,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    -- Update Chams handlers
    ChamsEnabled:OnChanged(function(Value)
        ESP.Settings.ChamsEnabled = Value
        if not Value then
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if ESPObjects[player] and ESPObjects[player].chams then
                    ESPObjects[player].chams:Destroy()
                    ESPObjects[player].chams = nil
                end
            end
        else
            -- Reinitialize Chams for all players when enabled
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    if not ESPObjects[player] then
                        ESP.InitESP(player)
                    elseif not ESPObjects[player].chams then
                        ESPObjects[player].chams = ESP.CreateChams(player)
                    end
                end
            end
        end
    end)

    ChamsColor:OnChanged(function(Value)
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if ESPObjects[player] and ESPObjects[player].chams then
                ESPObjects[player].chams.OutlineColor = Value
            end
        end
    end)

    ChamsTransparency:OnChanged(function(Value)
        ESP.Settings.ChamsTransparency = Value
    end)

    ChamsFillColor:OnChanged(function(Value)
        ESP.Settings.ChamsFillColor = Value
    end)

    ChamsFillTransparency:OnChanged(function(Value)
        ESP.Settings.ChamsFillTransparency = Value
    end)
end

-- Aimbot Settings
do
    local AimbotSection = Tabs.Combat:AddSection("Aimbot Controls")
    local TargetingSection = Tabs.Combat:AddSection("Targeting")
    local PredictionSection = Tabs.Combat:AddSection("Prediction")
    local KeybindSection = Tabs.Combat:AddSection("Keybind Settings") -- Changed this line

    local AimbotToggle = AimbotSection:AddToggle("AimbotToggle", {
        Title = "Enable Aimbot",
        Default = false
    })

    local AimbotMode = AimbotSection:AddDropdown("AimbotMode", {
        Title = "Aimbot Mode",
        Values = {"Tween", "Mouse", "Camera"},
        Default = "Tween"
    })

    local TargetMode = TargetingSection:AddDropdown("TargetMode", {
        Title = "Lock System",
        Values = {"Closest To Mouse", "Closest To Player"},
        Default = "Closest To Mouse"
    })

    local TargetLock = TargetingSection:AddToggle("TargetLock", {
        Title = "Lock Current Target",
        Default = true
    })

    local DeathUnlock = TargetingSection:AddToggle("DeathUnlock", {
        Title = "Unlock On Death",
        Default = true
    })

    local PredictionToggle = PredictionSection:AddToggle("PredictionToggle", {
        Title = "Enable Prediction",
        Default = false
    })

    local PredictionX = PredictionSection:AddSlider("PredictionX", {
        Title = "Prediction X",
        Default = 1,
        Min = 0,
        Max = 10,
        Rounding = 2
    })

    local PredictionY = PredictionSection:AddSlider("PredictionY", {
        Title = "Prediction Y",
        Default = 1,
        Min = 0,
        Max = 10,
        Rounding = 2
    })

    local SmoothnessToggle = AimbotSection:AddToggle("SmoothnessToggle", {
        Title = "Enable Smoothing",
        Default = false
    })

    local SmoothnessSlider = AimbotSection:AddSlider("SmoothnessSlider", {
        Title = "Smoothness",
        Description = "Lower = Faster",
        Default = 0.5,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    -- Add to Aimbot Settings section
    local KeybindMode = KeybindSection:AddDropdown("KeybindMode", {
        Title = "Keybind Mode",
        Values = {"Toggle", "Hold"},
        Default = "Toggle"
    })

    local AimbotKeybind = KeybindSection:AddKeybind("AimbotKeybind", {
        Title = "Aimbot Keybind",
        Mode = "Toggle", -- Set initial mode
        Default = "MouseButton2", -- Right mouse button as default
    })

    -- Update Keybind Mode when changed
    KeybindMode:OnChanged(function(Value)
        AimbotKeybind:SetValue(AimbotKeybind.Value, Value) -- Update the keybind mode
    end)

    -- Handle keybind state changes
    AimbotKeybind:OnClick(function()
        if KeybindMode.Value == "Toggle" then
            AimbotToggle:SetValue(not AimbotToggle.Value)
        end
    end)

    -- Handle hold mode
    AimbotKeybind:OnChanged(function(Value)
        if KeybindMode.Value == "Hold" then
            AimbotToggle:SetValue(Value)
        end
    end)

    -- Update handlers
    AimbotToggle:OnChanged(function(Value)
        Aimbot.Toggle(Value)
    end)

    AimbotMode:OnChanged(function(Value)
        Aimbot.Settings.Mode = Value
    end)

    TargetMode:OnChanged(function(Value)
        Aimbot.Settings.TargetMode = Value
        Aimbot.Target = nil
    end)

    TargetLock:OnChanged(function(Value)
        Aimbot.Settings.TargetLock = Value
    end)

    DeathUnlock:OnChanged(function(Value)
        Aimbot.Settings.DeathUnlock = Value
    end)

    PredictionToggle:OnChanged(function(Value)
        Aimbot.Settings.Prediction = Value
    end)

    PredictionX:OnChanged(function(Value)
        Aimbot.Settings.PredictionX = Value
    end)

    PredictionY:OnChanged(function(Value)
        Aimbot.Settings.PredictionY = Value
    end)

    SmoothnessToggle:OnChanged(function(Value)
        Aimbot.Settings.Smoothness = Value
    end)

    SmoothnessSlider:OnChanged(function(Value)
        Aimbot.Settings.SmoothnessValue = Value
    end)
end

do
    local SpeedEnabled = Tabs.Player:AddToggle("SpeedEnabled", {
        Title = "Enable Speed",
        Default = false
    })

    local SpeedValue = Tabs.Player:AddSlider("SpeedValue", {
        Title = "Speed Value",
        Default = 10,
        Min = 1,
        Max = 50,
        Rounding = 0
    })

    SpeedEnabled:OnChanged(function(Value)
        if Value then
            SpeedModule.SetSpeed(SpeedValue.Value)
        else
            SpeedModule.SetSpeed(0)
        end
    end)

    SpeedValue:OnChanged(function(Value)
        if SpeedEnabled.Value then
            SpeedModule.SetSpeed(Value)
        end
    end)
end

-- Replace existing Fly controls with this updated version
do
    local FlySection = Tabs.Player:AddSection("Fly")
    
    local FlyEnabled = FlySection:AddToggle("FlyEnabled", {
        Title = "Enable Fly",
        Default = false
    })

    local FlySpeed = FlySection:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Default = 50,
        Min = 10,
        Max = 200,
        Rounding = 0
    })

    local FlyKeybind = FlySection:AddKeybind("FlyKeybind", {
        Title = "Toggle Fly",
        Mode = "Toggle",
        Default = "F",
        
        Callback = function(Value)
            FlyEnabled:SetValue(not FlyEnabled.Value)
        end
    })

    FlyEnabled:OnChanged(function(Value)
        if Value then
            FlyModule.StartFlying()
            FlyModule.SetSpeed(FlySpeed.Value)
        else
            FlyModule.StopFlying()
        end
    end)

    FlySpeed:OnChanged(function(Value)
        if FlyEnabled.Value then
            FlyModule.SetSpeed(Value)
        end
    end)
end

game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        ESP.UpdateESP(Options)
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    pcall(function()
        ESP.CleanupESP(player) -- some esp tipes setrenderproperty is a thign and cleardrawcache
    end)
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
    pcall(function()
        if ESPObjects and ESPObjects[player] then
            ESP.CleanupESP(player)
        end
    end)
end)

game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "MainGui" then
        ESP.CleanupAllESP()
    end
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    ESP.RemoveFOVCircle()
    ESP.CleanupAllESP()
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    ESP.CreateFOVCircle()
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Surge")
SaveManager:SetFolder("Surge/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "surge.lua v." .. VERSION,
    Content = "Script has been loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
