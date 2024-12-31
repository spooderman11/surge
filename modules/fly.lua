local FlyModule = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local flying = false
local speed = 50
local flyDirection = Vector3.new()

local function startFlying()
    flying = true
    humanoidRootPart.Anchored = true
end

local function stopFlying()
    flying = false
    humanoidRootPart.Anchored = false
end

local function updateFlyDirection()
    flyDirection = Vector3.new()
    if userInputService:IsKeyDown(Enum.KeyCode.W) then
        flyDirection = flyDirection + humanoidRootPart.CFrame.LookVector
    end
    if userInputService:IsKeyDown(Enum.KeyCode.S) then
        flyDirection = flyDirection - humanoidRootPart.CFrame.LookVector
    end
    if userInputService:IsKeyDown(Enum.KeyCode.A) then
        flyDirection = flyDirection - humanoidRootPart.CFrame.RightVector
    end
    if userInputService:IsKeyDown(Enum.KeyCode.D) then
        flyDirection = flyDirection + humanoidRootPart.CFrame.RightVector
    end
    if userInputService:IsKeyDown(Enum.KeyCode.Space) then
        flyDirection = flyDirection + Vector3.new(0, 1, 0)
    end
    if userInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        flyDirection = flyDirection - Vector3.new(0, 1, 0)
    end
end

local function flyStep(deltaTime)
    if flying then
        updateFlyDirection()
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + flyDirection.Unit * speed * deltaTime
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end
end)

runService.RenderStepped:Connect(flyStep)

function FlyModule.SetSpeed(newSpeed)
    speed = newSpeed
end

return FlyModule
