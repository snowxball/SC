-- ERRANT GUI (ESP Fixed)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama jika ada
if CoreGui:FindFirstChild("ERRANT_GUI") then
    CoreGui.ERRANT_GUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ERRANT_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Sound Click
local clickSound = Instance.new("Sound", SoundService)
clickSound.SoundId = "rbxassetid://9118823105"
clickSound.Volume = 1

local function playClick()
    clickSound:Play()
end

local function addCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
end

-- Main Frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 280)
main.Position = UDim2.new(0.5, -150, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
addCorner(main, 12)

-- Title
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
local names = {"GOD MODE", "SPEEDHACK", "NOCLIP", "INFINITY JUMP", "ESP"}

-- Buat Tombol
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
        if funcs[name] then 
            funcs[name](toggled[name]) 
        end
    end)
    
    btns[name] = btn
end

-- ==================== ESP SYSTEM ====================
local ESP_Enabled = false
local ESP_Drawings = {}
local ESP_Connections = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    
    local drawings = {}
    
    local nameT = Drawing.new("Text")
    nameT.Center = true
    nameT.Outline = true
    nameT.Size = 14
    nameT.Font = 2
    
    local distT = Drawing.new("Text")
    distT.Center = true
    distT.Outline = true
    distT.Size = 13
    distT.Color = Color3.new(1, 0, 0)
    
    local bone = Drawing.new("Line")
    bone.Color = Color3.new(1, 1, 1)
    bone.Thickness = 2
    
    drawings.nameT = nameT
    drawings.distT = distT
    drawings.bone = bone
    
    -- RenderStepped
    local conn = RunService.RenderStepped:Connect(function()
        if not ESP_Enabled then return end
        
        local char = plr.Character
        if not char then
            nameT.Visible = false
            distT.Visible = false
            bone.Visible = false
            return
        end
        
        local head = char:FindFirstChild("Head")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not head or not root then return end
        
        local cam = workspace.CurrentCamera
        local pos, onScreen = cam:WorldToViewportPoint(head.Position)
        
        local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        local dist = myHead and (myHead.Position - head.Position).Magnitude or 9999
        
        if onScreen and dist <= 250 then
            nameT.Visible = true
            distT.Visible = true
            bone.Visible = true
            
            nameT.Text = plr.Name
            distT.Text = "Dist: " .. math.floor(dist)
            nameT.Position = Vector2.new(pos.X, pos.Y - 20)
            distT.Position = Vector2.new(pos.X, pos.Y)
            nameT.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            
            local h2 = cam:WorldToViewportPoint(head.Position)
            local t2 = cam:WorldToViewportPoint(root.Position)
            
            bone.From = Vector2.new(t2.X, t2.Y)
            bone.To = Vector2.new(h2.X, h2.Y)
        else
            nameT.Visible = false
            distT.Visible = false
            bone.Visible = false
        end
    end)
    
    ESP_Drawings[plr] = drawings
    if not ESP_Connections[plr] then ESP_Connections[plr] = {} end
    table.insert(ESP_Connections[plr], conn)
end

local function toggleESP(state)
    ESP_Enabled = state
    
    if state then
        -- Buat ESP untuk player yang sudah ada
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        
        -- Player baru
        ESP_Connections.PlayerAdded = Players.PlayerAdded:Connect(createESP)
    else
        -- Matikan & Bersihkan ESP
        for _, drawings in pairs(ESP_Drawings) do
            for _, obj in pairs(drawings) do
                if obj then obj:Remove() end
            end
        end
        
        for _, conns in pairs(ESP_Connections) do
            if typeof(conns) == "table" then
                for _, conn in ipairs(conns) do
                    if conn then conn:Disconnect() end
                end
            elseif typeof(conns) == "RBXScriptConnection" then
                conns:Disconnect()
            end
        end
        
        ESP_Drawings = {}
        ESP_Connections = {}
    end
end

-- ==================== FUNGSI LAINNYA ====================

funcs["GOD MODE"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = s and math.huge or 100
        hum.Health = s and math.huge or 100
    end
end

funcs["SPEEDHACK"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = s and 100 or 16
    end
end

funcs["NOCLIP"] = function(s)
    -- (Kamu bisa tambahkan kembali logic noclip jika mau)
end

funcs["INFINITY JUMP"] = function(s)
    if s then
        if _G.JC then _G.JC:Disconnect() end
        _G.JC = UserInputService.JumpRequest:Connect(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    elseif _G.JC then
        _G.JC:Disconnect()
        _G.JC = nil
    end
end

funcs["ESP"] = toggleESP

-- Re-apply toggle saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, name in ipairs(names) do
        if toggled[name] and funcs[name] then
            funcs[name](true)
        end
    end
end)
