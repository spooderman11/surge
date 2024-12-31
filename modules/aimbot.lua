local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Aimbot = {
    Settings = {
        Enabled = false,
        Mode = "Tween",
        TargetMode = "Closest To Mouse",
        Prediction = false,
        PredictionX = 1,
        PredictionY = 1,
        Smoothness = false,
        SmoothnessValue = 0.5,
        DeathUnlock = true,
        TargetLock = true
    },
    Target = nil,
    UpdateConnection = nil
}

function Aimbot.predictPosition(target)
    if not target or not target.Character then return nil end
    
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local velocity = hrp.Velocity
    local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / 1000
    
    return hrp.Position + Vector3.new(
        velocity.X * Aimbot.Settings.PredictionX,
        velocity.Y * Aimbot.Settings.PredictionY,
        velocity.Z * Aimbot.Settings.PredictionX
    ) * timeToHit
end

function Aimbot.smoothLerp(current, target, smoothness)
    local smoothness = math.clamp(smoothness, 0, 1)
    return current:Lerp(target, 1 - smoothness)
end

function Aimbot.getClosestPlayer()
    if Aimbot.Target and Aimbot.Settings.TargetLock then
        if Aimbot.Target.Character and 
           Aimbot.Target.Character:FindFirstChild("HumanoidRootPart") and 
           Aimbot.Target.Character:FindFirstChild("Humanoid") and 
           Aimbot.Target.Character.Humanoid.Health > 0 then
            return Aimbot.Target
        else
            Aimbot.Target = nil
        end
    end

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and 
           player.Character and 
           player.Character:FindFirstChild("HumanoidRootPart") and 
           player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 then
            
            if Aimbot.Settings.TargetMode == "Closest To Mouse" then
                local pos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).magnitude
                
                if magnitude < shortestDistance then
                    closestPlayer = player
                    shortestDistance = magnitude
                end
            elseif Aimbot.Settings.TargetMode == "Closest To Player" then
                local magnitude = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if magnitude < shortestDistance then
                    closestPlayer = player
                    shortestDistance = magnitude
                end
            end
        end
    end
    
    if closestPlayer and Aimbot.Settings.TargetLock then
        Aimbot.Target = closestPlayer
    end

    if closestPlayer and Aimbot.Settings.DeathUnlock then
        local humanoid = closestPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            return nil
        end
    end
    
    return closestPlayer
end

function Aimbot.Update()
    if not Aimbot.Settings.Enabled then return end
    
    local target = Aimbot.getClosestPlayer()
    if target and target.Character then
        local targetPos = target.Character.HumanoidRootPart.Position
        
        if Aimbot.Settings.Prediction then
            local predictedPos = Aimbot.predictPosition(target)
            if predictedPos then
                targetPos = predictedPos
            end
        end
        
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        
        if Aimbot.Settings.Smoothness then
            targetCFrame = Aimbot.smoothLerp(Camera.CFrame, targetCFrame, Aimbot.Settings.SmoothnessValue)
        end
        
        if Aimbot.Settings.Mode == "Tween" then
            local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = TweenService:Create(Camera, tweenInfo, {
                CFrame = targetCFrame
            })
            tween:Play()
        elseif Aimbot.Settings.Mode == "Mouse" then
            local targetScreenPos = Camera:WorldToViewportPoint(targetPos)
            mousemoveabs(targetScreenPos.X, targetScreenPos.Y)
        elseif Aimbot.Settings.Mode == "Camera" then
            Camera.CFrame = targetCFrame
        end
    end
end

function Aimbot.Toggle(enabled)
    Aimbot.Settings.Enabled = enabled
    if enabled then
        Aimbot.UpdateConnection = RunService.RenderStepped:Connect(function()
            Aimbot.Update()
        end)
    else
        if Aimbot.UpdateConnection then
            Aimbot.UpdateConnection:Disconnect()
        end
        Aimbot.Target = nil
    end
end

return Aimbot
