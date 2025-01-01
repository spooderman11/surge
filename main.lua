local VERSION = "S-110.8"

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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

local ESP = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/esp.lua")
local SpeedModule = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/speed.lua")
local Aimbot = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/aimbot.lua")
local FlyModule = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/fly.lua")
local MiscModule = loadModule("https://raw.githubusercontent.com/spooderman11/surge/main/modules/misc.lua")

if not ESP then
    warn("ESP module failed to load!")
    return
end
local function kick(reason)
    game.Players.LocalPlayer:Kick(reason)
end

if not ESP or not SpeedModule or not Aimbot or not FlyModule then
    kick("Failed to load one or more required modules!")
    return
end

local Window = Fluent:CreateWindow({
    Title = "surge.lua v." .. VERSION,
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Esp = Window:AddTab({ Title = "Esp", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user-round" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "folder-open" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    local AimbotSection = Tabs.Combat:AddSection("Aimbot Controls")
    local TargetingSection = Tabs.Combat:AddSection("Targeting")
    local PredictionSection = Tabs.Combat:AddSection("Prediction")
    local KeybindSection = Tabs.Combat:AddSection("Keybind Settings")

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

do
    local TeleportationSection = Tabs.misc:AddSection("Teleportations")

    Tabs.misc:AddButton({
        Title = "Rejoin",
        Description = "Rejoins the exact server your in.",
        Callback = function()
            Window:Dialog({
                Title = "Are You Sure?",
                Content = "Pressing confirm will rejoin the server but make sure you have saved your progress / arent in any sort of combat.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.Misc.Rejoin()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            -- Do nothing
                        end
                    }
                }
            })
        end
    })

    Tabs.misc:AddButton({
        Title = "Server Hop",
        Description = "Switches to a new server.",
        Callback = function()
            Window:Dialog({
                Title = "Are You Sure?",
                Content = "Pressing confirm will switch server so make sure you have saved your progress / arent in any sort of combat.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.Serverhop.Rejoin()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            -- Do nothing
                        end
                    }
                }
            })
        end
    })

    Tabs.misc:AddButton({
        Title = "Join Lowest Server",
        Description = "Joins the server with the lowest amount of players. ( May not work on Solara )",
        Callback = function()
            Window:Dialog({
                Title = "Are You Sure?",
                Content = "Pressing confirm will switch server so make sure you have saved your progress / arent in any sort of combat.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.JoinLowestServer.Rejoin()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            -- Do nothing
                        end
                    }
                }
            })
        end
    })

    Tabs.misc:AddButton({
        Title = "Join Highest Server",
        Description = "Joins the server with the Highest amount of players. ( May not work on Solara )",
        Callback = function()
            Window:Dialog({
                Title = "Are You Sure?",
                Content = "Pressing confirm will switch server so make sure you have saved your progress / arent in any sort of combat.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.JoinLowestServer.Rejoin()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            -- Do nothing
                        end
                    }
                }
            })
        end
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Surge")
SaveManager:SetFolder("Surge/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

do
    local PlayerEspSection = Tabs.Esp:AddSection("Player ESP")
    
    local EspToggle = Tabs.Esp:AddToggle("PlayerESP", {
        Title = "Player ESP",
        Default = ESP.Config.Enabled -- Fix: Changed from .True to .Enabled
    })

    local ShowHeldToggle = Tabs.Esp:AddToggle("ShowHeldESP", {
        Title = "Show Held",
        Default = ESP.Config.ShowEquipped
    })

    local BoxToggle = Tabs.Esp:AddToggle("BoxESP", {
        Title = "Box ESP",
        Default = ESP.Config.BoxEnabled
    })

    local BoxColor = Tabs.Esp:AddColorpicker("BoxColor", {
        Title = "Box Color",
        Default = ESP.Config.BoxColor
    })

    local HealthBarToggle = Tabs.Esp:AddToggle("HealthBar", {
        Title = "Health Bar",
        Default = ESP.Config.HealthBarEnabled
    })

    local TextToggle = Tabs.Esp:AddToggle("NameESP", {
        Title = "Name ESP",
        Default = ESP.Config.TextEnabled
    })

    local TextColor = Tabs.Esp:AddColorpicker("TextColor", {
        Title = "Text Color",
        Default = ESP.Config.TextColor
    })

    local TextSize = Tabs.Esp:AddSlider("TextSize", {
        Title = "Text Size",
        Description = "Adjust ESP text size",
        Default = ESP.Config.TextSize,
        Min = 8,
        Max = 24,
        Rounding = 0
    })

    local TracerSection = Tabs.Esp:AddSection("Tracers")
    
    local TracerToggle = TracerSection:AddToggle("TracerESP", {
        Title = "Enable Tracers",
        Default = false
    })

    local TracerOrigin = TracerSection:AddDropdown("TracerOrigin", {
        Title = "Tracer Origin",
        Values = {"Top", "Middle", "Bottom", "Mouse"},
        Default = "Bottom"
    })

    local TracerColor = TracerSection:AddColorpicker("TracerColor", {
        Title = "Tracer Color",
        Default = ESP.Config.TracerColor
    })

    local TracerThickness = TracerSection:AddSlider("TracerThickness", {
        Title = "Tracer Thickness",
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 0
    })

    local FovSection = Tabs.Esp:AddSection("FOV Circle")

    local FovToggle = FovSection:AddToggle("FovEnabled", {
        Title = "Show FOV Circle",
        Default = false
    })

    local FovSize = FovSection:AddSlider("FovSize", {
        Title = "FOV Size",
        Default = 100,
        Min = 10,
        Max = 500,
        Rounding = 0
    })

    local FovColor = FovSection:AddColorpicker("FovColor", {
        Title = "FOV Color",
        Default = ESP.Config.FovColor
    })

    local FovFilled = FovSection:AddToggle("FovFilled", {
        Title = "Filled FOV",
        Default = false
    })

    local FovTransparency = FovSection:AddSlider("FovTransparency", {
        Title = "FOV Transparency",
        Default = 1,
        Min = 0,
        Max = 1,
        Rounding = 2
    })

    local FovFollowMouse = FovSection:AddToggle("FovFollowMouse", {
        Title = "FOV Follows Mouse",
        Default = false
    })

    Options.PlayerESP = EspToggle
    Options.ShowHeldESP = ShowHeldToggle
    Options.BoxESP = BoxToggle
    Options.BoxColor = BoxColor
    Options.HealthBar = HealthBarToggle
    Options.NameESP = TextToggle
    Options.TextColor = TextColor
    Options.TextSize = TextSize
    Options.TracerESP = TracerToggle
    Options.TracerOrigin = TracerOrigin
    Options.TracerColor = TracerColor
    Options.TracerThickness = TracerThickness
    Options.FovEnabled = FovToggle
    Options.FovSize = FovSize
    Options.FovColor = FovColor
    Options.FovFilled = FovFilled
    Options.FovTransparency = FovTransparency
    Options.FovFollowMouse = FovFollowMouse

    EspToggle:OnChanged(function(Value)
        ESP.Config.Enabled = Value
        ESP:UpdateDrawing("all")
    end)

    BoxToggle:OnChanged(function(Value)
        ESP.Config.BoxEnabled = Value
        ESP:UpdateDrawing("box")
    end)

    ShowHeldToggle:OnChanged(function(Value)
        ESP.Config.ShowEquipped = Value
        ESP:UpdateDrawing("box")
    end)

    BoxColor:OnChanged(function(Value)
        ESP.Config.BoxColor = Value
        ESP:UpdateDrawing("box")
    end)

    HealthBarToggle:OnChanged(function(Value)
        ESP.Config.HealthBarEnabled = Value
        ESP:UpdateDrawing("health")
    end)

    TextToggle:OnChanged(function(Value)
        ESP.Config.TextEnabled = Value
        ESP:UpdateDrawing("text")
    end)

    TextColor:OnChanged(function(Value)
        ESP.Config.TextColor = Value
        ESP:UpdateDrawing("text")
    end)

    TextSize:OnChanged(function(Value)
        ESP.Config.TextSize = Value
        ESP:UpdateDrawing("text")
    end)

    TracerToggle:OnChanged(function(Value)
        ESP.Config.TracerEnabled = Value
        ESP:UpdateDrawing("all")
    end)

    TracerOrigin:OnChanged(function(Value)
        ESP.Config.TracerOrigin = Value
        ESP:UpdateDrawing("all")
    end)

    TracerColor:OnChanged(function(Value)
        ESP.Config.TracerColor = Value
        ESP:UpdateDrawing("all")
    end)

    TracerThickness:OnChanged(function(Value)
        ESP.Config.TracerThickness = Value
        ESP:UpdateDrawing("all")
    end)

    FovToggle:OnChanged(function(Value)
        ESP.Config.FovEnabled = Value
        ESP:UpdateDrawing("all")
    end)

    FovSize:OnChanged(function(Value)
        ESP.Config.FovSize = Value
        ESP:UpdateDrawing("all")
    end)

    FovColor:OnChanged(function(Value)
        ESP.Config.FovColor = Value
        ESP:UpdateDrawing("all")
    end)

    FovFilled:OnChanged(function(Value)
        ESP.Config.FovFilled = Value
        ESP:UpdateDrawing("all")
    end)

    FovTransparency:OnChanged(function(Value)
        ESP.Config.FovTransparency = Value
        ESP:UpdateDrawing("all")
    end)

    FovFollowMouse:OnChanged(function(Value)
        ESP.Config.FovFollowMouse = Value
        ESP:UpdateDrawing("all")
    end)

    Options.PlayerESP:SetValue(ESP.Config.Enabled)
    Options.BoxESP:SetValue(ESP.Config.BoxEnabled)
    -- Options.BoxColor:SetValue(ESP.Config.BoxColor)
    Options.HealthBar:SetValue(ESP.Config.HealthBarEnabled)
    Options.NameESP:SetValue(ESP.Config.TextEnabled)
    -- Options.TextColor:SetValue(ESP.Config.TextColor)
    Options.TextSize:SetValue(ESP.Config.TextSize)
    Options.TracerESP:SetValue(ESP.Config.TracerEnabled)
    Options.TracerOrigin:SetValue(ESP.Config.TracerOrigin)
    -- Options.TracerColor:SetValue(ESP.Config.TracerColor)
    Options.TracerThickness:SetValue(ESP.Config.TracerThickness)
    Options.FovEnabled:SetValue(ESP.Config.FovEnabled)
    Options.FovSize:SetValue(ESP.Config.FovSize)
    -- Options.FovColor:SetValue(ESP.Config.FovColor)
    Options.FovFilled:SetValue(ESP.Config.FovFilled)
    Options.FovTransparency:SetValue(ESP.Config.FovTransparency)
    Options.FovFollowMouse:SetValue(ESP.Config.FovFollowMouse)
end

Window:SelectTab(1)

Fluent:Notify({
    Title = "surge.lua v." .. VERSION,
    Content = "Script has been loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
