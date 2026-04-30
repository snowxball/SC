-- Errant --
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
