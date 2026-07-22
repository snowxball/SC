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
main.Size = UDim2.new(0, 260, 0, 180)
main.Position = UDim2.new(0.5, -130, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Errant - Farm DABUX"
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

-- Tombol Start Farm
local startBtn = Instance.new("TextButton", main)
startBtn.Size = UDim2.new(0.9, 0, 0, 45)
startBtn.Position = UDim2.new(0.05, 0, 0, 80)
startBtn.BackgroundColor3 = Color3.fromRGB(72, 61, 139)
startBtn.Text = "TELEPORT TO BEST CLUSTER"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.TextScaled = true
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)

-- Tombol Next Cluster
local nextBtn = Instance.new("TextButton", main)
nextBtn.Size = UDim2.new(0.9, 0, 0, 40)
nextBtn.Position = UDim2.new(0.05, 0, 0, 130)
nextBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 112)
nextBtn.Text = "NEXT CLUSTER"
nextBtn.TextColor3 = Color3.new(1,1,1)
nextBtn.TextScaled = true
nextBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0, 8)

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
            status.Text = "Cluster #" .. index .. " (" .. cluster.count .. " Dabux)"
            status.TextColor3 = Color3.fromRGB(0, 255, 120)
            print("Teleported to Cluster #" .. index)
        end
    else
        status.Text = "No more clusters"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

-- Tombol Teleport ke Cluster Terbaik
startBtn.MouseButton1Click:Connect(function()
    currentClusterIndex = 1
    teleportToCluster(currentClusterIndex)
end)

-- Tombol Next Cluster
nextBtn.MouseButton1Click:Connect(function()
    currentClusterIndex = currentClusterIndex + 1
    teleportToCluster(currentClusterIndex)
end)

print("Dabux Mini GUI Loaded")
print("Gunakan tombol 'NEXT CLUSTER' untuk pindah")
