-- =============================================
-- DABUX GUI | Errant's
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local root = player.Character and player.Character:WaitForChild("HumanoidRootPart")

local currentClusterIndex = 1
local noclipConn = nil

if CoreGui:FindFirstChild("DabuxProGUI") then
    CoreGui.DabuxProGUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DabuxProGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "-Errant's-"
title.TextColor3 = Color3.fromRGB(220, 20, 60)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.TextScaled = true
status.Font = Enum.Font.Gotham

local function createButton(text, posY, color)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.9, 0, 0, 36)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local startBtn   = createButton("DABUX", 80, Color3.fromRGB(25, 25, 112))
local nextBtn    = createButton("NEXT", 122, Color3.fromRGB(25, 25, 112))
local godBtn     = createButton("GOD MODE : OFF", 165, Color3.fromRGB(139, 0, 0))
local noclipBtn  = createButton("NOCLIP : OFF", 207, Color3.fromRGB(139, 0, 0))
local tpPlayerBtn = createButton("TELEPORT TO PLAYER", 249, Color3.fromRGB(25, 25, 112))

-- Speed Mode
local runBtn   = createButton("RUN", 290, Color3.fromRGB(72, 61, 139))
local flashBtn = createButton("FLASH SPEED", 332, Color3.fromRGB(72, 61, 139))

-- ==================== FUNCTIONS ====================
local function getRankedClusters()
    local allDabux, clusters = {}, {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Dabux" then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then table.insert(allDabux, part) end
        end
    end

    for _, primary in pairs(allDabux) do
        local count = 0
        for _, secondary in pairs(allDabux) do
            if (primary.Position - secondary.Position).Magnitude <= 50 then count += 1 end
        end
        table.insert(clusters, {cf = primary.CFrame, count = count})
    end

    table.sort(clusters, function(a,b) return a.count > b.count end)
    return clusters
end

local function teleportToCluster(index)
    local clusters = getRankedClusters()
    if #clusters >= index and root then
        root.CFrame = clusters[index].cf * CFrame.new(0, 4, 0)
        status.Text = "Cluster #" .. index
    end
end

local function teleportToPlayer(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and root then
        root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
        status.Text = "To " .. plr.Name
    end
end

-- Button Events
startBtn.MouseButton1Click:Connect(function()
    currentClusterIndex = 1
    teleportToCluster(currentClusterIndex)
end)

nextBtn.MouseButton1Click:Connect(function()
    currentClusterIndex += 1
    teleportToCluster(currentClusterIndex)
end)

-- God Mode
local godConn
godBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if godConn then godConn:Disconnect() end
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        godConn = hum.HealthChanged:Connect(function() hum.Health = hum.MaxHealth end)
        godBtn.Text = "GOD MODE : ON"
        godBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

-- NoClip
noclipBtn.MouseButton1Click:Connect(function()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        noclipBtn.Text = "NOCLIP : OFF"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
    else
        noclipConn = RunService.Stepped:Connect(function()
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
        noclipBtn.Text = "NOCLIP : ON"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end)

-- Speed
runBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 45 end
    status.Text = "Run Mode"
end)

flashBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 100 end
    status.Text = "Flash Mode"
end)

-- Teleport to Player
tpPlayerBtn.MouseButton1Click:Connect(function()
    local listFrame = Instance.new("Frame", main)
    listFrame.Size = UDim2.new(0.95, 0, 0.6, 0)
    listFrame.Position = UDim2.new(0.025, 0, 0.25, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

    local scrolling = Instance.new("ScrollingFrame", listFrame)
    scrolling.Size = UDim2.new(1,-10,1,-10)
    scrolling.Position = UDim2.new(0,5,0,5)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scrolling)
    layout.Padding = UDim.new(0, 5)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton", scrolling)
            btn.Size = UDim2.new(1,-10,0,32)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.GothamSemibold
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                teleportToPlayer(plr)
                listFrame:Destroy()
            end)
        end
    end
end)

print("Dabux GUI Full Loaded")
