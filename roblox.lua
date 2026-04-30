-- Errant SpeedHack with Slider (10 - 200)
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
local function playClick() clickSound:Play() end

local function addCorner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r)
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 340)
main.Position = UDim2.new(0.5, -160, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
addCorner(main, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ERRANT MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.BackgroundTransparency = 1
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextScaled = true
addCorner(minimize, 6)

-- Variabel Speed
local SpeedValue = 100  -- Default speed
local speedConnection = nil

local toggled = {}
local funcs = {}
local btns = {}

local names = {"GOD MODE", "SPEEDHACK", "NOCLIP", "INFINITY JUMP", "ESP"}

-- Buat tombol toggle
for i, name in ipairs(names) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 50 + (i - 1) * 42)
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

-- === SPEEDHACK SLIDER ===
local speedLabel = Instance.new("TextLabel", main)
speedLabel.Size = UDim2.new(1, -20, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 270)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. SpeedValue
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham

local speedSlider = Instance.new("TextButton", main)  -- Kita pakai TextButton sebagai slider sederhana
speedSlider.Size = UDim2.new(1, -20, 0, 25)
speedSlider.Position = UDim2.new(0, 10, 0, 300)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSlider.Text = ""
speedSlider.BorderSizePixel = 0
addCorner(speedSlider, 6)

local sliderInner = Instance.new("Frame", speedSlider)
sliderInner.Size = UDim2.new(SpeedValue/200, 0, 1, 0)
sliderInner.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
addCorner(sliderInner, 6)

-- Fungsi update slider
local function updateSlider()
    speedLabel.Text = "Speed: " .. SpeedValue
    sliderInner.Size = UDim2.new(SpeedValue/200, 0, 1, 0)
    
    -- Jika SpeedHack sedang aktif, langsung apply speed baru
    if toggled["SPEEDHACK"] then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SpeedValue
        end
    end
end

-- Drag slider
speedSlider.MouseButton1Down:Connect(function()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local mouseX = UserInputService:GetMouseLocation().X
        local sliderPos = speedSlider.AbsolutePosition.X
        local sliderWidth = speedSlider.AbsoluteSize.X
        
        local percent = math.clamp((mouseX - sliderPos) / sliderWidth, 0, 1)
        SpeedValue = math.floor(10 + (percent * 190))  -- 10 sampai 200
        
        updateSlider()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if connection then connection:Disconnect() end
        end
    end)
end)

-- ================== FUNGSI FITUR ==================

funcs["GOD MODE"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if s then
            hum.MaxHealth = 9e9
            hum.Health = 9e9
            hum.HealthChanged:Connect(function()
                if s then hum.Health = hum.MaxHealth end
            end)
        end
    end
end

funcs["SPEEDHACK"] = function(s)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if s then
            hum.WalkSpeed = SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end
end

funcs["NOCLIP"] = function(s)
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif noclipConn then
        noclipConn:Disconnect()
    end
end

funcs["INFINITY JUMP"] = function(s)
    if s then
        _G.JC = UserInputService.JumpRequest:Connect(function()
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState("Jumping") end
        end)
    elseif _G.JC then
        _G.JC:Disconnect()
    end
end

funcs["ESP"] = function(s)
    -- ESP kamu tetap sama (belum diubah)
    print("ESP diaktifkan (belum dimodifikasi)")
end

-- Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, name in ipairs(names) do
        if toggled[name] then 
            funcs[name](true) 
        end
    end
end)
