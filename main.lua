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
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
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
    local TeleportationSection = Tabs.Misc:AddSection("Teleportations")

    Tabs.Misc:AddButton({
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
                            MiscModule.Rejoin() -- Fixed: Changed Misc to MiscModule
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

    Tabs.Misc:AddButton({
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
                            MiscModule.Serverhop() -- Fixed: Changed Misc to MiscModule
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

    Tabs.Misc:AddButton({
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
                            MiscModule.JoinLowestServer()
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

    Tabs.Misc:AddButton({
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
                            MiscModule.JoinHighestServer() -- Fixed: Added MiscModule prefix
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

do
    local UtilitySection = Tabs.Misc:AddSection("Utility Features")

    local AntiAFKToggle = UtilitySection:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Default = false
    })

    local antiAFKConnection = nil
    AntiAFKToggle:OnChanged(function(Value)
        if Value then
            antiAFKConnection = MiscModule.AntiAFK()
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
    end)

    UtilitySection:AddButton({
        Title = "Remove Textures",
        Description = "Removes all textures and decals for better performance",
        Callback = function()
            Window:Dialog({
                Title = "Remove Textures",
                Content = "This will remove all textures and decals. This cannot be undone without rejoining.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.DeleteTextures()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function() end
                    }
                }
            })
        end
    })

    UtilitySection:AddButton({
        Title = "Low Graphics",
        Description = "Reduces graphics quality for better performance",
        Callback = function()
            Window:Dialog({
                Title = "Low Graphics",
                Content = "This will reduce graphics quality. This cannot be undone without rejoining.",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            MiscModule.LowGraphics()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function() end
                    }
                }
            })
        end
    })

    local PlayerFinderSection = Tabs.Misc:AddSection("Player Finder")

    local PlayerInput = PlayerFinderSection:AddInput("PlayerFinder", {
        Title = "Find Player",
        Default = "",
        Placeholder = "Enter partial name",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            local player = MiscModule.FindPlayer(Value)
            if player then
                Fluent:Notify({
                    Title = "Player Found",
                    Content = "Found player: " .. player.Name,
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Player Not Found",
                    Content = "No player found matching: " .. Value,
                    Duration = 3
                })
            end
        end
    })
end

do
    -- Add after existing Misc sections
    local MovementSection = Tabs.Misc:AddSection("Movement")
    
    local InfiniteJumpToggle = MovementSection:AddToggle("InfiniteJump", {
        Title = "Infinite Jump",
        Default = false
    })

    local NoClipToggle = MovementSection:AddToggle("NoClip", {
        Title = "No-Clip",
        Default = false
    })

    -- Remove ThirdPersonToggle and its OnChanged handler

    local VisualSection = Tabs.Misc:AddSection("Visual Enhancements")

    VisualSection:AddButton({
        Title = "Full Bright",
        Description = "Removes darkness",
        Callback = function()
            MiscModule.FullBright()
        end
    })

    VisualSection:AddButton({
        Title = "Remove Fog",
        Description = "Removes distance fog",
        Callback = function()
            MiscModule.RemoveFog()
        end
    })

    local TrollSection = Tabs.Misc:AddSection("Troll Features")

    local ChatSpamToggle = TrollSection:AddToggle("ChatSpam", {
        Title = "Chat Spam",
        Default = false
    })

    local ChatSpamMessage = TrollSection:AddInput("ChatSpamMessage", {
        Title = "Spam Message",
        Default = "surge.lua on top!",
        Placeholder = "Enter message to spam"
    })

    local ChatSpamInterval = TrollSection:AddSlider("ChatSpamInterval", {
        Title = "Spam Interval",
        Default = 1,
        Min = 0.1,
        Max = 10,
        Rounding = 1
    })

    local FeaturedScriptsSection = Tabs.Misc:AddSection("Featured Scripts")

    FeaturedScriptsSection:AddButton({
        Title = "Load Dex Explorer",
        Description = "Game Explorer",
        Callback = function()
            MiscModule.LoadDex()
        end
    })

    FeaturedScriptsSection:AddButton({
        Title = "Infinite Yield",
        Description = "Admin Commands",
        Callback = function()
            MiscModule.LoadIY()
        end
    })

    FeaturedScriptsSection:AddButton({
        Title = "Simple Spy V3",
        Description = "Remote Spy",
        Callback = function()
            MiscModule.LoadSimpleSpyV3()
        end
    })

    FeaturedScriptsSection:AddButton({
        Title = "Remote Spy",
        Description = "Alternative Remote Spy",
        Callback = function()
            MiscModule.LoadRemoteSpy()
        end
    })

    -- Connection handlers
    local infiniteJumpConnection
    InfiniteJumpToggle:OnChanged(function(Value)
        if Value then
            infiniteJumpConnection = MiscModule.InfiniteJump(true)
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
            end
        end
    end)

    local noClipConnection
    NoClipToggle:OnChanged(function(Value)
        if Value then
            noClipConnection = MiscModule.NoClip(true)
        else
            if noClipConnection then
                noClipConnection:Disconnect()
            end
        end
    end)

    -- Remove ThirdPersonToggle:OnChanged handler

    local chatSpamConnection
    ChatSpamToggle:OnChanged(function(Value)
        if Value then
            chatSpamConnection = MiscModule.ChatSpam(
                ChatSpamMessage.Value,
                ChatSpamInterval.Value
            )
        else
            if chatSpamConnection then
                chatSpamConnection:Disconnect()
            end
        end
    end)
end

do
    local CharacterSection = Tabs.Player:AddSection("Character Modifications")
    
    local WalkSpeedSlider = CharacterSection:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Default = 16,
        Min = 16,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            MiscModule.SetWalkSpeed(Value)
        end
    })

    local JumpPowerSlider = CharacterSection:AddSlider("JumpPower", {
        Title = "Jump Power",
        Default = 50,
        Min = 50,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            MiscModule.SetJumpPower(Value)
        end
    })

    local HipHeightSlider = CharacterSection:AddSlider("HipHeight", {
        Title = "Hip Height",
        Default = 0,
        Min = 0,
        Max = 50,
        Rounding = 1,
        Callback = function(Value)
            MiscModule.SetHipHeight(Value)
        end
    })

    local ViewSection = Tabs.Player:AddSection("View Modifications")
    
    local FreecamToggle = ViewSection:AddToggle("Freecam", {
        Title = "Enable Freecam",
        Default = false
    })

    local freecamConnection
    FreecamToggle:OnChanged(function(Value)
        if Value then
            freecamConnection = MiscModule.Freecam(true)
        else
            if freecamConnection then
                freecamConnection:Disconnect()
            end
        end
    end)

    local VisualEffectsSection = Tabs.Misc:AddSection("Visual Effects")

    local TimeOfDay = VisualEffectsSection:AddDropdown("TimeOfDay", {
        Title = "Time of Day",
        Values = {"Day", "Night", "Sunset", "Midnight"},
        Default = "Day",
        Callback = function(Value)
            local times = {
                Day = "12:00:00",
                Night = "20:00:00",
                Sunset = "17:30:00",
                Midnight = "00:00:00"
            }
            MiscModule.SetTimeOfDay(times[Value])
        end
    })

    local ShadowsToggle = VisualEffectsSection:AddToggle("Shadows", {
        Title = "Enable Shadows",
        Default = true,
        Callback = function(Value)
            MiscModule.ToggleShadows(Value)
        end
    })

    local RainbowToggle = VisualEffectsSection:AddToggle("RainbowCharacter", {
        Title = "Rainbow Character",
        Default = false
    })

    local rainbowConnection
    RainbowToggle:OnChanged(function(Value)
        if Value then
            rainbowConnection = MiscModule.RainbowCharacter(true)
        else
            if rainbowConnection then
                rainbowConnection:Disconnect()
            end
        end
    end)

    local GameEnhancementsSection = Tabs.Misc:AddSection("Game Enhancements")

    GameEnhancementsSection:AddButton({
        Title = "Enable Shift Lock",
        Description = "Forces shift lock to be enabled",
        Callback = function()
            MiscModule.EnableShiftLock()
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

    local TeamCheckToggle = Tabs.Esp:AddToggle("TeamcheckESP", {
        Title = "Team Check",
        Default = ESP.Config.TeamCheck
    })

    local TeamColorToggle = Tabs.Esp:AddToggle("TeamcolorESP", {
        Title = "Team Color",
        Default = ESP.Config.TeamColor
    })

    local ShowTeammatesToggle = Tabs.Esp:AddToggle("ShowteammatesESP", {
        Title = "Show Teammates",
        Default = ESP.Config.ShowTeammates
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
    Options.TeamcheckESP = TeamCheckToggle 
    Options.TeamcolorESP = TeamColorToggle
    Options.ShowteammatesESP = ShowTeammatesToggle
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
