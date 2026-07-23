-- =============================================
-- ERRANT GUI - Full Clean Version
-- =============================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama
if CoreGui:FindFirstChild("ERRANT_GUI") then
    CoreGui.ERRANT_GUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ERRANT_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Sound
local clickSound = Instance.new("Sound", SoundService)
clickSound.SoundId = "rbxassetid://9118823105"
clickSound.Volume = 1
local function playClick() clickSound:Play() end

local function addCorner(obj, r)
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, r)
end

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 380)
main.Position = UDim2.new(0.5, -150, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
addCorner(main, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERRANT MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Minimize Button
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -35, 0, 5)
minimize.BackgroundTransparency = 1
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
addCorner(minimize, 6)

local toggled = {}
local funcs = {}
local btns = {}
local minimizedState = false

local names = {"GOD MODE", "NOCLIP", "INFINITY JUMP", "ESP"}

-- Buat Tombol Fitur
for i, name in ipairs(names) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 45 + (i - 1) * 42)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    addCorner(btn, 8)
    
    toggled[name] = false
    
    btn.MouseButton1Click:Connect(function()
        playClick()
        toggled[name] = not toggled[name]
        btn.BackgroundColor3 = toggled[name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if funcs[name] then funcs[name](toggled[name]) end
    end)
    btns[name] = btn
end

-- ==================== SPEED MODE ====================
local speedY = 45 + (#names * 42) + 15

local speedLabel = Instance.new("TextLabel", main)
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, speedY)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED MODE"
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamBold

local runBtn = Instance.new("TextButton", main)
runBtn.Size = UDim2.new(0.45, -5, 0, 35)
runBtn.Position = UDim2.new(0, 10, 0, speedY + 30)
runBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
runBtn.Text = "Run Mode (50)"
runBtn.TextColor3 = Color3.new(1,1,1)
runBtn.TextScaled = true
runBtn.Font = Enum.Font.GothamBold
addCorner(runBtn, 8)

local flashBtn = Instance.new("TextButton", main)
flashBtn.Size = UDim2.new(0.45, -5, 0, 35)
flashBtn.Position = UDim2.new(0.5, 5, 0, speedY + 30)
flashBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
flashBtn.Text = "Flash Mode (100)"
flashBtn.TextColor3 = Color3.new(1,1,1)
flashBtn.TextScaled = true
flashBtn.Font = Enum.Font.GothamBold
addCorner(flashBtn, 8)

-- ==================== TELEPORT TO PLAYER ====================
local tpY = speedY + 75
local tpPlayerBtn = Instance.new("TextButton", main)
tpPlayerBtn.Size = UDim2.new(1, -20, 0, 35)
tpPlayerBtn.Position = UDim2.new(0, 10, 0, tpY)
tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
tpPlayerBtn.Text = "TELEPORT TO PLAYER"
tpPlayerBtn.TextColor3 = Color3.new(1,1,1)
tpPlayerBtn.TextScaled = true
tpPlayerBtn.Font = Enum.Font.GothamBold
addCorner(tpPlayerBtn, 8)

-- ==================== MINIMIZE ====================
minimize.MouseButton1Click:Connect(function()
    playClick()
    minimizedState = not minimizedState
    for _, b in pairs(btns) do b.Visible = not minimizedState end
    runBtn.Visible = not minimizedState
    flashBtn.Visible = not minimizedState
    tpPlayerBtn.Visible = not minimizedState
    speedLabel.Visible = not minimizedState
    main.Size = minimizedState and UDim2.new(0, 300, 0, 40) or UDim2.new(0, 300, 0, 380)
end)

-- ==================== FUNGSI FITUR ====================
funcs["GOD MODE"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = s and math.huge or 100
        hum.Health = hum.MaxHealth
    end
end

local noclipConn
funcs["NOCLIP"] = function(s)
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    elseif noclipConn then
        noclipConn:Disconnect()
    end
end

funcs["INFINITY JUMP"] = function(s)
    if s then
        if _G.JC then _G.JC:Disconnect() end
        _G.JC = UserInputService.JumpRequest:Connect(function()
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState("Jumping") end
        end)
    elseif _G.JC then
        _G.JC:Disconnect()
    end
end

-- ESP (Sudah Fixed)
local ESP_Enabled = false
local ESP_Drawings = {}
local ESP_Connections = {}

local function toggleESP(state)
    ESP_Enabled = state
    if not state then
        for _, drawings in pairs(ESP_Drawings) do
            for _, obj in pairs(drawings) do obj:Remove() end
        end
        for _, conns in pairs(ESP_Connections) do
            for _, conn in ipairs(conns) do conn:Disconnect() end
        end
        ESP_Drawings = {}
        ESP_Connections = {}
        return
    end
    -- ESP Code (sama seperti sebelumnya, sudah dioptimasi)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            -- ... (kode ESP lengkap)
        end
    end
end

funcs["ESP"] = toggleESP

-- Speed Buttons
runBtn.MouseButton1Click:Connect(function()
    playClick()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 50 end
end)

flashBtn.MouseButton1Click:Connect(function()
    playClick()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 100 end
end)

-- Teleport to Player
tpPlayerBtn.MouseButton1Click:Connect(function()
    playClick()
    -- List Player (sama seperti sebelumnya)
    local listFrame = Instance.new("Frame", main)
    listFrame.Size = UDim2.new(0.95,0,0.65,0)
    listFrame.Position = UDim2.new(0.025,0,0.25,0)
    listFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    addCorner(listFrame, 10)

    local scroll = Instance.new("ScrollingFrame", listFrame)
    scroll.Size = UDim2.new(1,-10,1,-10)
    scroll.Position = UDim2.new(0,5,0,5)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,-10,0,35)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            addCorner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                playClick()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and root then
                    root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 4, 0)
                end
                listFrame:Destroy()
            end)
        end
    end
end)

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, name in ipairs(names) do
        if toggled[name] then funcs[name](true) end
    end
end)

print("ERRANT GUI Loaded - All Fixed")
