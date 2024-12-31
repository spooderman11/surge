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

return Utils
