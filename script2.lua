--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--//========================
--// GUI SETUP (UPDATED)
--//========================

local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 300) -- taller
main.Position = UDim2.new(0.5, -160, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

-- Dragging (better than .Draggable)
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "Errant's X Sc"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = main

-- SCROLLING CONTAINER (IMPORTANT)
local container = Instance.new("ScrollingFrame")
container.Position = UDim2.new(0, 0, 0, 35)
container.Size = UDim2.new(1, 0, 1, -35)
container.BackgroundTransparency = 1
container.CanvasSize = UDim2.new(0,0,0,0)
container.ScrollBarThickness = 6
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = container

-- Auto resize scroll
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

--//========================
--// FEATURE: SPEED
--//========================

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -10, 0, 40)
speedFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = container

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 18
speedLabel.Parent = speedFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.5, -10, 0.7, 0)
speedBox.Position = UDim2.new(0.5, 5, 0.15, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.PlaceholderText = "Enter speed..."
speedBox.Text = ""
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 16
speedBox.Parent = speedFrame

local currentSpeed = 16

local function applySpeed()
	local char = player.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.WalkSpeed = currentSpeed
	end
end

-- When user presses Enter
speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(speedBox.Text)
		if num then
			currentSpeed = math.clamp(num, 0, 500)
			speedBox.Text = tostring(currentSpeed)
			applySpeed()
		else
			speedBox.Text = tostring(currentSpeed)
		end
	end
end)

-- Keep after respawn
player.CharacterAdded:Connect(function(char)
	local humanoid = char:WaitForChild("Humanoid")
	task.wait(0.2)
	humanoid.WalkSpeed = currentSpeed
end)

--//========================
--// FEATURE: SPIN
--//========================

local spinFrame = Instance.new("Frame")
spinFrame.Size = UDim2.new(1, -10, 0, 50)
spinFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
spinFrame.BorderSizePixel = 0
spinFrame.Parent = container

-- Label
local spinLabel = Instance.new("TextLabel")
spinLabel.Size = UDim2.new(0.4, 0, 1, 0)
spinLabel.BackgroundTransparency = 1
spinLabel.Text = "Spin"
spinLabel.TextColor3 = Color3.new(1,1,1)
spinLabel.Font = Enum.Font.SourceSans
spinLabel.TextSize = 18
spinLabel.Parent = spinFrame

-- Speed box
local spinBox = Instance.new("TextBox")
spinBox.Size = UDim2.new(0.3, 0, 0.7, 0)
spinBox.Position = UDim2.new(0.4, 5, 0.15, 0)
spinBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
spinBox.TextColor3 = Color3.new(1,1,1)
spinBox.PlaceholderText = "Speed"
spinBox.Text = "20"
spinBox.Font = Enum.Font.SourceSans
spinBox.TextSize = 16
spinBox.Parent = spinFrame

-- Toggle button (switch style)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0) -- red = off
toggle.Text = ""
toggle.Parent = spinFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- Logic
local spinning = false
local spinSpeed = 20

local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart")
end

local function applySpin()
	local char = player.Character
	if not char then return end
	
	local root = getRoot(char)
	if not root then return end

	-- remove existing
	for _,v in pairs(root:GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end

	if spinning then
		local Spin = Instance.new("BodyAngularVelocity")
		Spin.Name = "Spinning"
		Spin.Parent = root
		Spin.MaxTorque = Vector3.new(0, math.huge, 0)
		Spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
	end
end

-- Toggle click
toggle.MouseButton1Click:Connect(function()
	spinning = not spinning

	if spinning then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0) -- green
		knob:TweenPosition(UDim2.new(1, -22, 0.5, -10), "Out", "Quad", 0.15, true)
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0) -- red
		knob:TweenPosition(UDim2.new(0, 2, 0.5, -10), "Out", "Quad", 0.15, true)
	end

	applySpin()
end)

-- Speed input
spinBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(spinBox.Text)
		if num then
			spinSpeed = num
			spinBox.Text = tostring(spinSpeed)
			if spinning then
				applySpin()
			end
		else
			spinBox.Text = tostring(spinSpeed)
		end
	end
end)

-- Respawn handling
player.CharacterAdded:Connect(function()
	task.wait(0.3)
	if spinning then
		applySpin()
	end
end)

--//========================
--// FEATURE: NOCLIP (EXACT)
--//========================

local RunService = game:GetService("RunService")

local noclipFrame = Instance.new("Frame")
noclipFrame.Size = UDim2.new(1, -10, 0, 40)
noclipFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
noclipFrame.BorderSizePixel = 0
noclipFrame.Parent = container

-- Label
local noclipLabel = Instance.new("TextLabel")
noclipLabel.Size = UDim2.new(0.6, 0, 1, 0)
noclipLabel.BackgroundTransparency = 1
noclipLabel.Text = "Noclip"
noclipLabel.TextColor3 = Color3.new(1,1,1)
noclipLabel.Font = Enum.Font.SourceSans
noclipLabel.TextSize = 18
noclipLabel.Parent = noclipFrame

-- Toggle UI
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.Text = ""
toggle.Parent = noclipFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- ORIGINAL LOGIC VARIABLES
local Clip = true
local Noclipping = nil

local function startNoclip()
	Clip = false
	task.wait(0.1)

	local function NoclipLoop()
		if Clip == false and player.Character ~= nil then
			for _, child in pairs(player.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true then
					child.CanCollide = false
				end
			end
		end
	end

	Noclipping = RunService.Stepped:Connect(NoclipLoop)
end

local function stopNoclip()
	if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
end

-- Toggle
local enabled = false

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
		knob:TweenPosition(UDim2.new(1, -22, 0.5, -10), "Out", "Quad", 0.15, true)
		startNoclip()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
		knob:TweenPosition(UDim2.new(0, 2, 0.5, -10), "Out", "Quad", 0.15, true)
		stopNoclip()
	end
end)

-- Respawn support (same behavior as your commands)
player.CharacterAdded:Connect(function()
	if enabled then
		startNoclip()
	end
end)

--//========================
--// FEATURE: FLY
--//========================

-- Create frame
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(1, -10, 0, 50)
flyFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
flyFrame.BorderSizePixel = 0
flyFrame.Parent = container

-- Label
local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.3, 0, 1, 0)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly"
flyLabel.TextColor3 = Color3.new(1,1,1)
flyLabel.Font = Enum.Font.SourceSans
flyLabel.TextSize = 18
flyLabel.Parent = flyFrame

-- Speed box
local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Size = UDim2.new(0.3, 0, 0.7, 0)
flySpeedBox.Position = UDim2.new(0.35, 5, 0.15, 0)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
flySpeedBox.TextColor3 = Color3.new(1,1,1)
flySpeedBox.PlaceholderText = "Speed"
flySpeedBox.Text = "50"
flySpeedBox.Font = Enum.Font.SourceSans
flySpeedBox.TextSize = 16
flySpeedBox.Parent = flyFrame

-- Toggle button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.Text = ""
toggle.Parent = flyFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- Variables
local FLYING = false
local vfly = false
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local SPEED = 0
local flySpeed = 50
local humanoid
local T

-- Input handling
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1 end
	if input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1 end
	if input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1 end
	if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1 end
	if input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 1 end
	if input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -1 end
end)

UIS.InputEnded:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0 end
	if input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0 end
	if input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0 end
	if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0 end
	if input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0 end
	if input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0 end
end)

-- FocusLost for speed
flySpeedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(flySpeedBox.Text)
		if num then
			flySpeed = math.clamp(num, 0, 500)
			flySpeedBox.Text = tostring(flySpeed)
		else
			flySpeedBox.Text = tostring(flySpeed)
		end
	end
end)

-- FLY function (exact original logic)
local function FLY()
	FLYING = true

	local BG = Instance.new('BodyGyro')
	local BV = Instance.new('BodyVelocity')

	BG.P = 9e4
	BG.Parent = T
	BV.Parent = T

	BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	BG.CFrame = T.CFrame

	BV.Velocity = Vector3.new(0,0,0)
	BV.MaxForce = Vector3.new(9e9,9e9,9e9)

	task.spawn(function()
		repeat task.wait()
			local camera = workspace.CurrentCamera
			if not vfly and humanoid then
				humanoid.PlatformStand = true
			end

			if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
				SPEED = flySpeed
			elseif SPEED ~= 0 then
				SPEED = 0
			end

			if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
				BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E)*0.2, 0).p) - camera.CFrame.p)) * SPEED
				lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
			elseif SPEED ~= 0 then
				BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E)*0.2,0).p) - camera.CFrame.p)) * SPEED
			else
				BV.Velocity = Vector3.new(0,0,0)
			end

			BG.CFrame = camera.CFrame
		until not FLYING

		CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
		lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
		SPEED = 0

		BG:Destroy()
		BV:Destroy()
		if humanoid then humanoid.PlatformStand = false end
	end)
end

local function UNFLY()
	FLYING = false
end

-- Toggle
local enabled = false
toggle.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
		knob:TweenPosition(UDim2.new(1,-22,0.5,-10),"Out","Quad",0.15,true)

		local char = player.Character
		if char then
			humanoid = char:FindFirstChildOfClass("Humanoid")
			T = char:FindFirstChild("HumanoidRootPart")
			if humanoid and T then
				FLY()
			end
		end
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
		knob:TweenPosition(UDim2.new(0,2,0.5,-10),"Out","Quad",0.15,true)
		UNFLY()
	end
end)

-- Respawn support
player.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	if enabled then
		humanoid = char:FindFirstChildOfClass("Humanoid")
		T = char:FindFirstChild("HumanoidRootPart")
		if humanoid and T then
			FLY()
		end
	end
end)

--//========================
--// FEATURE: ESP
--//========================

local espFrame = Instance.new("Frame")
espFrame.Size = UDim2.new(1, -10, 0, 40)
espFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
espFrame.BorderSizePixel = 0
espFrame.Parent = container

-- Label
local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.6, 0, 1, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP"
espLabel.TextColor3 = Color3.new(1,1,1)
espLabel.Font = Enum.Font.SourceSans
espLabel.TextSize = 18
espLabel.Parent = espFrame

-- Toggle
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.Text = ""
toggle.Parent = espFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- Logic
local espEnabled = false
local espObjects = {}

local function createESP(plr)
	if plr == player then return end

	local function apply(char)
		if not espEnabled then return end

		local head = char:FindFirstChild("Head")
		if not head then return end

		-- Highlight
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight.FillColor = Color3.fromRGB(255,0,0)
		highlight.OutlineColor = Color3.fromRGB(255,0,0)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = char

		-- Billboard
		local bill = Instance.new("BillboardGui")
		bill.Name = "ESPBillboard"
		bill.Size = UDim2.new(0, 100, 0, 20)
		bill.StudsOffset = Vector3.new(0, 2, 0)
		bill.AlwaysOnTop = true
		bill.Parent = head

		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1,0,1,0)
		text.BackgroundTransparency = 1
		text.Text = plr.Name
		text.TextColor3 = Color3.fromRGB(255,0,0)
		text.TextStrokeTransparency = 0
		text.Font = Enum.Font.SourceSansBold
		text.TextScaled = true
		text.Parent = bill

		espObjects[plr] = {highlight, bill}
	end

	if plr.Character then
		apply(plr.Character)
	end

	plr.CharacterAdded:Connect(apply)
end

local function enableESP()
	for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
		createESP(plr)
	end
end

local function disableESP()
	for _, objs in pairs(espObjects) do
		for _, obj in pairs(objs) do
			if obj and obj.Parent then
				obj:Destroy()
			end
		end
	end
	espObjects = {}
end

-- Toggle click
toggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled

	if espEnabled then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
		knob:TweenPosition(UDim2.new(1,-22,0.5,-10),"Out","Quad",0.15,true)
		enableESP()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
		knob:TweenPosition(UDim2.new(0,2,0.5,-10),"Out","Quad",0.15,true)
		disableESP()
	end
end)

-- Handle new players joining
game:GetService("Players").PlayerAdded:Connect(function(plr)
	if espEnabled then
		createESP(plr)
	end
end)

--//========================
--// FEATURE: HITBOX
--//========================

local Players = game:GetService("Players")

local hitboxFrame = Instance.new("Frame")
hitboxFrame.Size = UDim2.new(1, -10, 0, 50)
hitboxFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
hitboxFrame.BorderSizePixel = 0
hitboxFrame.Parent = container

-- Label
local hitboxLabel = Instance.new("TextLabel")
hitboxLabel.Size = UDim2.new(0.3, 0, 1, 0)
hitboxLabel.BackgroundTransparency = 1
hitboxLabel.Text = "Hitbox"
hitboxLabel.TextColor3 = Color3.new(1,1,1)
hitboxLabel.Font = Enum.Font.SourceSans
hitboxLabel.TextSize = 18
hitboxLabel.Parent = hitboxFrame

-- Size box
local sizeBox = Instance.new("TextBox")
sizeBox.Size = UDim2.new(0.3, 0, 0.7, 0)
sizeBox.Position = UDim2.new(0.35, 5, 0.15, 0)
sizeBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
sizeBox.TextColor3 = Color3.new(1,1,1)
sizeBox.PlaceholderText = "Size"
sizeBox.Text = "5"
sizeBox.Font = Enum.Font.SourceSans
sizeBox.TextSize = 16
sizeBox.Parent = hitboxFrame

-- Toggle
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.Text = ""
toggle.Parent = hitboxFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- Logic
local hitboxEnabled = false
local hitboxSize = 5

local function applyHitbox(plr)
	if plr == player then return end
	if not hitboxEnabled then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		root.CanCollide = false

		if hitboxSize == 1 then
			root.Size = Vector3.new(2,1,1)
		else
			root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
		end

		root.Transparency = 0.4
	end
end

local function resetHitbox(plr)
	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		root.Size = Vector3.new(2,2,1)
		root.Transparency = 1
		root.CanCollide = true
	end
end

local function applyAll()
	for _, plr in pairs(Players:GetPlayers()) do
		applyHitbox(plr)
	end
end

local function resetAll()
	for _, plr in pairs(Players:GetPlayers()) do
		resetHitbox(plr)
	end
end

-- Size input
sizeBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(sizeBox.Text)
		if num then
			hitboxSize = math.clamp(num, 1, 50)
			sizeBox.Text = tostring(hitboxSize)

			if hitboxEnabled then
				applyAll()
			end
		else
			sizeBox.Text = tostring(hitboxSize)
		end
	end
end)

-- Toggle
toggle.MouseButton1Click:Connect(function()
	hitboxEnabled = not hitboxEnabled

	if hitboxEnabled then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
		knob:TweenPosition(UDim2.new(1,-22,0.5,-10),"Out","Quad",0.15,true)
		applyAll()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
		knob:TweenPosition(UDim2.new(0,2,0.5,-10),"Out","Quad",0.15,true)
		resetAll()
	end
end)

-- Respawn handling
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.3)
		if hitboxEnabled then
			applyHitbox(plr)
		end
	end)
end)

for _, plr in pairs(Players:GetPlayers()) do
	plr.CharacterAdded:Connect(function()
		task.wait(0.3)
		if hitboxEnabled then
			applyHitbox(plr)
		end
	end)
end

--8we38ybr328b6328r32br8236v2n87rt287rtb2387rt238723tb832bv3r

-- ===== GUI (same style as yours) =====
local flingFrame = Instance.new("Frame")
flingFrame.Size = UDim2.new(1, -10, 0, 40)
flingFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
flingFrame.BorderSizePixel = 0
flingFrame.Parent = container

local flingLabel = Instance.new("TextLabel")
flingLabel.Size = UDim2.new(0.6, 0, 1, 0)
flingLabel.BackgroundTransparency = 1
flingLabel.Text = "WalkFling"
flingLabel.TextColor3 = Color3.new(1,1,1)
flingLabel.Font = Enum.Font.SourceSans
flingLabel.TextSize = 18
flingLabel.Parent = flingFrame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 50, 0, 24)
toggle.Position = UDim2.new(1, -60, 0.5, -12)
toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
toggle.Text = ""
toggle.Parent = flingFrame

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 20, 0, 20)
knob.Position = UDim2.new(0, 2, 0.5, -10)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = toggle

-- ===== STATE =====
local walkflinging = false
local diedConn = nil

-- ===== START WALKFLING =====
local function startWalkFling()
	if walkflinging then return end
	walkflinging = true

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		diedConn = humanoid.Died:Connect(function()
			walkflinging = false
		end)
	end

	task.spawn(function()
		local movel = 0.1

		while walkflinging do
			RunService.Heartbeat:Wait()

			local character = player.Character
			local root = getRoot(character)

			while not (character and character.Parent and root and root.Parent) do
				RunService.Heartbeat:Wait()
				character = player.Character
				root = getRoot(character)
				if not walkflinging then return end
			end

			local vel = root.Velocity
			root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

			RunService.RenderStepped:Wait()
			if character and character.Parent and root and root.Parent then
				root.Velocity = vel
			end

			RunService.Stepped:Wait()
			if character and character.Parent and root and root.Parent then
				root.Velocity = vel + Vector3.new(0, movel, 0)
				movel = -movel
			end
		end
	end)
end

-- ===== STOP WALKFLING =====
local function stopWalkFling()
	walkflinging = false

	if diedConn then
		diedConn:Disconnect()
		diedConn = nil
	end
end

-- ===== TOGGLE =====
toggle.MouseButton1Click:Connect(function()
	if not walkflinging then
		toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
		knob:TweenPosition(UDim2.new(1,-22,0.5,-10),"Out","Quad",0.15,true)
		startWalkFling()
	else
		toggle.BackgroundColor3 = Color3.fromRGB(120,0,0)
		knob:TweenPosition(UDim2.new(0,2,0.5,-10),"Out","Quad",0.15,true)
		stopWalkFling()
	end
end)

-- ===== RESPAWN SUPPORT =====
player.CharacterAdded:Connect(function()
	if walkflinging then
		task.wait(1)
		startWalkFling()
	end
end)
