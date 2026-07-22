-- =============================================
-- DABUX CLUSTER FARM + GUI
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local AUTO_FARM = false
local connection = nil

-- Hapus GUI lama
if CoreGui:FindFirstChild("DabuxClusterGUI") then
    CoreGui.DabuxClusterGUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DabuxClusterGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 340, 0, 260)
main.Position = UDim2.new(0.5, -170, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "DABUX CLUSTER FARM"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0, 10, 0, 55)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.TextScaled = true
status.Font = Enum.Font.Gotham

-- Toggle Button
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 55)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
toggleBtn.Text = "START FARM"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

-- Restart Button
local restartBtn = Instance.new("TextButton", main)
restartBtn.Size = UDim2.new(0.9, 0, 0, 45)
restartBtn.Position = UDim2.new(0.05, 0, 0, 165)
restartBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
restartBtn.Text = "RESTART SCRIPT"
restartBtn.TextColor3 = Color3.new(1,1,1)
restartBtn.TextScaled = true
restartBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", restartBtn).CornerRadius = UDim.new(0, 10)

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

local function runFarm()
    if not root then 
        root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    end
    if not root then return end

    local rankedList = getRankedClusters()

    if #rankedList >= 1 then
        local first = rankedList[1]
        print("Teleporting to #1 Cluster (" .. first.count .. " Dabux)")
        root.CFrame = first.cf * CFrame.new(0, 4, 0)

        task.wait(40)

        rankedList = getRankedClusters()
        if #rankedList >= 2 then
            local second = rankedList[2]
            print("Moving to #2 Cluster (" .. second.count .. " Dabux)")
            root.CFrame = second.cf * CFrame.new(0, 4, 0)
            print("✅ Finished moving to second cluster.")
        end
    else
        print("No Dabux found.")
    end
end

-- Toggle Button
toggleBtn.MouseButton1Click:Connect(function()
    AUTO_FARM = not AUTO_FARM
    
    if AUTO_FARM then
        status.Text = "Status: FARM RUNNING"
        status.TextColor3 = Color3.fromRGB(0, 255, 120)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        toggleBtn.Text = "STOP FARM"
        runFarm()
    else
        status.Text = "Status: Stopped"
        status.TextColor3 = Color3.fromRGB(255, 80, 80)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        toggleBtn.Text = "START FARM"
    end
end)

-- Restart Button
restartBtn.MouseButton1Click:Connect(function()
    print("Restarting Dabux Farm Script...")
    gui:Destroy()
    loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/snowxball/SC/main/DarkJourney.lua"))()"))() -- Ganti jika perlu
    -- Atau reload script manual
end)

print("Dabux Cluster Farm GUI Loaded")
print("Tekan START FARM untuk menjalankan")
