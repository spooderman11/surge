local VERSION = "S101.1"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local ESP = require(loadstring(game:HttpGet("https://raw.githubusercontent.com/spooderman11/surge/refs/heads/main/modules/esp.luaa"))())
local Utils = require(loadstring(game:HttpGet("https://raw.githubusercontent.com/spooderman11/surge/refs/heads/main/modules/utils.lua"))())

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
    ESP.UpdateESP(Options)
end)

-- Cleanup on player removal
game:GetService("Players").PlayerRemoving:Connect(function(player)
    ESP.CleanupESP(player)
end)

game.Players.LocalPlayer.CharacterRemoving:Connect(function()
    ESP.RemoveFOVCircle()
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
