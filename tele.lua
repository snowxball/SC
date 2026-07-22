-- ERRANT TELEPORT GUI
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama
if CoreGui:FindFirstChild("ERRANT_TELEPORT_GUI") then
    CoreGui.ERRANT_TELEPORT_GUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ERRANT_TELEPORT_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 400)
main.Position = UDim2.new(0.5, -160, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "ERRANT TELEPORT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local titleCorner = Instance.new("UICorner", title)
titleCorner.CornerRadius = UDim.new(0, 12)

-- Player List Frame
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1, -20, 1, -100)
listFrame.Position = UDim2.new(0, 10, 0, 60)
listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 6

local listCorner = Instance.new("UICorner", listFrame)
listCorner.CornerRadius = UDim.new(0, 8)

local uiListLayout = Instance.new("UIListLayout", listFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

-- Refresh Button
local refreshBtn = Instance.new("TextButton", main)
refreshBtn.Size = UDim2.new(0.45, 0, 0, 35)
refreshBtn.Position = UDim2.new(0.05, 0, 1, -45)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
refreshBtn.Text = "Refresh List"
refreshBtn.TextColor3 = Color3.new(1,1,1)
refreshBtn.TextScaled = true
refreshBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)

-- Close Button
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0.45, 0, 0, 35)
closeBtn.Position = UDim2.new(0.5, 0, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Fungsi Teleport
local function teleportTo(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            print("Teleported to " .. plr.Name)
        end
    end
end

-- Buat tombol player
local function refreshPlayerList()
    -- Hapus tombol lama
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = "👤 " .. plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamSemibold
            btn.Parent = listFrame
            
            local btnCorner = Instance.new("UICorner", btn)
            btnCorner.CornerRadius = UDim.new(0, 8)
            
            btn.MouseButton1Click:Connect(function()
                teleportTo(plr)
            end)
        end
    end
end

-- Event
refreshBtn.MouseButton1Click:Connect(refreshPlayerList)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Refresh otomatis saat player join/leave
Players.PlayerAdded:Connect(function()
    task.wait(1)
    refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    refreshPlayerList()
end)

-- Refresh pertama kali
task.wait(1)
refreshPlayerList()

print("ERRANT Teleport GUI Loaded")
