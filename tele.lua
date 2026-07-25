-- RBLX-Teleport GUI by Errant
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("RBLX_Teleport_GUI") then
    CoreGui.RBLX_Teleport_GUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RBLX_Teleport_GUI"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- ==================== MAIN GUI (Ukuran Kecil) ====================
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 260, 0, 220)   -- Diperkecil jadi setengah
main.Position = UDim2.new(0.5, -130, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Title Bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -55, 0, 28)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "RBLX-Teleport"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", titleBar)
subtitle.Size = UDim2.new(1, -55, 0, 15)
subtitle.Position = UDim2.new(0, 15, 0, 28)  -- Jarak lebih baik
subtitle.BackgroundTransparency = 1
subtitle.Text = "By: Errant"
subtitle.TextColor3 = Color3.fromRGB(160, 160, 160)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -32, 0, 10)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -45)
content.Position = UDim2.new(0, 0, 0, 45)
content.BackgroundTransparency = 1

local function createButton(text, y, color)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local toPlayerBtn = createButton("To Player", 15, Color3.fromRGB(0, 90, 180))
local customBtn   = createButton("Custom Game Server", 60, Color3.fromRGB(0, 90, 180))
local rejoinBtn   = createButton("Rejoin This Server", 105, Color3.fromRGB(0, 90, 180))

-- ==================== MINIMIZE WITH ANIMATION ====================
local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 260, 0, 45) or UDim2.new(0, 260, 0, 220)
    
    local tween = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = targetSize})
    tween:Play()
    
    content.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "–"
end)

-- ==================== SUB GUI (To Player & Custom) ====================
local function createSubGUI(titleText)
    local sub = Instance.new("Frame", screenGui)
    sub.Size = UDim2.new(0, 260, 0, 280)
    sub.Position = UDim2.new(0.5, -130, main.Position.Y.Scale + 0.2, main.Position.Y.Offset + 50) -- Di bawah main GUI
    sub.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", sub).CornerRadius = UDim.new(0, 12)

    local subTitle = Instance.new("TextLabel", sub)
    subTitle.Size = UDim2.new(1,0,0,45)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = titleText
    subTitle.TextColor3 = Color3.new(1,1,1)
    subTitle.TextScaled = true
    subTitle.Font = Enum.Font.GothamBold

    local closeBtn = Instance.new("TextButton", sub)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -35, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold

    closeBtn.MouseButton1Click:Connect(function()
        sub:Destroy()
    end)

    return sub
end

-- To Player
toPlayerBtn.MouseButton1Click:Connect(function()
    local listGui = createSubGUI("Teleport to Player")
    
    local scroll = Instance.new("ScrollingFrame", listGui)
    scroll.Size = UDim2.new(1,-20,1,-65)
    scroll.Position = UDim2.new(0,10,0,55)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,-10,0,40)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamSemibold
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,4,0)
                end
                listGui:Destroy()
            end)
        end
    end
end)

-- Custom Game Server
customBtn.MouseButton1Click:Connect(function()
    local customGui = createSubGUI("Custom Game Server")

    -- Game ID
    local gLabel = Instance.new("TextLabel", customGui)
    gLabel.Size = UDim2.new(0.9,0,0,20)
    gLabel.Position = UDim2.new(0.05,0,0,65)
    gLabel.BackgroundTransparency = 1
    gLabel.Text = "Game ID"
    gLabel.TextColor3 = Color3.new(1,1,1)
    gLabel.Font = Enum.Font.Gotham

    local gameIdBox = Instance.new("TextBox", customGui)
    gameIdBox.Size = UDim2.new(0.9,0,0,35)
    gameIdBox.Position = UDim2.new(0.05,0,0,88)
    gameIdBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    gameIdBox.PlaceholderText = "Masukkan Game ID"
    gameIdBox.TextColor3 = Color3.new(1,1,1)
    gameIdBox.TextScaled = true
    Instance.new("UICorner", gameIdBox).CornerRadius = UDim.new(0, 8)

    -- Server ID
    local sLabel = Instance.new("TextLabel", customGui)
    sLabel.Size = UDim2.new(0.9,0,0,20)
    sLabel.Position = UDim2.new(0.05,0,0,135)
    sLabel.BackgroundTransparency = 1
    sLabel.Text = "Server ID"
    sLabel.TextColor3 = Color3.new(1,1,1)
    sLabel.Font = Enum.Font.Gotham

    local serverIdBox = Instance.new("TextBox", customGui)
    serverIdBox.Size = UDim2.new(0.9,0,0,35)
    serverIdBox.Position = UDim2.new(0.05,0,0,158)
    serverIdBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
    serverIdBox.PlaceholderText = "Masukkan Server ID"
    serverIdBox.TextColor3 = Color3.new(1,1,1)
    serverIdBox.TextScaled = true
    Instance.new("UICorner", serverIdBox).CornerRadius = UDim.new(0, 8)

    local tpBtn = Instance.new("TextButton", customGui)
    tpBtn.Size = UDim2.new(0.9,0,0,45)
    tpBtn.Position = UDim2.new(0.05,0,0,205)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    tpBtn.Text = "TELEPORT SEKARANG"
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.TextScaled = true
    tpBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 10)

    tpBtn.MouseButton1Click:Connect(function()
        local gameId = tonumber(gameIdBox.Text)
        local serverId = serverIdBox.Text
        if gameId and serverId and serverId ~= "" then
            TeleportService:TeleportToPlaceInstance(gameId, serverId, LocalPlayer)
        end
    end)
end)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

print("RBLX-Teleport GUI Loaded")
