-- =============================================
-- DABUX CLUSTER + TELEPORT PLAYER | Errant's Script Test
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local root = player.Character and player.Character:WaitForChild("HumanoidRootPart")

local currentClusterIndex = 1

-- Hapus GUI lama
if CoreGui:FindFirstChild("DabuxMiniGUI") then
    CoreGui.DabuxMiniGUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DabuxMiniGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 220)   -- sedikit diperbesar
main.Position = UDim2.new(0.5, -140, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 1
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "-Errant's-"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.TextScaled = true
status.Font = Enum.Font.Gotham

-- Tombol Cluster
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(0.9, 0, 0, 40)
startBtn.Position = UDim2.new(0.05, 0, 0, 80)
startBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 112)
startBtn.Text = "DABUX"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)

local nextBtn = Instance.new("TextButton", main)
nextBtn.Size = UDim2.new(0.9, 0, 0, 40)
nextBtn.Position = UDim2.new(0.05, 0, 0, 125)
nextBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 112)
nextBtn.Text = "NEXT"
nextBtn.TextColor3 = Color3.new(1,1,1)
nextBtn.TextScaled = true
nextBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 8)

-- Tombol Teleport ke Player
local tpPlayerBtn = Instance.new("TextButton", main)
tpPlayerBtn.Size = UDim2.new(0.9, 0, 0, 40)
tpPlayerBtn.Position = UDim2.new(0.05, 0, 0, 170)
tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 112)
tpPlayerBtn.Text = "TO PLAYER"
tpPlayerBtn.TextColor3 = Color3.new(1,1,1)
tpPlayerBtn.TextScaled = true
tpPlayerBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", tpPlayerBtn).CornerRadius = UDim.new(0, 8)

-- ==================== FUNCTION ====================
local function getRankedClusters()
    local allDabux = {}
    local clusters = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Dabux" then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then 
                table.insert(allDabux, part) 
            end
        end
    end

    for _, primary in pairs(allDabux) do
        local neighbors = 0
        for _, secondary in pairs(allDabux) do
            if (primary.Position - secondary.Position).Magnitude <= 50 then
                neighbors = neighbors + 1
            end
        end
        table.insert(clusters, {cf = primary.CFrame, count = neighbors})
    end

    table.sort(clusters, function(a, b) return a.count > b.count end)
    return clusters
end

local function teleportToCluster(index)
    local clusters = getRankedClusters()
    if #clusters >= index then
        local cluster = clusters[index]
        if root then
            root.CFrame = cluster.cf * CFrame.new(0, 4, 0)
            status.Text = "Cluster #" .. index .. " (" .. cluster.count .. ")"
            status.TextColor3 = Color3.fromRGB(0, 255, 120)
        end
    else
        status.Text = "No more clusters"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

local function teleportToPlayer(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        if root then
            root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
            status.Text = "Teleported to " .. plr.Name
        end
    end
end

-- Button Functions
startBtn.MouseButton1Click:Connect(function()
    currentClusterIndex = 1
    teleportToCluster(currentClusterIndex)
end)

nextBtn.MouseButton1Click:Connect(function()
    currentClusterIndex += 1
    teleportToCluster(currentClusterIndex)
end)

-- Teleport to Player (membuka list player)
tpPlayerBtn.MouseButton1Click:Connect(function()
    -- Buat frame list player sementara
    local listFrame = Instance.new("Frame", main)
    listFrame.Size = UDim2.new(0.95, 0, 0.7, 0)
    listFrame.Position = UDim2.new(0.025, 0, 0.15, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
    
    local scrolling = Instance.new("ScrollingFrame", listFrame)
    scrolling.Size = UDim2.new(1, -10, 1, -10)
    scrolling.Position = UDim2.new(0, 5, 0, 5)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 6
    
    local layout = Instance.new("UIListLayout", scrolling)
    layout.Padding = UDim.new(0, 5)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton", scrolling)
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                teleportToPlayer(plr)
                listFrame:Destroy()
            end)
        end
    end
end)

print("Dabux Gui Loaded")
