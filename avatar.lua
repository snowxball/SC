--[[
    Errant x Avatar Changer
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== FUNGSI UTAMA ======================

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Copy Avatar dari player lain (Visual Only)
local function copyAvatar(targetPlayer)
    local targetChar = targetPlayer.Character
    if not targetChar then return end

    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    local myHum = getHumanoid()
    if not targetHum or not myHum then return end

    local success, description = pcall(function()
        return targetHum:GetAppliedDescription()
    end)

    if success and description then
        pcall(function()
            myHum:ApplyDescription(description)
        end)
        print("Berhasil copy avatar dari:", targetPlayer.Name)
    else
        warn("Gagal mengambil description dari", targetPlayer.Name)
    end
end

-- Tambah Item menggunakan Asset ID
local function addItemById(assetId)
    assetId = tonumber(assetId)
    if not assetId then
        warn("Asset ID tidak valid")
        return
    end

    local char = getCharacter()
    local hum = getHumanoid()
    if not char or not hum then return end

    local success, model = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)

    if not success or not model then
        warn("Gagal load asset ID:", assetId)
        return
    end

    -- Cari Accessory / Clothing di dalam model
    local item = model:FindFirstChildOfClass("Accessory")
        or model:FindFirstChildOfClass("Shirt")
        or model:FindFirstChildOfClass("Pants")
        or model:FindFirstChildOfClass("ShirtGraphic")
        or model:FindFirstChildWhichIsA("Accessory")
        or model:GetChildren()[1]

    if item then
        item.Parent = char
        print("Berhasil menambahkan item ID:", assetId)
    else
        -- Coba terapkan lewat HumanoidDescription
        pcall(function()
            local desc = hum:GetAppliedDescription()
            -- Kita coba tambahkan sebagai accessory
            local newDesc = desc:Clone()
            -- Karena visual only, kita langsung parent saja
        end)
        warn("Item tidak dikenali sebagai Accessory/Clothing")
    end

    model:Destroy()
end

-- ====================== GUI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarChangerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 380)
main.Position = UDim2.new(0.5, -140, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Avatar Changer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -31, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 42)
content.BackgroundTransparency = 1
content.Parent = main

-- Section: Copy Avatar
local copyLabel = Instance.new("TextLabel")
copyLabel.Size = UDim2.new(1, 0, 0, 20)
copyLabel.BackgroundTransparency = 1
copyLabel.Text = "Copy Avatar dari Player"
copyLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
copyLabel.Font = Enum.Font.GothamBold
copyLabel.TextSize = 12
copyLabel.TextXAlignment = Enum.TextXAlignment.Left
copyLabel.Parent = content

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, 0, 0, 160)
playerScroll.Position = UDim2.new(0, 0, 0, 24)
playerScroll.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = content
Instance.new("UICorner", playerScroll).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = playerScroll

local function refreshPlayerList()
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -8, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = player.Name
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = playerScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

            btn.MouseButton1Click:Connect(function()
                copyAvatar(player)
            end)
        end
    end

    playerScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end

refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- Section: Add Item by ID
local addLabel = Instance.new("TextLabel")
addLabel.Size = UDim2.new(1, 0, 0, 20)
addLabel.Position = UDim2.new(0, 0, 0, 200)
addLabel.BackgroundTransparency = 1
addLabel.Text = "Add Item (Asset ID)"
addLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
addLabel.Font = Enum.Font.GothamBold
addLabel.TextSize = 12
addLabel.TextXAlignment = Enum.TextXAlignment.Left
addLabel.Parent = content

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(1, 0, 0, 32)
idBox.Position = UDim2.new(0, 0, 0, 224)
idBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
idBox.PlaceholderText = "Masukkan Asset ID..."
idBox.Text = ""
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 13
idBox.ClearTextOnFocus = false
idBox.Parent = content
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, 0, 0, 32)
addBtn.Position = UDim2.new(0, 0, 0, 264)
addBtn.BackgroundColor3 = Color3.fromRGB(45, 100, 180)
addBtn.Text = "Add Item"
addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addBtn.Font = Enum.Font.GothamBold
addBtn.TextSize = 13
addBtn.Parent = content
Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)

addBtn.MouseButton1Click:Connect(function()
    local id = idBox.Text
    if id and id ~= "" then
        addItemById(id)
        idBox.Text = ""
    end
end)

-- Refresh Button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 28)
refreshBtn.Position = UDim2.new(0, 0, 0, 308)
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
refreshBtn.Text = "Refresh Player List"
refreshBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.TextSize = 12
refreshBtn.Parent = content
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

refreshBtn.MouseButton1Click:Connect(refreshPlayerList)

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

print("Avatar Changer loaded!")
