-- Errant Menu - Minimize Fixed
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("Errant") then
    CoreGui.Errant:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "Errant"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

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
main.Size = UDim2.new(0, 320, 0, 360)
main.Position = UDim2.new(0.5, -160, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
addCorner(main, 12)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERRANT MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Minimize Button
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -38, 0, 5)
minimize.BackgroundTransparency = 1
minimize.Text = "−"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.TextScaled = true
minimize.Font = Enum.Font.GothamBold
addCorner(minimize, 6)

local minimized = false
local originalSize = UDim2.new(0, 320, 0, 360)

minimize.MouseButton1Click:Connect(function()
    playClick()
    minimized = not minimized
    
    if minimized then
        main.Size = UDim2.new(0, 320, 0, 40)   -- Hanya title yang tersisa
        minimize.Text = "+"
    else
        main.Size = originalSize
        minimize.Text = "−"
    end
    
    -- Sembunyikan / Tampilkan semua elemen kecuali title dan minimize button
    for _, child in ipairs(main:GetChildren()) do
        if child ~= title and child ~= minimize then
            child.Visible = not minimized
        end
    end
end)

-- ================== VARIABEL SPEED ==================
local SpeedValue = 100

-- ================== TOGGLE BUTTONS ==================
local toggled = {}
local funcs = {}
local btns = {}

local names = {"GOD MODE", "SPEEDHACK", "NOCLIP", "INFINITY JUMP", "ESP"}

for i, name in ipairs(names) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, 50 + (i-1)*45)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    addCorner(btn, 8)

    toggled[name] = false
    btns[name] = btn

    btn.MouseButton1Click:Connect(function()
        playClick()
        toggled[name] = not toggled[name]
        btn.BackgroundColor3 = toggled[name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        if funcs[name] then
            funcs[name](toggled[name])
        end
    end)
end

-- ================== SPEED SLIDER ==================
local speedLabel = Instance.new("TextLabel", main)
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 280)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. SpeedValue
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamSemibold

local speedSlider = Instance.new("TextButton", main)
speedSlider.Size = UDim2.new(1, -20, 0, 28)
speedSlider.Position = UDim2.new(0, 10, 0, 310)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSlider.Text = ""
speedSlider.BorderSizePixel = 0
addCorner(speedSlider, 8)

local sliderFill = Instance.new("Frame", speedSlider)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.Size = UDim2.new(SpeedValue/200, 1, 1, 0)
sliderFill.BorderSizePixel = 0
addCorner(sliderFill, 8)

local function updateSlider()
    speedLabel.Text = "Speed: " .. SpeedValue
    sliderFill.Size = UDim2.new(SpeedValue / 200, 0, 1, 0)
    
    if toggled["SPEEDHACK"] then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedValue
        end
    end
end

-- Slider Logic
speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderStart = speedSlider.AbsolutePosition.X
            local sliderWidth = speedSlider.AbsoluteSize.X
            
            local percent = math.clamp((mousePos - sliderStart) / sliderWidth, 0, 1)
            SpeedValue = math.floor(10 + percent * 190)
            updateSlider()
        end)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- ================== FUNGSI FITUR ==================

funcs["GOD MODE"] = function(s) 
    -- ... (bisa kamu pakai yang versi kuat sebelumnya)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and s then
        hum.MaxHealth = 9e9
        hum.Health = 9e9
    end
end

funcs["SPEEDHACK"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = s and SpeedValue or 16
    end
end

funcs["NOCLIP"] = function(s)
    -- kode noclip kamu sebelumnya
end

funcs["INFINITY JUMP"] = function(s)
    -- kode infinity jump kamu sebelumnya
end

funcs["ESP"] = function(s)
    -- kode ESP kamu
end

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.2)
    for _, name in ipairs(names) do
        if toggled[name] then
            funcs[name](true)
        end
    end
end)
