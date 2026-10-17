-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ==================== DEFAULT VALUES (untuk restore) ====================
local DefaultSettings = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ShadowSoftness = Lighting.ShadowSoftness,
    GlobalShadows = Lighting.GlobalShadows,
    Technology = Lighting.Technology,
    ExposureCompensation = Lighting.ExposureCompensation,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}

-- Settings yang bisa di-custom
local Settings = {
    Enabled = false,
    LightingPercent = 100,   -- 0 - 200%
    ShadePercent = 100,      -- 0 - 200% (shadow softness & intensity)
}

-- ==================== APPLY / RESTORE ====================
local function ApplyVisuals()
    if not Settings.Enabled then return end

    local lightMult = Settings.LightingPercent / 100
    local shadeMult = Settings.ShadePercent / 100

    -- Lighting
    Lighting.Brightness = math.clamp(2.5 * lightMult, 0, 10)
    Lighting.Ambient = Color3.fromRGB(
        math.clamp(80 * lightMult, 0, 255),
        math.clamp(80 * lightMult, 0, 255),
        math.clamp(90 * lightMult, 0, 255)
    )
    Lighting.OutdoorAmbient = Color3.fromRGB(
        math.clamp(120 * lightMult, 0, 255),
        math.clamp(120 * lightMult, 0, 255),
        math.clamp(140 * lightMult, 0, 255)
    )
    Lighting.ExposureCompensation = math.clamp(0.4 * lightMult, -2, 2)
    Lighting.EnvironmentDiffuseScale = math.clamp(1 * lightMult, 0, 2)
    Lighting.EnvironmentSpecularScale = math.clamp(1 * lightMult, 0, 2)

    -- Shadows / Shade
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = math.clamp(0.2 / shadeMult, 0.05, 1) -- semakin tinggi % = shadow lebih tajam
    pcall(function()
        Lighting.Technology = Enum.Technology.Future -- paling bagus (jika support)
    end)
end

local function RestoreVisuals()
    Lighting.Brightness = DefaultSettings.Brightness
    Lighting.Ambient = DefaultSettings.Ambient
    Lighting.OutdoorAmbient = DefaultSettings.OutdoorAmbient
    Lighting.ShadowSoftness = DefaultSettings.ShadowSoftness
    Lighting.GlobalShadows = DefaultSettings.GlobalShadows
    Lighting.Technology = DefaultSettings.Technology
    Lighting.ExposureCompensation = DefaultSettings.ExposureCompensation
    Lighting.EnvironmentDiffuseScale = DefaultSettings.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = DefaultSettings.EnvironmentSpecularScale
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HDVisualGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "HD Visual Enhancer"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -45)
Content.Position = UDim2.new(0, 12, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
ToggleBtn.Text = "Visual: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

-- ===== Lighting % =====
local LightingLabel = Instance.new("TextLabel")
LightingLabel.Size = UDim2.new(1, 0, 0, 22)
LightingLabel.Position = UDim2.new(0, 0, 0, 50)
LightingLabel.BackgroundTransparency = 1
LightingLabel.Text = "Lighting: 100%"
LightingLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
LightingLabel.Font = Enum.Font.Gotham
LightingLabel.TextSize = 13
LightingLabel.TextXAlignment = Enum.TextXAlignment.Left
LightingLabel.Parent = Content

local LightingMinus = Instance.new("TextButton")
LightingMinus.Size = UDim2.new(0, 40, 0, 28)
LightingMinus.Position = UDim2.new(0, 0, 0, 75)
LightingMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
LightingMinus.Text = "-"
LightingMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
LightingMinus.Font = Enum.Font.GothamBold
LightingMinus.TextSize = 18
LightingMinus.Parent = Content

local LightingPlus = Instance.new("TextButton")
LightingPlus.Size = UDim2.new(0, 40, 0, 28)
LightingPlus.Position = UDim2.new(1, -40, 0, 75)
LightingPlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
LightingPlus.Text = "+"
LightingPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
LightingPlus.Font = Enum.Font.GothamBold
LightingPlus.TextSize = 18
LightingPlus.Parent = Content

local LightingCorner1 = Instance.new("UICorner")
LightingCorner1.CornerRadius = UDim.new(0, 5)
LightingCorner1.Parent = LightingMinus

local LightingCorner2 = Instance.new("UICorner")
LightingCorner2.CornerRadius = UDim.new(0, 5)
LightingCorner2.Parent = LightingPlus

-- ===== Shade % =====
local ShadeLabel = Instance.new("TextLabel")
ShadeLabel.Size = UDim2.new(1, 0, 0, 22)
ShadeLabel.Position = UDim2.new(0, 0, 0, 115)
ShadeLabel.BackgroundTransparency = 1
ShadeLabel.Text = "Shade / Shadow: 100%"
ShadeLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
ShadeLabel.Font = Enum.Font.Gotham
ShadeLabel.TextSize = 13
ShadeLabel.TextXAlignment = Enum.TextXAlignment.Left
ShadeLabel.Parent = Content

local ShadeMinus = Instance.new("TextButton")
ShadeMinus.Size = UDim2.new(0, 40, 0, 28)
ShadeMinus.Position = UDim2.new(0, 0, 0, 140)
ShadeMinus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ShadeMinus.Text = "-"
ShadeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
ShadeMinus.Font = Enum.Font.GothamBold
ShadeMinus.TextSize = 18
ShadeMinus.Parent = Content

local ShadePlus = Instance.new("TextButton")
ShadePlus.Size = UDim2.new(0, 40, 0, 28)
ShadePlus.Position = UDim2.new(1, -40, 0, 140)
ShadePlus.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
ShadePlus.Text = "+"
ShadePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
ShadePlus.Font = Enum.Font.GothamBold
ShadePlus.TextSize = 18
ShadePlus.Parent = Content

local ShadeCorner1 = Instance.new("UICorner")
ShadeCorner1.CornerRadius = UDim.new(0, 5)
ShadeCorner1.Parent = ShadeMinus

local ShadeCorner2 = Instance.new("UICorner")
ShadeCorner2.CornerRadius = UDim.new(0, 5)
ShadeCorner2.Parent = ShadePlus

-- ==================== EVENTS ====================
local function UpdateLabels()
    LightingLabel.Text = "Lighting: " .. Settings.LightingPercent .. "%"
    ShadeLabel.Text = "Shade / Shadow: " .. Settings.ShadePercent .. "%"
end

ToggleBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled

    if Settings.Enabled then
        ToggleBtn.Text = "Visual: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        ApplyVisuals()
    else
        ToggleBtn.Text = "Visual: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
        RestoreVisuals()
    end
end)

-- Lighting controls
LightingPlus.MouseButton1Click:Connect(function()
    Settings.LightingPercent = math.clamp(Settings.LightingPercent + 10, 0, 200)
    UpdateLabels()
    if Settings.Enabled then ApplyVisuals() end
end)

LightingMinus.MouseButton1Click:Connect(function()
    Settings.LightingPercent = math.clamp(Settings.LightingPercent - 10, 0, 200)
    UpdateLabels()
    if Settings.Enabled then ApplyVisuals() end
end)

-- Shade controls
ShadePlus.MouseButton1Click:Connect(function()
    Settings.ShadePercent = math.clamp(Settings.ShadePercent + 10, 0, 200)
    UpdateLabels()
    if Settings.Enabled then ApplyVisuals() end
end)

ShadeMinus.MouseButton1Click:Connect(function()
    Settings.ShadePercent = math.clamp(Settings.ShadePercent - 10, 0, 200)
    UpdateLabels()
    if Settings.Enabled then ApplyVisuals() end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    Settings.Enabled = false
    RestoreVisuals()
    ScreenGui:Destroy()
end)

print("HD Visual Enhancer Loaded!")
