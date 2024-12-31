local VERSION = "S-101.2"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Fix module loading
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/spooderman11/surge/main/modules/esp.lua"))()

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

    -- Remove FontStyle dropdown and add new customization options
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

    -- Update callbacks for customization
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
end

-- ESP Update Loop with error handling
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(function()
        ESP.UpdateESP(Options)
    end)
end)

-- Player cleanup handlers with error handling
game:GetService("Players").PlayerRemoving:Connect(function(player)
    pcall(function()
        ESP.CleanupESP(player)
    end)
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
    pcall(function()
        if ESPObjects and ESPObjects[player] then
            ESP.CleanupESP(player)
        end
    end)
end)

-- Clean all ESP when game ends or player teleports
game:GetService("CoreGui").DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "MainGui" then
        ESP.CleanupAllESP()
    end
end)

-- Cleanup on character events
game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    ESP.RemoveFOVCircle()
    ESP.CleanupAllESP()
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    ESP.CreateFOVCircle()
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

Window:SelectTab(1)

Fluent:Notify({
    Title = "surge.lua v." .. VERSION,
    Content = "Script has been loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
