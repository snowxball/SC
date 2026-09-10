--[[
    Free Cam + GUI On/Off + Tombol Gerak di GUI
]]

local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local rotating = false
local freeCamEnabled = false
local renderConnection = nil
local originalCameraType = cam.CameraType

local speed = 0.6
local sens = 0.3

-- Status tombol gerak
local moveForward = false
local moveBackward = false
local moveLeft = false
local moveRight = false

-- ====================== FREE CAM LOGIC ======================
local function renderStepped()
    if not freeCamEnabled then return end

    -- Rotasi kamera (klik kanan)
    if rotating then
        local delta = UIS:GetMouseDelta()
        local cf = cam.CFrame
        local yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
        local newAmount = math.deg(yAngle) + delta.Y

        if newAmount > 65 or newAmount < -65 then
            if not (yAngle < 0 and delta.Y < 0) and not (yAngle > 0 and delta.Y > 0) then
                delta = Vector2.new(delta.X, 0)
            end
        end

        cf *= CFrame.Angles(-math.rad(delta.Y), 0, 0)
        cf = CFrame.Angles(0, -math.rad(delta.X), 0) * (cf - cf.Position) + cf.Position
        cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)

        if delta ~= Vector2.new(0, 0) then
            cam.CFrame = cam.CFrame:Lerp(cf, sens)
        end
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end

    -- Gerakan dari tombol GUI
    if moveForward then
        cam.CFrame *= CFrame.new(0, 0, -speed)
    end
    if moveBackward then
        cam.CFrame *= CFrame.new(0, 0, speed)
    end
    if moveLeft then
        cam.CFrame *= CFrame.new(-speed, 0, 0)
    end
    if moveRight then
        cam.CFrame *= CFrame.new(speed, 0, 0)
    end
end

-- Input untuk rotasi (klik kanan)
UIS.InputBegan:Connect(function(Input)
    if not freeCamEnabled then return end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = true
    end
end)

UIS.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = false
    end
end)

-- ====================== TOGGLE FUNCTION ======================
local function setFreeCam(state)
    freeCamEnabled = state

    if state then
        originalCameraType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable
        if not renderConnection then
            renderConnection = RS.RenderStepped:Connect(renderStepped)
        end
    else
        cam.CameraType = Enum.CameraType.Custom
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        rotating = false
        moveForward = false
        moveBackward = false
        moveLeft = false
        moveRight = false
        if renderConnection then
            renderConnection:Disconnect()
            renderConnection = nil
        end
    end
end

-- ====================== GUI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FreeCamGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 200, 0, 210)
main.Position = UDim2.new(0, 20, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Free Cam"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0, 28)
toggleBtn.Position = UDim2.new(0.075, 0, 0, 32)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = main
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 7)

toggleBtn.MouseButton1Click:Connect(function()
    local newState = not freeCamEnabled
    setFreeCam(newState)

    if newState then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 70)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Movement Buttons Container
local moveFrame = Instance.new("Frame")
moveFrame.Size = UDim2.new(0, 140, 0, 110)
moveFrame.Position = UDim2.new(0.5, -70, 0, 75)
moveFrame.BackgroundTransparency = 1
moveFrame.Parent = main

-- Helper untuk membuat tombol gerak
local function createMoveButton(text, position, onPress, onRelease)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 42)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = moveFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Down:Connect(function()
        if freeCamEnabled then
            onPress()
            btn.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
        end
    end)

    btn.MouseButton1Up:Connect(function()
        onRelease()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)

    -- Support touch
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onRelease()
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end
    end)

    return btn
end

-- Tombol Maju (I)
createMoveButton("▲", UDim2.new(0.5, -21, 0, 0), function()
    moveForward = true
end, function()
    moveForward = false
end)

-- Tombol Kiri (J)
createMoveButton("◀", UDim2.new(0, 0, 0, 48), function()
    moveLeft = true
end, function()
    moveLeft = false
end)

-- Tombol Mundur (K)
createMoveButton("▼", UDim2.new(0.5, -21, 0, 48), function()
    moveBackward = true
end, function()
    moveBackward = false
end)

-- Tombol Kanan (L)
createMoveButton("▶", UDim2.new(1, -42, 0, 48), function()
    moveRight = true
end, function()
    moveRight = false
end)

-- Drag GUI
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Free Cam + GUI Buttons loaded!")
