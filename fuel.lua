-- SERVICES
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- REFERENCES
local MapFolder = Workspace:FindFirstChild("Map")
local DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
local PlayAgainRemote = ReplicatedStorage.Remotes.Misc:FindFirstChild("VotePlayAgain")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local cachedGeneratorLocation = nil
local excludeFuel = {}
local isFarming = false
local PermanentNoclipEnabled = true

-- ====================== SAFETY ======================
local function evacuateServer(reason)
    warn("[CRITICAL EVACUATION]: " .. reason)
    task.spawn(function()
        if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
            pcall(function() PlayAgainRemote:FireServer() end)
            task.wait(1)
        end
        LocalPlayer:Kick("[WARNING] UNKNOWN PLAYER DETECTED!")
    end)
    error("Script terminated")
end

if #Players:GetPlayers() > 1 then
    evacuateServer("Pre-existing player DETECTED!")
end

Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= LocalPlayer then
        evacuateServer("Player entry detected (" .. newPlayer.Name .. ")")
    end
end)

-- ====================== NOCLIP ======================
local function StartPermanentNoclip()
    local noclipConnection

    local function ConnectNoclip()
        if noclipConnection then noclipConnection:Disconnect() end

        noclipConnection = RunService.Stepped:Connect(function()
            if not PermanentNoclipEnabled then
                if noclipConnection then noclipConnection:Disconnect() end
                return
            end

            if character then
                for _, child in ipairs(character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide then
                        child.CanCollide = false
                    end
                end

                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end

    ConnectNoclip()

    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        character = newChar
        ConnectNoclip()
    end)
end

StartPermanentNoclip()

-- ====================== GENERATOR ======================
local function getGeneratorPosition()
    if cachedGeneratorLocation then
        return cachedGeneratorLocation
    end

    if MapFolder then
        local tiles = MapFolder:FindFirstChild("Tiles")
        if tiles then
            for _, child in ipairs(tiles:GetChildren()) do
                if child.Name == "Generator" or child:FindFirstChild("Generator") then
                    cachedGeneratorLocation = child:GetPivot().Position
                    return cachedGeneratorLocation
                end
            end
        end
    end

    local fallback = Workspace:FindFirstChild("Generator", true)
    if fallback then
        cachedGeneratorLocation = fallback:GetPivot().Position
        return cachedGeneratorLocation
    end
    return nil
end

-- ====================== OPTIMIZED FUEL FINDER ======================
local function getClosestFuelPosition(currentPos)
    local bestTarget = nil
    local shortestDistance = math.huge
    local generatorLoc = getGeneratorPosition()

    if not DroppedItemsFolder then return nil end

    for _, item in ipairs(DroppedItemsFolder:GetChildren()) do
        if item.Name == "Fuel" and not excludeFuel[item] then
            local fuelPos = item:GetPivot().Position
            local heightDiff = fuelPos.Y - currentPos.Y

            -- Exclude tinggi
            if heightDiff > 2 then
                excludeFuel[item] = true
                continue
            end

            -- Exclude terlalu dekat generator
            if generatorLoc then
                local distToGen = (fuelPos - generatorLoc).Magnitude
                if distToGen < 50 then
                    excludeFuel[item] = true
                    continue
                end
            end

            local dist = (currentPos - fuelPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                bestTarget = item
            end
        end
    end

    return bestTarget
end

-- ====================== TELEPORT FUEL ======================
local function FuelTeleport(targetFuel)
    local generatorLoc = getGeneratorPosition()
    if not targetFuel or not generatorLoc then return end

    local fuelUnion = targetFuel:FindFirstChild("Union") or targetFuel.PrimaryPart
    local itemDrag = targetFuel:FindFirstChild("ItemDrag")
    local networkRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")

    if fuelUnion and networkRemote then
        pcall(function()
            networkRemote:FireServer(fuelUnion)
        end)
        task.wait(0.12)

        pcall(function()
            targetFuel:PivotTo(CFrame.new(generatorLoc) + Vector3.new(0, 1, 0))
        end)
        task.wait(0.15)
    end
end

-- ====================== CRAWL (bisa dihentikan) ======================
local function adaptiveCrawlTo(targetPos, humanoidRootPart)
    if not isFarming then return end

    local finalTarget = targetPos + Vector3.new(0, 3, 0)
    local BURST_SPEED = 75
    local SLOW_SPEED = 7
    local CLEARANCE_COOLDOWN = 0.5
    local SLOW_ZONE_DURATION = 0.35
    local lastWallDetectedTime = 0
    local lockedYHeight = humanoidRootPart.Position.Y

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character}

    while isFarming do
        if not humanoidRootPart or not humanoidRootPart.Parent then break end

        local deltaTime = RunService.Heartbeat:Wait()
        local currentPos = humanoidRootPart.Position
        local flatTarget = Vector3.new(finalTarget.X, lockedYHeight, finalTarget.Z)
        local remainingVector = flatTarget - currentPos
        local totalDistance = remainingVector.Magnitude

        if totalDistance <= 2.5 then
            humanoidRootPart.CFrame = CFrame.new(finalTarget)
            humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            break
        end

        local direction = remainingVector.Unit
        local rayResult = workspace:Raycast(currentPos, direction * 5, raycastParams)

        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            lastWallDetectedTime = os.clock()
        end

        local currentAllowedSpeed = SLOW_SPEED
        if os.clock() - lastWallDetectedTime >= CLEARANCE_COOLDOWN then
            local fraction = workspace:GetServerTimeNow() % 1.0
            if fraction < (1.0 - SLOW_ZONE_DURATION) then
                currentAllowedSpeed = BURST_SPEED
            end
        end

        local travel = math.min(currentAllowedSpeed * deltaTime, totalDistance)
        local nextPos = currentPos + direction * travel
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(nextPos.X, lockedYHeight, nextPos.Z))
    end
end

-- ====================== FARM LOOP ======================
local function startFarmingLoop()
    task.spawn(function()
        while isFarming do
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.5)
                continue
            end

            local fuel = getClosestFuelPosition(hrp.Position)

            if fuel and isFarming then
                print("[Farm] Moving to fuel...")
                adaptiveCrawlTo(fuel:GetPivot().Position, hrp)

                if isFarming and fuel and fuel.Parent then
                    FuelTeleport(fuel)
                    excludeFuel[fuel] = true
                    print("[Farm] Fuel berhasil dikirim ke generator!")
                end
            else
                -- Tidak ada fuel valid, tunggu sebentar
                task.wait(1.2)
            end

            task.wait(0.25)
        end
        print("[Farm] Stopped.")
    end)
end

-- ====================== GUI ======================
local function createGUI()
    -- Hapus GUI lama kalau ada
    if PlayerGui:FindFirstChild("FuelFarmGUI") then
        PlayerGui.FuelFarmGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FuelFarmGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Name = "Main"
    frame.Size = UDim2.new(0, 180, 0, 70)
    frame.Position = UDim2.new(1, -200, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "Fuel Farm"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local button = Instance.new("TextButton")
    button.Name = "Toggle"
    button.Size = UDim2.new(0.85, 0, 0, 28)
    button.Position = UDim2.new(0.075, 0, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    button.Text = "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button

    -- Toggle Logic
    button.MouseButton1Click:Connect(function()
        isFarming = not isFarming

        if isFarming then
            button.Text = "ON"
            button.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
            print("[GUI] Fuel Farm STARTED")
            startFarmingLoop()
        else
            button.Text = "OFF"
            button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            print("[GUI] Fuel Farm STOPPED")
        end
    end)
end

-- Jalankan GUI
createGUI()

print("Fuel Farm GUI loaded! Klik tombol untuk On/Off.")
