-- ERRANT FULL BRIGHT GUI
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = game.Players.LocalPlayer

-- Hapus GUI lama
if CoreGui:FindFirstChild("ERRANT_LIGHTING_GUI") then
    CoreGui.ERRANT_LIGHTING_GUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ERRANT_LIGHTING_GUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 220)
main.Position = UDim2.new(0.5, -140, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "ERRANT LIGHTING"
title.TextColor3 = Color3.fromRGB(255, 220, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Status Label
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 60)
status.BackgroundTransparency = 1
status.Text = "Status: Normal"
status.TextColor3 = Color3.fromRGB(150, 150, 150)
status.TextScaled = true
status.Font = Enum.Font.Gotham

-- Toggle Button
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 100)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleBtn.Text = "FULL BRIGHT OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 10)

-- Variabel
local fullBrightEnabled = false
local originalSettings = {}

-- Simpan setting asli
local function saveOriginal()
    originalSettings.Brightness = Lighting.Brightness
    originalSettings.ClockTime = Lighting.ClockTime
    originalSettings.FogEnd = Lighting.FogEnd
    originalSettings.GlobalShadows = Lighting.GlobalShadows
    originalSettings.Ambient = Lighting.Ambient
end

-- Full Bright Function
local function setFullBright(enable)
    fullBrightEnabled = enable
    
    if enable then
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        
        -- Efek tambahan
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end
        
        status.Text = "Status: FULL BRIGHT ON"
        status.TextColor3 = Color3.fromRGB(0, 255, 100)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        toggleBtn.Text = "FULL BRIGHT ON"
    else
        -- Kembalikan ke setting semula
        Lighting.Brightness = originalSettings.Brightness or 1
        Lighting.ClockTime = originalSettings.ClockTime or 14
        Lighting.FogEnd = originalSettings.FogEnd or 100000
        Lighting.GlobalShadows = originalSettings.GlobalShadows or true
        Lighting.Ambient = originalSettings.Ambient or Color3.fromRGB(128, 128, 128)
        
        status.Text = "Status: Normal"
        status.TextColor3 = Color3.fromRGB(150, 150, 150)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        toggleBtn.Text = "FULL BRIGHT OFF"
    end
end

-- Event
toggleBtn.MouseButton1Click:Connect(function()
    setFullBright(not fullBrightEnabled)
end)

-- Simpan setting saat pertama kali
saveOriginal()

print("ERRANT Full Bright GUI Loaded ✅")

-- Bonus: Tekan "L" untuk toggle cepat
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.L then
        setFullBright(not fullBrightEnabled)
    end
end)
