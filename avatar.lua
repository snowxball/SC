--[[
    Errant x Avatar Changer (Visual Only) - Fixed Version
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== FUNGSI UTAMA ======================

local function getCharacter()
    return LocalPlayer.Character
end

local function clearAvatar(character)
    if not character then return end

    -- Hapus semua accessory
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") then
            item:Destroy()
        end
    end

    -- Hapus clothing
    local shirt = character:FindFirstChildOfClass("Shirt")
    local pants = character:FindFirstChildOfClass("Pants")
    local tshirt = character:FindFirstChildOfClass("ShirtGraphic")
    if shirt then shirt:Destroy() end
    if pants then pants:Destroy() end
    if tshirt then tshirt:Destroy() end
end

-- Copy Avatar secara manual (lebih reliable)
local function copyAvatar(targetPlayer)
    local myChar = getCharacter()
    local targetChar = targetPlayer.Character

    if not myChar or not targetChar then
        warn("Character tidak ditemukan")
        return
    end

    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
    if not myHum or not targetHum then return end

    -- 1. Clear dulu
    clearAvatar(myChar)

    -- 2. Copy BodyColors
    local targetColors = targetChar:FindFirstChildOfClass("BodyColors")
    if targetColors then
        local oldColors = myChar:FindFirstChildOfClass("BodyColors")
        if oldColors then oldColors:Destroy() end
        targetColors:Clone().Parent = myChar
    end

    -- 3. Copy Shirt
    local targetShirt = targetChar:FindFirstChildOfClass("Shirt")
    if targetShirt then
        targetShirt:Clone().Parent = myChar
    end

    -- 4. Copy Pants
    local targetPants = targetChar:FindFirstChildOfClass("Pants")
    if targetPants then
        targetPants:Clone().Parent = myChar
    end

    -- 5. Copy T-Shirt
    local targetTShirt = targetChar:FindFirstChildOfClass("ShirtGraphic")
    if targetTShirt then
        targetTShirt:Clone().Parent = myChar
    end

    -- 6. Copy semua Accessory
    for _, item in ipairs(targetChar:GetChildren()) do
        if item:IsA("Accessory") or item:IsA("Hat") then
            local clone = item:Clone()
            clone.Parent = myChar

            -- Pastikan Accessory sudah terpasang dengan benar
            pcall(function()
                myHum:AddAccessory(clone)
            end)
        end
    end

    print("Berhasil copy avatar dari:", targetPlayer.Name)
end

-- Tambah Item by Asset ID
local function addItemById(assetId)
    assetId = tonumber(assetId)
    if not assetId then
        warn("Asset ID tidak valid")
        return
    end

    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then return end

    local success, asset = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)

    if success and asset then
        local item = asset:FindFirstChildOfClass("Accessory")
            or asset:FindFirstChildOfClass("Hat")
            or asset:FindFirstChildOfClass("Shirt")
            or asset:FindFirstChildOfClass("Pants")
            or asset:FindFirstChildOfClass("ShirtGraphic")
            or asset:GetChildren()[1]

        if item then
            local clone = item:Clone()
            clone.Parent = char

            if clone:IsA("Accessory") or clone:IsA("Hat") then
                pcall(function()
                    hum:AddAccessory(clone)
                end)
            end

            print("Berhasil menambahkan item:", assetId)
        else
            warn("Tidak menemukan item di dalam asset")
        end

        asset:Destroy()
    else
        warn("Gagal load Asset ID:", assetId)
    end
end

-- ====================== GUI ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AvatarChangerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 390)
main.Position = UDim2.new(0.5, -140, 0.5, -195)
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

-- Copy Section
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
playerScroll.Size = UDim2.new(1, 0, 0, 165)
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

-- Add Item Section
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
    if idBox.Text ~= "" then
        addItemById(idBox.Text)
        idBox.Text = ""
    end
end)

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

-- Drag
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

print("Avatar Changer Fixed loaded!")
