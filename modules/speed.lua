local SpeedModule = {}

local speed = 10
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local moveDirections = {
    W = false,
    A = false,
    S = false,
    D = false,
}

local function moveCharacterSmoothly(deltaTime)
    local moveVector = Vector3.new()
    local camera = workspace.CurrentCamera

    if moveDirections.W then
        moveVector = moveVector + camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if moveDirections.S then
        moveVector = moveVector - camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if moveDirections.A then
        moveVector = moveVector - camera.CFrame.RightVector
    end
    if moveDirections.D then
        moveVector = moveVector + camera.CFrame.RightVector
    end

    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit
        humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveVector * speed * deltaTime
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.W then
        moveDirections.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirections.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirections.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirections.D = true
    end
end)

userInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.W then
        moveDirections.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        moveDirections.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        moveDirections.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        moveDirections.D = false
    end
end)

runService.RenderStepped:Connect(moveCharacterSmoothly)

function SpeedModule.SetSpeed(newSpeed)
    speed = newSpeed
end

return SpeedModule
