print("Loading")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local ContentProvider = game:GetService("ContentProvider")
while ContentProvider.RequestQueueSize > 0 do
    task.wait(0.5)
end

print("The game is loaded in. Wait more for things to fully load")
task.wait(6.0)
print("Complete! Starting the farm.")

-- SERVICES --
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG & REFERENCES --
local LocalPlayer = Players.LocalPlayer
local MapFolder = Workspace:FindFirstChild("Map")
local DroppedItemsFolder = Workspace:WaitForChild("DroppedItems")
local PlayAgainRemote = ReplicatedStorage.Remotes.Misc:FindFirstChild("VotePlayAgain")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local cachedGeneratorLocation = nil
local PermanentNoclipEnabled = true
local excludeFuel = {}

-- SAFETY: Evacuate if other players join
local function evacuateServer(reason)
    warn("[CRITICAL EVACUATION]: " .. reason)
    task.spawn(function()
        if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
            pcall(function()
                PlayAgainRemote:FireServer()
            end)
            print("ESCAPING BY PLAYING AGAIN")
            task.wait(1.0)
        end
        LocalPlayer:Kick("[WARNING] UNKNOWN PLAYER DETECTED!")
    end)
    error("Script execution terminated.")
end

-- PERMANENT NOCLIP
local function StartPermanentNoclip()
    local noclipConnection = nil

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

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        character = LocalPlayer.Character
        ConnectNoclip()
    end)
end

StartPermanentNoclip()

-- GET GENERATOR POSITION (cached)
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

    local fallbackGen = Workspace:FindFirstChild("Generator", true)
    if fallbackGen then
        cachedGeneratorLocation = fallbackGen:GetPivot().Position
        return cachedGeneratorLocation
    end

    return nil
end

-- OPTIMIZED CLOSEST FUEL FINDER (Single Pass)
local function getClosestFuelPosition(currentPos)
    local bestTarget = nil
    local shortestDistance = math.huge
    local generatorLoc = getGeneratorPosition()

    if not DroppedItemsFolder then
        return nil
    end

    for _, item in ipairs(DroppedItemsFolder:GetChildren()) do
        if item.Name == "Fuel" and not excludeFuel[item] then
            local fuelPos = item:GetPivot().Position
            local heightDiff = fuelPos.Y - currentPos.Y

            -- Exclude fuel yang terlalu tinggi
            if heightDiff > 2 then
                excludeFuel[item] = true
                continue
            end

            -- Exclude fuel yang terlalu dekat dengan generator (< 50 stud)
            if generatorLoc then
                local distToGen = (fuelPos - generatorLoc).Magnitude
                if distToGen < 50 then
                    excludeFuel[item] = true
                    continue
                end
            end

            -- Cari yang paling dekat
            local dist = (currentPos - fuelPos).Magnitude
            if dist < shortestDistance then
                shortestDistance = dist
                bestTarget = item
            end
        end
    end

    return bestTarget
end

-- TELEPORT FUEL KE GENERATOR
local function FuelTeleport(hrp, targetFuel)
    local generatorLoc = getGeneratorPosition()
    if not hrp or not targetFuel or not generatorLoc then return end

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

-- ADAPTIVE CRAWL (Movement)
local function adaptiveCrawlTo(targetPos, humanoidRootPart, character)
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

    local heartbeatEvent = RunService.Heartbeat

    while true do
        if not humanoidRootPart or not humanoidRootPart.Parent then break end

        local deltaTime = heartbeatEvent:Wait()
        local currentPos = humanoidRootPart.Position
        local flatTarget = Vector3.new(finalTarget.X, lockedYHeight, finalTarget.Z)
        local remainingVector = flatTarget - currentPos
        local totalDistance = remainingVector.Magnitude

        if totalDistance <= 2.0 then
            humanoidRootPart.CFrame = CFrame.new(finalTarget)
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
            humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            humanoidRootPart.Anchored = true
            task.wait(0.05)
            humanoidRootPart.Anchored = false
            break
        end

        local direction = remainingVector.Unit
        local rayResult = workspace:Raycast(currentPos, direction * 5, raycastParams)

        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            lastWallDetectedTime = os.clock()
        end

        local currentAllowedSpeed = SLOW_SPEED
        if os.clock() - lastWallDetectedTime >= CLEARANCE_COOLDOWN then
            local serverTime = workspace:GetServerTimeNow()
            local currentSecondFraction = serverTime % 1.0
            if currentSecondFraction < (1.0 - SLOW_ZONE_DURATION) then
                currentAllowedSpeed = BURST_SPEED
            end
        end

        local frameTravelDistance = currentAllowedSpeed * deltaTime
        if frameTravelDistance > totalDistance then
            frameTravelDistance = totalDistance
        end

        local nextPosition = currentPos + (direction * frameTravelDistance)
        local flattenedPosition = Vector3.new(nextPosition.X, lockedYHeight, nextPosition.Z)
        humanoidRootPart.CFrame = CFrame.new(flattenedPosition)
    end
end

-- MAIN PIPELINE
local function runPipeline()
    print("Free and Keyless, script is in https://pastebin.com/V0wHqZe4")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    print("[Pipeline] Initiating Complete Sequence...")
    task.wait(0.3)

    -- Kirim 8 Fuel
    for i = 1, 8 do
        local fuel = getClosestFuelPosition(humanoidRootPart.Position)
        if fuel then
            print("[Step " .. i .. "] Moving to fuel #" .. i)
            adaptiveCrawlTo(fuel:GetPivot().Position, humanoidRootPart, character)
            task.wait(0.3)
            FuelTeleport(humanoidRootPart, fuel)
            excludeFuel[fuel] = true
            task.wait(0.5)
        else
            print("[Step " .. i .. "] Tidak ada fuel valid lagi.")
            break
        end
    end

    -- Power Box
    print("[Step 9] Scanning for closest Power Box...")
    local powerBoxData = {}
    local interactionSuccess = false

    if MapFolder and MapFolder:FindFirstChild("Tiles") then
        for _, child in ipairs(MapFolder.Tiles:GetChildren()) do
            if child.Name == "Power Plant" then
                local powerBox = child:FindFirstChild("Power Box")
                if powerBox and powerBox:IsA("Model") then
                    table.insert(powerBoxData, {
                        Instance = powerBox,
                        Position = powerBox:GetPivot().Position
                    })
                end
            end
        end
    end

    if #powerBoxData > 0 then
        local currentPos = humanoidRootPart.Position
        table.sort(powerBoxData, function(a, b)
            return (currentPos - a.Position).Magnitude < (currentPos - b.Position).Magnitude
        end)

        local chosenBox = powerBoxData[1].Instance
        local finalBoxTarget = powerBoxData[1].Position

        print("[Step 9] Crawling to closest Power Box.")
        adaptiveCrawlTo(finalBoxTarget, humanoidRootPart, character)
        task.wait(0.5)

        if (humanoidRootPart.Position - finalBoxTarget).Magnitude < 15 then
            local prompt = chosenBox:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                for i = 1, 3 do
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration + 0.05)
                        prompt:InputHoldEnd()
                    end
                    task.wait(0.1)
                end
                print("[Pipeline] Interaction successfully forced!")
                interactionSuccess = true
            end
        end
    end

    -- Vote Play Again
    task.wait(0.5)
    if interactionSuccess then
        if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
            pcall(function()
                PlayAgainRemote:FireServer()
            end)
            print("[Play Again] Sequence executed successfully.")
        else
            warn("[Warning] VotePlayAgain remote path could not be found.")
        end
        print("Free and Keyless, script is in https://pastebin.com/V0wHqZe4")
    end
end

-- BACKGROUND SAFETY
if #Players:GetPlayers() > 1 then
    evacuateServer("Pre-existing player DETECTED!")
end

Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= LocalPlayer then
        evacuateServer("Player entry detected (" .. newPlayer.Name .. "). Executing immediate escape.")
    end
end)

-- Timeout 100 detik
task.spawn(function()
    task.wait(100.0)
    if PlayAgainRemote then
        print("[WARNING!] Match timeout reached. Restarting a run.")
        pcall(function()
            PlayAgainRemote:FireServer()
        end)
    end
end)

-- Auto restart kalau mati
if LocalPlayer.Character then
    LocalPlayer.Character:GetAttributeChangedSignal("Dead"):Connect(function()
        pcall(function() PlayAgainRemote:FireServer() end)
    end)
end

runPipeline()
