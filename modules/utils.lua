local Utils = {}

function Utils.CalculateBox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local size = character:GetExtentsSize()
    local position = hrp.Position
    
    local topRight = game.Workspace.CurrentCamera:WorldToViewportPoint(position + Vector3.new(size.X/2, size.Y/2, 0))
    local bottomLeft = game.Workspace.CurrentCamera:WorldToViewportPoint(position - Vector3.new(size.X/2, size.Y/2, 0))
    
    return {
        TopRight = topRight,
        BottomLeft = bottomLeft
    }
end

function Utils.GetPlayers()
    local players = game.Players:GetPlayers()
    local result = {}
    
    for i, player in ipairs(players) do
        table.insert(result, player)
    end
    
    return result
end

function Utils.GetPlayerFromName(name)
    local players = game.Players:GetPlayers()
    
    for i, player in ipairs(players) do
        if player.Name == name then
            return player
        end
    end
    
    return nil
end

function Utils.GetPlayerFromUserId(userId)
    local players = game.Players:GetPlayers()
    
    for i, player in ipairs(players) do
        if player.UserId == userId then
            return player
        end
    end
    
    return nil
end

function Utils.GetPlayerFromCharacter(character)
    local players = game.Players:GetPlayers()
    
    for i, player in ipairs(players) do
        if player.Character == character then
            return player
        end
    end
    
    return nil
end

function Utils.AntiCrack(func)
    local ui = Instance.new("ScreenGui")
    ui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = ui

    local text = Instance.new("TextLabel")
    text.Text = "DO NOT TRY TO CRACK SURGE. JUST BUY PREMIUM AND SUPPORT THE DEVS?? OR USE FREE VERSION"
    text.Size = UDim2.new(0, 500, 0, 50)
    text.Position = UDim2.new(0.5, -250, 0.5, -25)
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Parent = frame

    wait(0.1)

    while true do end
end

return Utils
