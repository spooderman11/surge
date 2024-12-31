local FlyModule = {}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local flying = false
local speed = 50
local flyConnection = nil

function FlyModule.StartFlying()
    if flying then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    flying = true
    
    flyConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not flying then return end
        
        local flyVector = Vector3.new()
        local camera = workspace.CurrentCamera
        
        -- Movement controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            flyVector = flyVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            flyVector = flyVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            flyVector = flyVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            flyVector = flyVector + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyVector = flyVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyVector = flyVector - Vector3.new(0, 1, 0)
        end
        
        if flyVector.Magnitude > 0 then
            flyVector = flyVector.Unit
            humanoidRootPart.Velocity = flyVector * speed
        else
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function FlyModule.StopFlying()
    if not flying then return end
    
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

function FlyModule.SetSpeed(newSpeed)
    speed = newSpeed
end

function FlyModule.IsFlying()
    return flying
end

return FlyModule
