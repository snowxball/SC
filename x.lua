-- Errant x01 | Universal Script (with Kill Aura)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== STATES ======================
local infiniteJump = false
local noclip = false
local killAura = false
local currentSpeed = 16
local isMinimized = false
local showingPlayerList = false

local KILL_AURA_RANGE = 50 -- jarak kill aura

-- ====================== CHARACTER ======================
local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Infinity Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not killAura then return end

    local myHRP = getHRP()
    if not myHRP then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")

            if targetHRP and targetHum and targetHum.Health > 0 then
                local distance = (myHRP.Position - targetHRP.Position).Magnitude
                if distance <= KILL_AURA_RANGE then
                    pcall(function()
                        -- Metode universal yang paling sering bekerja
                        firetouchinterest(myHRP, targetHRP, 0)
                        firetouchinterest(myHRP, targetHRP, 1)
                    end)
                end
            end
        end
    end
end)

-- Speed
local function applySpeed(speed)
    currentSpeed = speed
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = speed
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.WalkSpeed = currentSpeed
    end
end)

-- ====================== GUI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ErrantX01"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 430)
main.Position = UDim2.new(0.5, -150, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 56)
titleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 24)
title.Position = UDim2.new(0, 14, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Errant x01"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 18)
subtitle.Position = UDim2.new(0, 14, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Loading..."
subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextTruncate = Enum.TextTruncate.AtEnd
subtitle.Parent = titleBar

-- Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -66, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Content
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 62)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.BorderSizePixel = 0
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = content

local function updateCanvas()
    task.defer(function()
        content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
end

local function addSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(130, 130, 145)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = content
    updateCanvas()
end

local function addToggle(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    btn.Text = name .. "  :  OFF"
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. "  :  " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(35, 95, 55) or Color3.fromRGB(32, 32, 40)
        callback(state)
    end)
    updateCanvas()
end

local function addButton(text, bgColor, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = bgColor
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    updateCanvas()
    return btn
end

-- ===== UI BUILD =====
addToggle("Infinity Jump", function(v) infiniteJump = v end)
addToggle("No Clip", function(v) noclip = v end)

local speedHolder = Instance.new("Frame")
speedHolder.Size = UDim2.new(1, 0, 0, 34)
speedHolder.BackgroundTransparency = 1
speedHolder.Parent = content

local speedLayout = Instance.new("UIListLayout")
speedLayout.FillDirection = Enum.FillDirection.Horizontal
speedLayout.Padding = UDim.new(0, 6)
speedLayout.Parent = speedHolder

local function createSpeedButton(text, speed)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 84, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = speedHolder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        applySpeed(speed)
        for _, c in ipairs(speedHolder:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(45, 100, 170)
    end)
end

createSpeedButton("OFF", 16)
createSpeedButton("50", 50)
createSpeedButton("100", 100)
updateCanvas()

addToggle("Kill Aura", function(v) killAura = v end)

addButton("Teleport to Player", Color3.fromRGB(45, 75, 140), function()
    showingPlayerList = not showingPlayerList
    playerList.Visible = showingPlayerList
    if showingPlayerList then
        refreshPlayers()
    end
end)

-- ===== PLAYER LIST =====
local playerList = Instance.new("Frame")
playerList.Size = UDim2.new(0, 190, 0, 280)
playerList.Position = UDim2.new(1, 10, 0, 0)
playerList.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
playerList.BorderSizePixel = 0
playerList.Visible = false
playerList.Parent = main
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 8)

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, 0, 0, 32)
plTitle.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
plTitle.Text = "Select Player"
plTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 13
plTitle.Parent = playerList
Instance.new("UICorner", plTitle).CornerRadius = UDim.new(0, 8)

local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(1, -10, 1, -75)
plScroll.Position = UDim2.new(0, 5, 0, 36)
plScroll.BackgroundTransparency = 1
plScroll.ScrollBarThickness = 3
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.Parent = playerList

local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 4)
plLayout.Parent = plScroll

local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(1, -10, 0, 30)
cancelBtn.Position = UDim2.new(0, 5, 1, -36)
cancelBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
cancelBtn.Text = "Cancel"
cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 13
cancelBtn.Parent = playerList
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

cancelBtn.MouseButton1Click:Connect(function()
    showingPlayerList = false
    playerList.Visible = false
end)

function refreshPlayers()
    for _, child in ipairs(plScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = plScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            btn.MouseButton1Click:Connect(function()
                local targetHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = getHRP()
                if targetHRP and myHRP then
                    myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 3)
                end
                showingPlayerList = false
                playerList.Visible = false
            end)
        end
    end
    plScroll.CanvasSize = UDim2.new(0, 0, 0, plLayout.AbsoluteContentSize.Y + 8)
end

-- ====================== DRAG ======================
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
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

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ====================== RESIZE ======================
local resizeBtn = Instance.new("TextButton")
resizeBtn.Size = UDim2.new(0, 14, 0, 14)
resizeBtn.Position = UDim2.new(1, -14, 1, -14)
resizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
resizeBtn.Text = ""
resizeBtn.Parent = main
Instance.new("UICorner", resizeBtn).CornerRadius = UDim.new(0, 3)

local resizing, rStart, rSize
resizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        rStart = input.Position
        rSize = main.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - rStart
        local newX = math.clamp(rSize.X.Offset + delta.X, 260, 450)
        local newY = math.clamp(rSize.Y.Offset + delta.Y, 300, 580)
        main.Size = UDim2.new(0, newX, 0, newY)
    end
end)

-- Minimize
local fullSize = main.Size
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        content.Visible = false
        playerList.Visible = false
        main.Size = UDim2.new(0, main.Size.X.Offset, 0, 56)
        minBtn.Text = "+"
    else
        content.Visible = true
        main.Size = fullSize
        minBtn.Text = "−"
    end
end)

-- Load info
task.spawn(function()
    local name = "Unknown"
    pcall(function()
        name = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    subtitle.Text = "Server: " .. string.sub(tostring(game.JobId), 1, 8) .. "...  |  " .. name
end)

print("Errant x01 loaded!")
