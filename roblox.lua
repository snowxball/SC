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
clickSound.Volume = 0.7

local function playClick()
    clickSound:Play()
end

local function addCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 320)
main.Position = UDim2.new(0.5, -140, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
addCorner(main, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -50, 0, 35)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERRANT"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local minimizeBtn = Instance.new("TextButton", main)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -34, 0, 4)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
addCorner(minimizeBtn, 6)

local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    playClick()
    minimized = not minimized
    
    if minimized then
        main.Size = UDim2.new(0, 280, 0, 35)
        minimizeBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 280, 0, 320)
        minimizeBtn.Text = "−"
    end

    for _, child in ipairs(main:GetChildren()) do
        if child ~= title and child ~= minimizeBtn then
            child.Visible = not minimized
        end
    end
end)

local SpeedValue = 100

local toggled = {}
local funcs = {}
local btns = {}

local names = {"GOD MODE", "SPEEDHACK", "NOCLIP", "INFINITY JUMP", "ESP"}

for i, name in ipairs(names) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, 45 + (i-1)*39)
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

local speedLabel = Instance.new("TextLabel", main)
speedLabel.Size = UDim2.new(1, -16, 0, 22)
speedLabel.Position = UDim2.new(0, 8, 0, 245)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. SpeedValue
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.GothamSemibold

local speedSlider = Instance.new("TextButton", main)
speedSlider.Size = UDim2.new(1, -16, 0, 24)
speedSlider.Position = UDim2.new(0, 8, 0, 270)
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

speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderX = speedSlider.AbsolutePosition.X
            local sliderWidth = speedSlider.AbsoluteSize.X
            
            local percent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
            SpeedValue = math.floor(10 + (percent * 190))
            updateSlider()
        end)
        
        local endedConn
        endedConn = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                if conn then conn:Disconnect() end
                if endedConn then endedConn:Disconnect() end
            end
        end)
    end
end)

funcs["GOD MODE"] = function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and state then
        hum.MaxHealth = 9e9
        hum.Health = 9e9
    end
end

funcs["SPEEDHACK"] = function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = state and SpeedValue or 16
    end
end

funcs["NOCLIP"] = function(state)
end

funcs["INFINITY JUMP"] = function(state)
end

funcs["ESP"] = function(state)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.2)
    for _, name in ipairs(names) do
        if toggled[name] then
            funcs[name](true)
        end
    end
end)

print("Errant Menu Loaded")
