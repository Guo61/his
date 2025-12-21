local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local TEvent
pcall(function()
    TEvent = require(ReplicatedStorage.Shared.Core.TEvent)
end)

local Value
pcall(function()
    Value = require(ReplicatedStorage.Shared.Core.Value)
end)

local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()

local Settings = {
    ESP = false,
    Brightness = false,
    BrightnessValue = 5,
    Aura = false,
    AuraRange = 50,
    PushMonster = false,
    PushRadius = 30,
    PushStrength = 180,
    ESP_Mob = true,
    ESP_Item = true,
    ESP_Player = true,
    ESP_NPC = true,
    ESP_Container = true,
    ESP_ItemOutline = true,
    Speed = false,
    SpeedValue = 30,
    Noclip = false,
    NoStun = false,
    InfiniteStamina = false,
    Invincible = false,
    AutoHeal = false,
    AutoExtract = false,
    AutoExtractNoReturn = false,
    AutoPickupCash = false,
    AutoInteract = false,
    AutoInteractRange = 20,
    AutoOpenCrate = false,
    AutoOpenCabinet = false,
    AutoOpenOilBucket = false,
    AutoOpenFridge = false,
    AutoCollectItems = false,
    ThirdPerson = false,
    CameraFOV = 70,
    MonsterToPlayer = false,
    MonsterRotate = false,
    RotateRadius = 10,
    RotateSpeed = 2,
    MonsterToSelectedPlayer = false,
    SelectedTargetPlayer = "",
    Color_Item = Color3.fromRGB(60, 255, 100),
    Color_Container = Color3.fromRGB(255, 180, 60),
    Color_Mob = Color3.fromRGB(255, 60, 60),
    Color_Player = Color3.fromRGB(80, 160, 255),
    Color_NPC = Color3.fromRGB(255, 255, 80),
    Price_Min = 100,
    Price_Max = 5000,
    Color_Item_High = Color3.fromRGB(255, 255, 0),
}

local GameSystem = Workspace:FindFirstChild("GameSystem")
local GameObjects = {}

local GodModeActive = false
local GodModeConnections = {}
local MonsterRotation = {}
local BypassActive = false

local function Janse_Bypass_Init()
    BypassActive = true
    local bypassSuccess = false
    if not (getrawmetatable and newcclosure and checkcaller and getnamecallmethod) then
        return bypassSuccess
    end

    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if not checkcaller() then
            local info = debug.getinfo(2, "S")
            local src = info and info.source or ""
            
            if Value and t == Value then
                if src:find("Checker") or src:find("PlayerInPart") then
                    if k == "InteractHolding" then return function() return false end end
                    if k == "InteractTick" then return 0 end
                end
                if k == "PlayerState" then return "Alive" end
            end
        end
        return oldIndex(t, k)
    end)

    mt.__newindex = newcclosure(function(t, k, v)
        if not checkcaller() then
 
            if Value and t == Value and (k == "InteractTarget" or k == "InteractTick") then
                local info = debug.getinfo(2, "S")
                local src = info and info.source or ""
                if src:find("Checker") then return end 
            end
        end
        return oldNewIndex(t, k, v)
    end)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            if self.Name:find("Check") or self.Name:find("Detection") then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
    bypassSuccess = true

    task.spawn(function()
        while task.wait(1) and BypassActive do
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "Stop") and rawget(v, "_id") then
                        if v._part then v:Stop() end
                    end
                end
            end)
        end
    end)

    return bypassSuccess
end

local function Janse001()
    GameSystem = Workspace:FindFirstChild("GameSystem")
    if GameSystem then
        GameObjects = {
            Loot = GameSystem:FindFirstChild("Loots") and GameSystem.Loots:FindFirstChild("World"),
            Monster = GameSystem:FindFirstChild("Monsters"),
            Interact = GameSystem:FindFirstChild("InteractiveItem"),
            NPCs = GameSystem:FindFirstChild("NPCModels")
        }
    else
        GameObjects = {
            Loot = Workspace:FindFirstChild("Loots") or Workspace:FindFirstChild("World"),
            Monster = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Enemies"),
            Interact = Workspace:FindFirstChild("InteractiveItem"),
            NPCs = Workspace:FindFirstChild("NPCs") or Workspace:FindFirstChild("NPCModels")
        }
    end
    
    if not GameObjects.Loot then
         GameObjects.Loot = Workspace:FindFirstChild("Loots") or Workspace:FindFirstChild("World")
    end
    if not GameObjects.Monster then
        GameObjects.Monster = Workspace:FindFirstChild("Monsters") or Workspace:FindFirstChild("Enemies")
    end
end

Janse001()

local ESPCache = {}
local isTeleporting = false
local collectedItems = {}
local itemCollectionTimes = {}
local openedContainers = {}

local function Janse002(speed)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then 
        humanoid.WalkSpeed = speed or 16
    end
end

local function Janse003(state)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state then
                humanoid.CameraOffset = Vector3.new(0, 0, Settings.CameraFOV / -10)
            else
                humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
        end
        
        if state then
             LocalPlayer.CameraMode = Enum.CameraMode.Classic
        else
             LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end
end

local function Janse004()
    for _, part in pairs(Workspace:GetDescendants()) do 
        if part.Name == "Left4" and part:IsA("Model") and part:FindFirstChild("Check") then
            return part.Check, part
        end
        if (part.Name:find("Elevator") or part.Name:find("电梯")) and part:IsA("Model") and part.PrimaryPart then
            return part.PrimaryPart, part
        end
    end 
    return nil, nil
end

local function Janse005()
    local MainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if not MainGui then return false end
    
    local HomePage = MainGui:FindFirstChild("HomePage")
    if not HomePage then return false end
    
    if HomePage:FindFirstChild("HandsFull") and HomePage.HandsFull.Visible then
        return true
    end
    
    if HomePage:FindFirstChild("Bottom") then
        local filledSlots = 0
        for i = 1, 4 do
            local slot = HomePage.Bottom:FindFirstChild(tostring(i))
            if slot and slot:GetAttribute("uid") and slot:GetAttribute("uid") ~= "" then
                filledSlots = filledSlots + 1
            end
        end
        return filledSlots >= 4
    end
    
    return false
end

local function Janse006()
    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if not mainGui then return true end
    
    local homePage = mainGui:FindFirstChild("HomePage")
    if not homePage then return true end
    
    local bottom = homePage:FindFirstChild("Bottom")
    if not bottom then return true end
    
    local handSlot = bottom:FindFirstChild("0")
    if not handSlot then return true end
    
    return not (handSlot:GetAttribute("uid") and handSlot:GetAttribute("uid") ~= "")
end

local function Janse007()
    local mainGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if not mainGui then return true end
    
    local homePage = mainGui:FindFirstChild("HomePage")
    if not homePage then return true end
    
    local bottom = homePage:FindFirstChild("Bottom")
    if not bottom then return true end
    
    for i = 1, 4 do
        local slot = bottom:FindFirstChild(tostring(i))
        if slot and slot:GetAttribute("uid") and slot:GetAttribute("uid") ~= "" then
            return false
        end
    end
    
    return true
end

local function Janse008(hrp, targetCFrame, duration)
    if not hrp or not targetCFrame then return end
    
    local startCFrame = hrp.CFrame
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            hrp.CFrame = targetCFrame
            connection:Disconnect()
            return
        end
        
        local alpha = elapsed / duration
        hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
    end)
    
    task.wait(duration)
    if connection then connection:Disconnect() end
    hrp.CFrame = targetCFrame
end

local function Janse009(humanoidRootPart, returnCFrame)
    if not humanoidRootPart then return end
    humanoidRootPart.CFrame = CFrame.new(0, 500, 0)
    task.wait(0.2)
    humanoidRootPart.CFrame = returnCFrame
end

local function Janse010(pricedOnly)
    local items = {}
    
    local elevatorPart, elevatorModel = Janse004()
    local elevatorPosition = elevatorPart and elevatorPart.Position
    
    local function processLoot(lootModel)
        if not lootModel or not lootModel:IsA("Model") or not lootModel.PrimaryPart then return end
        
        local lootPosition = lootModel.PrimaryPart.Position
        
        if elevatorPosition and (lootPosition - elevatorPosition).Magnitude < 20 then
            return
        end
        
        local monsterSources = {
            GameObjects.Monster,
            Workspace:FindFirstChild("Enemies"),
            Workspace:FindFirstChild("Monsters"),
            Workspace:FindFirstChild("Mobs")
        }
        
        local tooCloseToMonster = false
        for _, source in pairs(monsterSources) do
            if source then
                for _, monster in pairs(source:GetChildren()) do
                    if monster:IsA("Model") then
                        local monsterHRP = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                        if monsterHRP then
                            local distanceToMonster = (lootPosition - monsterHRP.Position).Magnitude
                            if distanceToMonster <= 5 then
                                tooCloseToMonster = true
                                break
                            end
                        end
                    end
                end
            end
            if tooCloseToMonster then break end
        end
        
        if tooCloseToMonster then return end
        
        local isPriced = false
        local priceValue = 0
        local priceText = ""
        
        local lootUI = lootModel:FindFirstChild("LootUI", true)
        if lootUI then
            local frame = lootUI:FindFirstChild("Frame")
            if frame then
                local priceLabel = frame:FindFirstChild("Price")
                if priceLabel and priceLabel.Text and priceLabel.Text ~= "?" then
                    isPriced = true
                    priceText = priceLabel.Text
                    local _, numStr = priceText:find("P%s*(%d+)")
                    if numStr then
                        priceValue = tonumber(numStr) or 0
                    end
                end
            end
        end

        local shouldInclude = false
        if pricedOnly and isPriced then
            shouldInclude = true
        elseif not pricedOnly then
             shouldInclude = true
        end
        
        if shouldInclude then
            table.insert(items, {
                Model = lootModel,
                PrimaryPart = lootModel.PrimaryPart,
                ItemName = lootModel.Name,
                ValueText = priceText or "0",
                Value = priceValue,
            })
        end
    end
    
    if GameObjects.Loot then
        for _, obj in pairs(GameObjects.Loot:GetChildren()) do
            processLoot(obj)
        end
    end

    local uniqueItems = {}
    local seen = {}
    for _, item in ipairs(items) do
        if item.PrimaryPart and not seen[item.PrimaryPart] then
            table.insert(uniqueItems, item)
            seen[item.PrimaryPart] = true
        end
    end

    return uniqueItems
end

local function Janse011(item)
    if item.Model and item.PrimaryPart then
        local modelId = item.Model.Name .. "_" .. tostring(item.Model:GetFullName())
        return modelId .. "_" .. tostring(math.floor(item.PrimaryPart.Position.X)) .. "_" .. 
               tostring(math.floor(item.PrimaryPart.Position.Y)) .. "_" .. 
               tostring(math.floor(item.PrimaryPart.Position.Z))
    end
    return tostring(item)
end

local function Janse012(item)
    if not item or not item.Model or not item.PrimaryPart then return false end
    
    local itemKey = Janse011(item)
    local currentTime = tick()
    
    if collectedItems[itemKey] then
        if currentTime - itemCollectionTimes[itemKey] > 15 then
            collectedItems[itemKey] = nil
            itemCollectionTimes[itemKey] = nil
        else
            return false
        end
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local playerPosition = humanoidRootPart.Position
    local playerForward = humanoidRootPart.CFrame.LookVector
    
    local targetDistance = 5
    local targetOffset = Vector3.new(0, 2, 0)
    
    local targetPosition = playerPosition + (playerForward * targetDistance) + targetOffset
    
    local randomRotationY = math.random(0, 360)
    local targetCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, math.rad(randomRotationY), 0)
    
    local success = pcall(function()
        if item.Model:IsA("Model") then
            local modelParts = {}
            for _, part in pairs(item.Model:GetChildren()) do
                if part:IsA("BasePart") then
                    table.insert(modelParts, part)
                end
            end
            
            if #modelParts > 0 then
                for _, part in pairs(modelParts) do
                    part.Anchored = false
                    part.CanCollide = true
                    part.CFrame = targetCFrame
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.Velocity = Vector3.new(0, 0, 0)
                    part.RotVelocity = Vector3.new(0, 0, 0)
                end
                
                if item.Model.PrimaryPart then
                    item.Model:PivotTo(targetCFrame)
                end
            end
            
            collectedItems[itemKey] = true
            itemCollectionTimes[itemKey] = currentTime
            
            task.delay(0.05, function()
                pcall(function()
                    if item.Model and item.Model.Parent then
                        for _, part in pairs(item.Model:GetChildren()) do
                            if part:IsA("BasePart") then
                                if part.Anchored then
                                    part.Anchored = false
                                end
                                if not part.CanCollide then
                                    part.CanCollide = true
                                end
                            end
                        end
                    end
                end)
            end)
            
            task.delay(0.1, function()
                pcall(function()
                    if item.Model and item.Model.Parent then
                        local microOffsetX = math.random(-1, 1)
                        local microOffsetY = math.random(-0.5, 0.5)
                        local microOffsetZ = math.random(-1, 1)
                        local microAdjustment = Vector3.new(microOffsetX, microOffsetY, microOffsetZ)
                        
                        for _, part in pairs(item.Model:GetChildren()) do
                            if part:IsA("BasePart") then
                                local currentPosition = part.Position
                                part.CFrame = CFrame.new(currentPosition + microAdjustment)
                                
                                local randomForceX = math.random(-30, 30)
                                local randomForceY = math.random(0, 10)
                                local randomForceZ = math.random(-30, 30)
                                part:ApplyImpulse(Vector3.new(randomForceX, randomForceY, randomForceZ))
                            end
                        end
                    end
                end)
            end)
            
            return true
        elseif item.PrimaryPart:IsA("BasePart") then
            item.PrimaryPart.Anchored = false
            item.PrimaryPart.CanCollide = true
            item.PrimaryPart.CFrame = targetCFrame
            item.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            item.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
            item.PrimaryPart.RotVelocity = Vector3.new(0, 0, 0)
            
            collectedItems[itemKey] = true
            itemCollectionTimes[itemKey] = currentTime
            
            task.delay(0.05, function()
                pcall(function()
                    if item.PrimaryPart and item.PrimaryPart.Parent then
                        if item.PrimaryPart.Anchored then
                            item.PrimaryPart.Anchored = false
                        end
                        if not item.PrimaryPart.CanCollide then
                            item.PrimaryPart.CanCollide = true
                        end
                    end
                end)
            end)
            
            task.delay(0.1, function()
                pcall(function()
                    if item.PrimaryPart and item.PrimaryPart.Parent then
                        local microOffsetX = math.random(-1, 1)
                        local microOffsetY = math.random(-0.5, 0.5)
                        local microOffsetZ = math.random(-1, 1)
                        local microAdjustment = Vector3.new(microOffsetX, microOffsetY, microOffsetZ)
                        item.PrimaryPart.CFrame = item.PrimaryPart.CFrame + microAdjustment
                        
                        local randomForceX = math.random(-30, 30)
                        local randomForceY = math.random(0, 10)
                        local randomForceZ = math.random(-30, 30)
                        item.PrimaryPart:ApplyImpulse(Vector3.new(randomForceX, randomForceY, randomForceZ))
                    end
                end)
            end)
            
            return true
        end
    end)
    
    if success then
        task.wait(0.08)
        pcall(function()
            if item.Model and item.Model.Parent then
                local modelPrimaryPart = item.Model.PrimaryPart or item.PrimaryPart
                if modelPrimaryPart then
                    local itemPosition = modelPrimaryPart.Position
                    local distanceToPlayer = (itemPosition - playerPosition).Magnitude
                    
                    if distanceToPlayer > 10 then
                        local newPosition = playerPosition + Vector3.new(math.random(-3, 3), 2, math.random(-3, 3))
                        
                        for _, part in pairs(item.Model:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CFrame = CFrame.new(newPosition)
                                part.Anchored = false
                            end
                        end
                    end
                end
            end
        end)
    end
    
    return success
end

local function Janse013()
    local lastValidCFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
    
    while task.wait(0.05) do
        if not Settings.AutoPickupCash or not LocalPlayer.Character then continue end
        
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        local isHandsFull = Janse005() or not Janse006() 

        if isHandsFull then
            
            local elevatorPart, _ = Janse004()
            if not elevatorPart then 
                task.wait(1) 
                continue 
            end
            
            local elevatorCFrame = elevatorPart.CFrame + Vector3.new(0, 3, 0)
            
            Janse008(humanoidRootPart, elevatorCFrame, 0.5)
            task.wait(0.5)
            
            if not Janse007() or not Janse006() then
                Janse009(humanoidRootPart, elevatorCFrame) 
                task.wait(1)
            end
            
            if Janse007() and Janse006() and lastValidCFrame then
                Janse008(humanoidRootPart, lastValidCFrame, 0.5)
                task.wait(0.2)
            else
                task.wait(1) 
                continue 
            end
        end
        
        lastValidCFrame = humanoidRootPart.CFrame
        
        local pricedItems = Janse010(true)
        
        if #pricedItems == 0 then
            local elevatorPart, _ = Janse004()
            if elevatorPart then
                local elevatorCFrame = elevatorPart.CFrame + Vector3.new(0, 3, 0)
                Janse008(humanoidRootPart, elevatorCFrame, 0.5)
                task.wait(1)
                continue
            end
        end
        
        if #pricedItems > 0 then
            table.sort(pricedItems, function(a, b)
                return (humanoidRootPart.Position - a.PrimaryPart.Position).Magnitude < (humanoidRootPart.Position - b.PrimaryPart.Position).Magnitude
            end)

            local targetItem = pricedItems[1]
            local targetPart = targetItem.PrimaryPart
            
            local targetPosition = targetPart.Position + Vector3.new(0, 5, 0)
            humanoidRootPart.CFrame = CFrame.new(targetPosition, targetPart.Position)
            task.wait(0.02)
            
            local interactObj = targetItem.Model 
            
            for i = 1, 5 do
                if TEvent then
                    pcall(function()
                        TEvent.FireRemote("Interactable", interactObj)
                    end)
                end
                
                local prompt = interactObj:FindFirstChildOfClass("ProximityPrompt", true)
                local clickDetector = interactObj:FindFirstChildOfClass("ClickDetector", true)
                
                if prompt and prompt.Enabled then
                    fireproximityprompt(prompt)
                elseif clickDetector then
                    fireclickdetector(clickDetector)
                end
                task.wait(0.02)
            end
            
            task.wait(0.3)
        end
    end
end

local function Janse014()
    while task.wait(0.05) do
        if (Settings.AutoInteract or Settings.AutoOpenCrate or Settings.AutoOpenCabinet or Settings.AutoOpenOilBucket or Settings.AutoOpenFridge) and LocalPlayer.Character then
            local searchRoot = GameObjects.Interact or Workspace
            
            for _, obj in pairs(searchRoot:GetDescendants()) do
                if obj:IsA("Model") and (obj:HasTag("Interactable") or obj:FindFirstChildOfClass("ProximityPrompt", true) or obj:FindFirstChildOfClass("ClickDetector", true)) and obj.Name ~= "Cash" then
                    local isSpecificContainer = false
                    local objName = obj.Name:lower()
                    local objId = tostring(obj:GetFullName())
                    
                    if Settings.AutoOpenCrate and objName:find("crate") then isSpecificContainer = true end
                    if Settings.AutoOpenCabinet and objName:find("cabinet") then isSpecificContainer = true end
                    if Settings.AutoOpenOilBucket and (objName:find("oil") or objName:find("bucket")) then isSpecificContainer = true end
                    if Settings.AutoOpenFridge and objName:find("fridge") then isSpecificContainer = true end
                    
                    local shouldInteract = Settings.AutoInteract or (isSpecificContainer and not openedContainers[objId])
                    
                    if shouldInteract then
                        
                        if isSpecificContainer and not openedContainers[objId] then
                             openedContainers[objId] = tick()
                        end
                        
                        for i = 1, 3 do
                            if TEvent then
                                pcall(function()
                                    TEvent.FireRemote("Interactable", obj)
                                end)
                            end
                            
                            local prompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                            local clickDetector = obj:FindFirstChildOfClass("ClickDetector", true)
                            
                            if prompt and prompt.Enabled then
                                fireproximityprompt(prompt)
                            elseif clickDetector then
                                fireclickdetector(clickDetector)
                            end
                        end
                        
                        task.wait(0.01)
                    end
                end
            end
        end
    end
end

local function Janse015()
    while task.wait(1) do
        if Settings.AutoCollectItems then
            local pricedItems = Janse010(false)
            if #pricedItems == 0 then
                local elevatorPart, _ = Janse004()
                local character = LocalPlayer.Character
                if elevatorPart and character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local elevatorCFrame = elevatorPart.CFrame + Vector3.new(0, 3, 0)
                        Janse008(humanoidRootPart, elevatorCFrame, 0.5)
                        task.wait(1)
                    end
                end
            else
                for _, item in pairs(pricedItems) do
                    if item.Model and item.Model.Parent then
                        local success = Janse012(item)
                        if success then
                            task.wait(0.1)
                        else
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end

local function Janse016()
    while task.wait(0.3) do
        if Settings.Aura and LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local allMonsters = {}
                local sources = {
                    GameObjects.Monster,
                    Workspace:FindFirstChild("Enemies"),
                    Workspace:FindFirstChild("Monsters"),
                    Workspace:FindFirstChild("Mobs")
                }
                
                for _, source in pairs(sources) do
                    if source then
                        for _, monster in pairs(source:GetChildren()) do
                            if monster:IsA("Model") then
                                local monsterHRP = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                                local humanoid = monster:FindFirstChild("Humanoid")
                                
                                if monsterHRP and humanoid and humanoid.Health > 0 then 
                                    table.insert(allMonsters, {HRP = monsterHRP, Humanoid = humanoid})
                                end
                            end
                        end
                    end
                end
                
                for _, monster in pairs(allMonsters) do 
                    local distance = (humanoidRootPart.Position - monster.HRP.Position).Magnitude 
                    if distance <= Settings.AuraRange then 
                        pcall(function()
                            humanoidRootPart.CFrame = monster.HRP.CFrame * CFrame.new(0, 0, 2)
                        end)
                        
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") 
                        if tool then 
                            tool:Activate() 
                            VirtualUser:CaptureController() 
                            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame) 
                            task.wait(0.1)
                            VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                        end 
                    end 
                end 
            end 
        end 
    end 
end

local function Janse017()
    while task.wait() do
        if Settings.PushMonster and LocalPlayer.Character then
            local HRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if HRP then
                local sources = {
                    GameObjects.Monster,
                    Workspace:FindFirstChild("Enemies"),
                    Workspace:FindFirstChild("Monsters"),
                    Workspace:FindFirstChild("Mobs")
                }
                
                for _, source in pairs(sources) do
                    if source then
                        for _, m in pairs(source:GetChildren()) do
                            local MHRP = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                            if MHRP and MHRP:IsA("BasePart") then
                                local dist = (MHRP.Position - HRP.Position).Magnitude
                                if dist <= Settings.PushRadius then
                                    local dir = (MHRP.Position - HRP.Position).Unit
                                    pcall(function()
                                        MHRP.AssemblyLinearVelocity = dir * Settings.PushStrength
                                        MHRP.Velocity = dir * Settings.PushStrength
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Janse018()
    while task.wait(1.5) do
        if Settings.AutoHeal and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth * 0.3 then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local healingItem = backpack and (backpack:FindFirstChild("Bandage") or backpack:FindFirstChild("Medkit"))

                if healingItem then 
                    humanoid:EquipTool(healingItem) 
                    task.wait(0.1)
                    healingItem:Activate() 
                    task.wait(0.5)
                end 
            end 
        end
    end 
end

local function Janse019()
    while task.wait(1) do
        if (Settings.AutoExtract or Settings.AutoExtractNoReturn) and LocalPlayer.Character and not isTeleporting then 
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and Janse005() then
                isTeleporting = true 
                local lastPosition = humanoidRootPart.CFrame 
                
                local elevator = Janse004()
                
                if elevator then
                    local elevatorCFrame = elevator.CFrame + Vector3.new(0, 3, 0)
                    Janse008(humanoidRootPart, elevatorCFrame, 0.5)
                    
                    task.wait(2)
                    
                    if not Janse007() or not Janse006() then
                        Janse009(humanoidRootPart, elevatorCFrame)
                        task.wait(1.5)
                    end
                    
                    if Janse007() and Janse006() then
                        if Settings.AutoExtract and not Settings.AutoExtractNoReturn then
                            Janse008(humanoidRootPart, lastPosition, 0.5)
                        end
                    end
                end
                
                isTeleporting = false 
            end
        end
    end
end

local function Janse020()
    if Settings.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

local function Janse021()
    if Settings.NoStun and LocalPlayer.Character then
        for _, object in pairs(LocalPlayer.Character:GetChildren()) do
            if object.Name:lower():find("stun") or object.Name:lower():find("slow") or object.Name:lower():find("ragdoll") then
                object:Destroy()
            end
        end
    end
end

local function Janse022(price)
    local minPrice = Settings.Price_Min
    local maxPrice = Settings.Price_Max
    
    local baseColor = Settings.Color_Item 
    local highColor = Settings.Color_Item_High 
    
    if maxPrice <= minPrice then 
        return baseColor 
    end
    
    local clampedPrice = math.clamp(price, minPrice, maxPrice)
    local alpha = (clampedPrice - minPrice) / (maxPrice - minPrice)
    
    return baseColor:Lerp(highColor, alpha)
end

local function Janse023()
    if not Settings.ESP then 
        for object, cache in pairs(ESPCache) do
            if cache.Highlight then cache.Highlight:Destroy() end
            if cache.Billboard then cache.Billboard:Destroy() end
            ESPCache[object] = nil
        end
        return 
    end
    
    local objectsToHighlight = {}
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    local function getDistance(part) 
        return (HRP.Position - part.Position).Magnitude 
    end
    
    local function createBillboard(part, text, color)
        local billboard = Instance.new("BillboardGui") 
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 150, 0, 20) 
        billboard.AlwaysOnTop = true 
        billboard.StudsOffset = Vector3.new(0, 2.5, 0) 
        billboard.Parent = CoreGui 
        
        local textLabel = Instance.new("TextLabel") 
        textLabel.Size = UDim2.new(1, 0, 1, 0) 
        textLabel.BackgroundTransparency = 1 
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 12 
        textLabel.Text = text
        textLabel.TextColor3 = color
        textLabel.Parent = billboard 
        return billboard
    end
    
    local function createHighlight(adornee, color, useHighlight)
        local highlight = Instance.new("Highlight") 
        highlight.Adornee = adornee 
        highlight.OutlineColor = Color3.new(1, 1, 1) 
        highlight.OutlineTransparency = 0.3 
        highlight.FillTransparency = 0.75 
        highlight.FillColor = color 
        highlight.Enabled = useHighlight 
        highlight.Parent = CoreGui 
        return highlight
    end

    if Settings.ESP_Mob then
        local monsterSources = {
            GameObjects.Monster, 
            Workspace:FindFirstChild("Enemies"), 
            Workspace:FindFirstChild("Monsters"), 
            Workspace:FindFirstChild("Mobs")
        }
        for _, source in pairs(monsterSources) do
            if source then
                for _, monster in pairs(source:GetChildren()) do
                    if monster:IsA("Model") then
                        local root = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                        local humanoid = monster:FindFirstChild("Humanoid")
                        if root and humanoid and humanoid.Health > 0 then
                            objectsToHighlight[monster] = { 
                                Adornee = monster, 
                                PrimaryPart = root,
                                Color = Settings.Color_Mob, 
                                Text = monster.Name .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "] " .. math.floor(getDistance(root)) .. "m", 
                                UseHighlight = true 
                            }
                        end
                    end
                end
            end
        end
    end
    
    if Settings.ESP_Item and GameObjects.Loot then 
        for _, obj in pairs(GameObjects.Loot:GetChildren()) do
            if obj:IsA("Model") and obj.PrimaryPart then
                local lootModel = obj
                local itemName = lootModel.Name
                local priceText = ""
                local priceValue = 0
                
                local lootUI = lootModel:FindFirstChild("LootUI", true)
                if lootUI then
                    local frame = lootUI:FindFirstChild("Frame")
                    if frame then
                        local nameLabel = frame:FindFirstChild("ItemName")
                        local priceLabel = frame:FindFirstChild("Price")
                        if nameLabel and priceLabel then
                            itemName = nameLabel.Text
                            priceText = priceLabel.Text
                            local _, numStr = priceText:find("P%s*(%d+)")
                            if numStr then priceValue = tonumber(numStr) or 0 end
                        end
                    end
                end
                
                local priceDisplay = priceText ~= "?" and " [" .. priceText .. "]" or ""
                local color = Janse022(priceValue) 
                
                objectsToHighlight[lootModel] = { 
                    Adornee = lootModel, 
                    PrimaryPart = lootModel.PrimaryPart,
                    Color = color, 
                    Text = itemName .. priceDisplay .. " " .. math.floor(getDistance(lootModel.PrimaryPart)) .. "m",
                    UseHighlight = Settings.ESP_ItemOutline 
                } 
            end
        end
    end 
    
    if Settings.ESP_Container and GameObjects.Interact then 
        for _, container in pairs(GameObjects.Interact:GetChildren()) do 
            if container:IsA("Model") and container.PrimaryPart then 
                objectsToHighlight[container] = { 
                    Adornee = container, 
                    PrimaryPart = container.PrimaryPart, 
                    Color = Settings.Color_Container, 
                    Text = container.Name .. " " .. math.floor(getDistance(container.PrimaryPart)) .. "m", 
                    UseHighlight = true 
                } 
            end 
        end 
    end 
    
    if Settings.ESP_NPC and GameObjects.NPCs then 
        for _, npc in pairs(GameObjects.NPCs:GetChildren()) do 
            if npc:IsA("Model") and npc.PrimaryPart then 
                objectsToHighlight[npc] = { 
                    Adornee = npc, 
                    PrimaryPart = npc.PrimaryPart, 
                    Color = Settings.Color_NPC, 
                    Text = npc.Name .. " " .. math.floor(getDistance(npc.PrimaryPart)) .. "m", 
                    UseHighlight = true 
                } 
            end 
        end 
    end 
    
    if Settings.ESP_Player then 
        for _, player in pairs(Players:GetPlayers()) do 
            if player ~= LocalPlayer and player.Character then 
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    objectsToHighlight[player.Character] = { 
                        Adornee = player.Character, 
                        PrimaryPart = hrp, 
                        Color = Settings.Color_Player, 
                        Text = player.Name .. " " .. math.floor(getDistance(hrp)) .. "m", 
                        UseHighlight = true 
                    }
                end
            end 
        end 
    end 
    
    for object, data in pairs(objectsToHighlight) do 
        local cache = ESPCache[object]
        
        if not cache then 
            cache = {}
            ESPCache[object] = cache
            
            cache.Billboard = createBillboard(data.PrimaryPart, data.Text, data.Color)
            if data.UseHighlight then
                cache.Highlight = createHighlight(data.Adornee, data.Color, true)
            end
        end
        
        if cache.Billboard and cache.Billboard:FindFirstChild("TextLabel") then 
            cache.Billboard.TextLabel.Text = data.Text 
            cache.Billboard.TextLabel.TextColor3 = data.Color 
        end 

        if data.UseHighlight and cache.Highlight then
            cache.Highlight.FillColor = data.Color 
            cache.Highlight.Enabled = true
            cache.Highlight.Adornee = data.Adornee 
        elseif cache.Highlight then
            cache.Highlight.Enabled = false
        end
    end 
    
    for object, cache in pairs(ESPCache) do 
        if not objectsToHighlight[object] or (object:IsA("Instance") and not object.Parent) then 
            if cache.Highlight then 
                cache.Highlight:Destroy() 
            end 
            if cache.Billboard then 
                cache.Billboard:Destroy() 
            end 
            ESPCache[object] = nil 
        end 
    end 
end

local function hookStamina()
    local originalPreRenderFunction
    for _, connection in ipairs(getconnections(RunService.PreRender)) do
        local func = connection.Function
        if func and debug.info(func, "s"):find("Stamina") then
            originalPreRenderFunction = func
            connection:Disable()
            break
        end
    end
    
    RunService.PreRender:Connect(function(dt)
        if Value and typeof(Value.Stamina) == "number" then
            Value.Stamina = 1000
        end
        if Value and typeof(Value.Run) == "boolean" then
            Value.Run = true
        end
    end)
    
    if Value then
        Value.Stamina = 1000
        Value.StaminaConsumeMutil = 0
        if typeof(Value.Run) == "boolean" then
            Value.Run = true
        end
    end
end

local function Janse025(state)
    Settings.InfiniteStamina = state
    if state then
        local success, err = pcall(hookStamina)
        if not success then
            RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Value and Value.Stamina then
                        Value.Stamina = 1000
                    end
                end)
            end)
        end
    elseif Value and Value.StaminaConsumeMutil == 0 then
        Value.StaminaConsumeMutil = 1
    end
end

local function Janse026(state)
    Settings.Invincible = state
    if state then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local clone = character.HumanoidRootPart:Clone()
            clone.Parent = character
        end
    else
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Head") then
            character.Head:Destroy()
        end
    end
end

local function Janse027()
    while task.wait(0.1) do
        if Settings.MonsterToSelectedPlayer and Settings.SelectedTargetPlayer ~= "" then
            pcall(function()
                local targetPlayer = Players:FindFirstChild(Settings.SelectedTargetPlayer)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    local monsterFolders = {Workspace:FindFirstChild("Monsters"), Workspace:FindFirstChild("Enemies"), GameObjects.Monster}
                    for _, folder in pairs(monsterFolders) do
                        if folder then
                            for _, monster in pairs(folder:GetChildren()) do
                                local mHRP = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                                if mHRP then
                                    mHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 2, 0)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end

local function Janse028()
    while task.wait(0.05) do
        if Settings.MonsterRotate and LocalPlayer.Character then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local center = hrp.Position
                local currentTime = tick() * Settings.RotateSpeed
                
                local sources = {
                    GameObjects.Monster,
                    Workspace:FindFirstChild("Enemies"),
                    Workspace:FindFirstChild("Monsters"),
                    Workspace:FindFirstChild("Mobs")
                }
                
                local monsterIndex = 0
                for _, source in pairs(sources) do
                    if source then
                        for _, monster in pairs(source:GetChildren()) do
                            if monster:IsA("Model") then
                                monsterIndex = monsterIndex + 1
                                local monsterHRP = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
                                if monsterHRP then
                                    local angle = currentTime + (monsterIndex * (2 * math.pi / 10))
                                    local x = math.cos(angle) * Settings.RotateRadius
                                    local z = math.sin(angle) * Settings.RotateRadius
                                    local targetPosition = center + Vector3.new(x, 0, z)
                                    
                                    MonsterRotation[monster] = MonsterRotation[monster] or {}
                                    MonsterRotation[monster].angle = angle
                                    MonsterRotation[monster].radius = Settings.RotateRadius
                                    
                                    monsterHRP.CFrame = CFrame.new(targetPosition, center)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Janse029()
    local elevatorPart, elevatorModel = Janse004()
    if elevatorPart and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local elevatorCFrame = elevatorPart.CFrame + Vector3.new(0, 3, 0)
            Janse008(hrp, elevatorCFrame, 0.5)
            return true
        end
    end
    return false
end

local function Janse030()
    while task.wait() do
        if Settings.AutoInteract and TEvent and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in workspace:GetDescendants() do
                    if obj:HasTag("Interactable") and obj:GetAttribute("en") then
                        local dst = obj:GetAttribute("sz") or Settings.AutoInteractRange
                        local prt = obj:IsA("Model") and obj.PrimaryPart or obj:IsA("BasePart") and obj
                        if prt and (hrp.Position - prt.Position).Magnitude <= dst then
                            TEvent.FireRemote("Interactable", obj)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.Speed then
        Janse002(Settings.SpeedValue)
    end
    if Settings.ThirdPerson then
        Janse003(true)
    end
    if Settings.InfiniteStamina then
        Janse025(true)
    end
    if Settings.Invincible then
        Janse026(true)
    end
end)

RunService.RenderStepped:Connect(function()
    Janse023()
    
    if Camera and Camera.FieldOfView ~= Settings.CameraFOV then
        Camera.FieldOfView = Settings.CameraFOV
    end
    
    if Settings.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Settings.SpeedValue then 
            humanoid.WalkSpeed = Settings.SpeedValue 
        end
    end
    
    if Settings.ThirdPerson and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.CameraOffset.Z == 0 then
             humanoid.CameraOffset = Vector3.new(0, 0, Settings.CameraFOV / -10)
        end
    end
end)

RunService.Stepped:Connect(function()
    Janse021()
    Janse020()
end)

task.spawn(Janse013)
task.spawn(Janse018)
task.spawn(Janse019) 
task.spawn(Janse016)
task.spawn(Janse017)
task.spawn(Janse014)
task.spawn(Janse015)
task.spawn(Janse027)
task.spawn(Janse028)
task.spawn(Janse030)

task.spawn(function()
    task.wait(3)
    Janse001()
    while task.wait(10) do
        Janse001()
    end
end)

local MenuKey = "LeftAlt"
local Notifier = Compkiller.newNotify()
local ConfigManager = Compkiller:ConfigManager({
	Directory = "Deadly-Deliver",
	Config = "亡命速递-配置"
})

Compkiller:Loader("rbxassetid://120245531583106" , 1.5).yield()

local Window = Compkiller.new({
	Name = "亡命速递 | 江",
	Keybind = MenuKey,
	Logo = "rbxassetid://120245531583106",
    Size = UDim2.new(0.45, 0, 0.60, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
	TextSize = 15,
})

local Watermark = Window:Watermark()
Watermark:AddText({ Icon = "user", Text = LocalPlayer.Name, })
local Time = Watermark:AddText({ Icon = "timer", Text = "TIME", })
task.spawn(function()
	while true do task.wait()
		Time:SetText(Compkiller:GetTimeNow())
	end
end)

Window:DrawCategory({ Name = "Deadly-Deliver" })
local MainTab = Window:DrawTab({
	Name = "主要功能",
	Icon = "zap",
	EnableScrolling = true
})

local BypassSection = MainTab:DrawSection({
    Name = "反作弊绕过",
    Position = 'left'	
})

BypassSection:AddToggle({
    Name = "启用反作弊绕过",
    Flag = "Toggle_EnableBypass",
    Default = true,
    Callback = function(state)
        if state then
            BypassActive = true
            Notifier.new({
                Title = "反作弊绕过",
                Content = "反作弊绕过已启用",
                Duration = 3,
                Icon = "shield-check"
            })
        else
            BypassActive = false
            Notifier.new({
                Title = "反作弊绕过",
                Content = "反作弊绕过已禁用",
                Duration = 3,
                Icon = "shield-off"
            })
        end
    end,
})

BypassSection:AddButton({
    Name = "刷新绕过系统",
    Callback = function()
        Janse_Bypass_Init()
    end,
})

BypassSection:AddButton({
    Name = "强制清理检测器",
    Callback = function()
        pcall(function()
            local cleaned = 0
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and (rawget(v, "Stop") or rawget(v, "Check") or rawget(v, "SetParams")) then
                    pcall(function()
                        if rawget(v, "Stop") then v:Stop() end
                        if rawget(v, "Destroy") then v:Destroy() end
                        cleaned = cleaned + 1
                    end)
                end
            end
            
            Notifier.new({
                Title = "清理完成",
                Content = "已清理 " .. cleaned .. " 个检测器",
                Duration = 5,
                Icon = "trash-2"
            })
        end)
    end,
})

local MovementSection = MainTab:DrawSection({
	Name = "移动功能",
	Position = 'left'	
})

MovementSection:AddToggle({
	Name = "速度启用",
	Flag = "Toggle_Speed",
	Default = Settings.Speed,
	Callback = function(state)
        Settings.Speed = state
        Janse002(state and Settings.SpeedValue or 16)
	end,
})

MovementSection:AddSlider({
	Name = "移动速度",
	Min = 16,
	Max = 100,
	Default = Settings.SpeedValue,
	Round = 0,
	Flag = "Slider_SpeedValue",
	Callback = function(value)
        Settings.SpeedValue = value
        if Settings.Speed then
            Janse002(value)
        end
	end
})

MovementSection:AddToggle({
	Name = "穿墙",
	Flag = "Toggle_Noclip",
	Default = Settings.Noclip,
	Callback = function(state)
        Settings.Noclip = state
	end,
})

MovementSection:AddToggle({
	Name = "防眩晕/防慢速",
	Flag = "Toggle_NoStun",
	Default = Settings.NoStun,
	Callback = function(state)
        Settings.NoStun = state
	end,
})

MovementSection:AddToggle({
	Name = "无限体力",
	Flag = "Toggle_InfiniteStamina",
	Default = Settings.InfiniteStamina,
	Callback = Janse025,
})

MovementSection:AddButton({
    Name = "飞行脚本",
    Callback = function()
        local success, result = pcall(function()
            local flightScript = game:HttpGet("https://raw.githubusercontent.com/Guo61/Cat-/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%AC.lua")
            if flightScript then
                local loadedFunction = loadstring(flightScript)
                if loadedFunction then
                    loadedFunction()
                    Notifier.new({
                        Title = "飞行脚本",
                        Content = "飞行脚本加载成功",
                        Duration = 3,
                        Icon = "zap"
                    })
                else
                    error("飞行脚本加载失败")
                end
            else
                error("无法获取飞行脚本")
            end
        end)
        
        if not success then
            Notifier.new({
                Title = "飞行脚本",
                Content = "飞行脚本加载失败: " .. tostring(result),
                Duration = 5,
                Icon = "alert-triangle"
            })
        end
    end,
})

MovementSection:AddToggle({
	Name = "无敌模式",
	Flag = "Toggle_Invincible",
	Default = Settings.Invincible,
	Callback = Janse026,
})

MovementSection:AddButton({
    Name = "一键传送回电梯",
    Callback = function()
        local success = Janse029()
        if success then
            Notifier.new({
                Title = "传送",
                Content = "已传送回电梯",
                Duration = 3,
                Icon = "navigation"
            })
        else
            Notifier.new({
                Title = "传送失败",
                Content = "未找到电梯或角色",
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end,
})

local ViewSection = MainTab:DrawSection({
	Name = "视野/亮度",
	Position = 'right'	
})

ViewSection:AddSlider({
	Name = "FOV",
	Min = 30,
	Max = 120,
	Default = Settings.CameraFOV,
	Round = 0,
	Flag = "Slider_FOV",
	Callback = function(value)
        Settings.CameraFOV = value
        if Camera then Camera.FieldOfView = value end
        if Settings.ThirdPerson then Janse003(true) end
	end
})

ViewSection:AddToggle({
	Name = "视野高亮",
	Flag = "Toggle_Brightness",
	Default = Settings.Brightness,
	Callback = function(state)
        Settings.Brightness = state
        if state then
            Lighting.Brightness = Settings.BrightnessValue
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.new(0, 0, 0)
        end
	end,
})

ViewSection:AddSlider({
	Name = "亮度值",
	Min = 1,
	Max = 10,
	Default = Settings.BrightnessValue,
	Round = 0,
	Flag = "Slider_BrightnessValue",
	Callback = function(value)
        Settings.BrightnessValue = value
        if Settings.Brightness then 
            Lighting.Brightness = value 
        end
	end
})

ViewSection:AddToggle({
	Name = "锁定第三人称(其实无效)",
	Flag = "Toggle_ThirdPerson",
	Default = Settings.ThirdPerson,
	Callback = function(state)
        Settings.ThirdPerson = state
        Janse003(state)
	end,
})

local MonsterControlSection = MainTab:DrawSection({ Name = "怪物控制", Position = 'right' })

local playerNames = {}
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(playerNames, p.Name) end end

local PlayerDropdown = MonsterControlSection:AddDropdown({
    Name = "选择目标玩家",
    Values = playerNames,
    Callback = function(v)
        Settings.SelectedTargetPlayer = v
        Notifier.new({Title = "目标锁定", Content = "已选择: "..v, Duration = 2})
    end
})

MonsterControlSection:AddToggle({
    Name = "开启传送怪物",
    Flag = "Toggle_MonsterTP",
    Default = false,
    Callback = function(state)
        if Settings.SelectedTargetPlayer == "" and state then
            Notifier.new({Title = "错误", Content = "请先选择一个目标玩家", Duration = 3})
            return
        end
        Settings.MonsterToSelectedPlayer = state
    end
})

MonsterControlSection:AddButton({
    Name = "刷新玩家列表",
    Callback = function()
        local newNames = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(newNames, p.Name) end end
        PlayerDropdown:SetValues(newNames)
    end
})

MonsterControlSection:AddToggle({
	Name = "传送怪物到身边",
	Flag = "Toggle_MonsterToPlayer",
	Default = Settings.MonsterToPlayer,
	Callback = function(state)
        Settings.MonsterToPlayer = state
	end,
})

MonsterControlSection:AddToggle({
	Name = "怪物围绕旋转",
	Flag = "Toggle_MonsterRotate",
	Default = Settings.MonsterRotate,
	Callback = function(state)
        Settings.MonsterRotate = state
        if not state then
            MonsterRotation = {}
        end
	end,
})

MonsterControlSection:AddSlider({
	Name = "旋转半径",
	Min = 5,
	Max = 50,
	Default = Settings.RotateRadius,
	Round = 1,
	Flag = "Slider_RotateRadius",
	Callback = function(value)
        Settings.RotateRadius = value
	end
})

MonsterControlSection:AddSlider({
	Name = "旋转速度",
	Min = 0.5,
	Max = 5,
	Default = Settings.RotateSpeed,
	Round = 0.1,
	Flag = "Slider_RotateSpeed",
	Callback = function(value)
        Settings.RotateSpeed = value
	end
})

ViewSection:AddButton({
    Name = "加入QQ群聊",
    Callback = function()
        local qqGroupUrl = "https://qun.qq.com/universal-share/share?ac=1&authKey=6OsGC3gzpffqTyK%2B1FETLileHESybuSzphL6XQ4Q%2BzKC5L5uIm%2FON5GA1RkBg1b%2F&busi_data=eyJncm91cENvZGUiOiIxMDczMzEzMzQyIiwidG9rZW4iOiJNTjgwZnRVZ3lCM2VtOFFoT0syNDh4bG5HTy96YTQzcThxR0dlb1ZMckdWV0lMT3BCcmJ5RWN1SEhzVXVGWGt1IiwidWluIjoiMzM5NTg1ODA1MyJ9&data=8V7cPQbSXrdN1Zo_-U0s_ucOptXQHDcl5gD2UDgGaSpoWxHM755b7h4R6zdVI8B7dBZcFl-bIMT39nzEpNEPFQ&svctype=4&tempid=h5_group_info"
        
        setclipboard(qqGroupUrl)
        
        Notifier.new({
            Title = "QQ群聊链接已复制",
            Content = "链接已复制到剪贴板，请粘贴到浏览器打开加入群聊！",
            Duration = 10,
            Icon = "users"
        })
    end,
})

MainTab:DrawSection({Name = "游戏对象管理"}):AddButton({
    Name = "刷新游戏对象",
    Callback = function()
        Janse001()
        Notifier.new({
            Title = "刷新完成",
            Content = "游戏对象已成功刷新",
            Duration = 3,
            Icon = "zap"
        })
    end,
})

local CombatTab = Window:DrawTab({
	Name = "战斗辅助",
	Icon = "swords",
	EnableScrolling = true
})

local CombatSection = CombatTab:DrawSection({
	Name = "战斗功能",
	Position = 'left'	
})

CombatSection:AddToggle({
	Name = "杀戮光环 (TP杀)",
	Risky = true,
	Flag = "Toggle_Aura",
	Default = Settings.Aura,
	Callback = function(state)
        Settings.Aura = state
	end,
})

CombatSection:AddSlider({
	Name = "光环范围",
	Min = 10,
	Max = 100,
	Default = Settings.AuraRange,
	Round = 0,
	Flag = "Slider_AuraRange",
	Callback = function(value)
        Settings.AuraRange = value
	end
})

CombatSection:AddToggle({
	Name = "推动怪物",
	Flag = "Toggle_PushMonster",
	Default = Settings.PushMonster,
	Callback = function(state)
        Settings.PushMonster = state
	end,
})

CombatSection:AddSlider({
	Name = "推动范围",
	Min = 10,
	Max = 100,
	Default = Settings.PushRadius,
	Round = 0,
	Flag = "Slider_PushRadius",
	Callback = function(value)
        Settings.PushRadius = value
	end
})

CombatSection:AddSlider({
	Name = "推动力度",
	Min = 50,
	Max = 500,
	Default = Settings.PushStrength,
	Round = 0,
	Flag = "Slider_PushStrength",
	Callback = function(value)
        Settings.PushStrength = value
	end
})

local AutoSection = CombatTab:DrawSection({
	Name = "自动功能",
	Position = 'right'	
})

AutoSection:AddToggle({
	Name = "残血自动治疗",
	Flag = "Toggle_AutoHeal",
	Default = Settings.AutoHeal,
	Callback = function(state)
        Settings.AutoHeal = state
	end,
})

AutoSection:AddToggle({
	Name = "满包自动传送(会返回原位)",
	Flag = "Toggle_AutoExtract",
	Default = Settings.AutoExtract,
	Callback = function(state)
        Settings.AutoExtract = state
	end,
})

AutoSection:AddToggle({
	Name = "满包自动传送 (不返回原位)",
	Flag = "Toggle_AutoExtractNoReturn",
	Default = Settings.AutoExtractNoReturn,
	Callback = function(state)
        Settings.AutoExtractNoReturn = state
	end,
})

AutoSection:AddToggle({
	Name = "自动互动",
	Flag = "Toggle_AutoInteract",
	Default = Settings.AutoInteract,
	Callback = function(state)
        Settings.AutoInteract = state
	end,
})

AutoSection:AddSlider({
	Name = "互动范围",
	Min = 10,
	Max = 200,
	Default = Settings.AutoInteractRange,
	Round = 1,
	Flag = "Slider_AutoInteractRange",
	Callback = function(value)
        Settings.AutoInteractRange = value
	end
})

local FarmTab = Window:DrawTab({
	Name = "刷钱物品",
	Icon = "dollar-sign",
	EnableScrolling = true
})

local PickupSection = FarmTab:DrawSection({
	Name = "自动拾取",
	Position = 'left'	
})

PickupSection:AddToggle({
	Name = "自动刷钱(拾取带价物品)",
	Flag = "Toggle_AutoPickupCash",
	Default = Settings.AutoPickupCash,
	Callback = function(state)
        Settings.AutoPickupCash = state
        if state then
            Settings.Noclip = false
        end
	end,
})

PickupSection:AddToggle({
	Name = "吸附物品(传送到电梯)",
	Risky = true,
	Flag = "Toggle_AutoCollectItems",
	Default = Settings.AutoCollectItems,
	Callback = function(state)
        Settings.AutoCollectItems = state
        if state then
            Settings.Noclip = false
        end
	end,
})

local AutoOpenSection = FarmTab:DrawSection({
	Name = "自动打开容器",
	Position = 'right'	
})

AutoOpenSection:AddToggle({
	Name = "自动打开箱子",
	Flag = "Toggle_AutoOpenCrate",
	Default = Settings.AutoOpenCrate,
	Callback = function(state)
        Settings.AutoOpenCrate = state
        if not state then openedContainers = {} end
	end,
})

AutoOpenSection:AddToggle({
	Name = "自动打开柜子",
	Flag = "Toggle_AutoOpenCabinet",
	Default = Settings.AutoOpenCabinet,
	Callback = function(state)
        Settings.AutoOpenCabinet = state
        if not state then openedContainers = {} end
	end,
})

AutoOpenSection:AddToggle({
	Name = "自动打开油桶",
	Flag = "Toggle_AutoOpenOilBucket",
	Default = Settings.AutoOpenOilBucket,
	Callback = function(state)
        Settings.AutoOpenOilBucket = state
        if not state then openedContainers = {} end
	end,
})

AutoOpenSection:AddToggle({
	Name = "自动打开冰箱",
	Flag = "Toggle_AutoOpenFridge",
	Default = Settings.AutoOpenFridge,
	Callback = function(state)
        Settings.AutoOpenFridge = state
        if not state then openedContainers = {} end
	end,
})

local ESPTab = Window:DrawTab({
	Name = "ESP",
	Icon = "eye",
	EnableScrolling = true
})

local ESPToggleSection = ESPTab:DrawSection({
	Name = "ESP 开关",
	Position = 'left'	
})

ESPToggleSection:AddToggle({
	Name = "ESP总开关",
	Flag = "Toggle_ESP",
	Default = Settings.ESP,
	Callback = function(state)
        Settings.ESP = state
	end,
})

ESPToggleSection:AddToggle({
	Name = "物品轮廓",
	Flag = "Toggle_ESPItemOutline",
	Default = Settings.ESP_ItemOutline,
	Callback = function(state)
        Settings.ESP_ItemOutline = state
	end,
})

local ESPTargetSection = ESPTab:DrawSection({
	Name = "ESP 目标",
	Position = 'left'	
})

ESPTargetSection:AddToggle({
	Name = "显示怪物",
	Flag = "Toggle_ESPMob",
	Default = Settings.ESP_Mob,
	Callback = function(state)
        Settings.ESP_Mob = state
	end,
})

ESPTargetSection:AddToggle({
	Name = "显示物品",
	Flag = "Toggle_ESPItem",
	Default = Settings.ESP_Item,
	Callback = function(state)
        Settings.ESP_Item = state
	end,
})

ESPTargetSection:AddToggle({
	Name = "显示玩家",
	Flag = "Toggle_ESPPlayer",
	Default = Settings.ESP_Player,
	Callback = function(state)
        Settings.ESP_Player = state
	end,
})

ESPTargetSection:AddToggle({
	Name = "显示NPC",
	Flag = "Toggle_ESPNPC",
	Default = Settings.ESP_NPC,
	Callback = function(state)
        Settings.ESP_NPC = state
	end,
})

ESPTargetSection:AddToggle({
	Name = "显示容器",
	Flag = "Toggle_ESPContainer",
	Default = Settings.ESP_Container,
	Callback = function(state)
        Settings.ESP_Container = state
	end,
})

local PriceSection = ESPTab:DrawSection({
	Name = "物品价格渐变调整",
	Position = 'right'	
})

PriceSection:AddSlider({
	Name = "最低价格",
	Min = 0,
	Max = 5000,
	Default = Settings.Price_Min,
	Round = 100,
	Flag = "Slider_PriceMin",
	Callback = function(value)
        Settings.Price_Min = value
	end
})

PriceSection:AddSlider({
	Name = "最高价格",
	Min = 1000,
	Max = 20000,
	Default = Settings.Price_Max,
	Round = 500,
	Flag = "Slider_PriceMax",
	Callback = function(value)
        Settings.Price_Max = value
	end
})

PriceSection:AddColorPicker({
	Name = "物品基础颜色",
	Default = Settings.Color_Item,
	Flag = "Color_ItemBase",
	Callback = function(color)
        Settings.Color_Item = color
	end
})

PriceSection:AddColorPicker({
	Name = "物品高价颜色",
	Default = Settings.Color_Item_High,
	Flag = "Color_ItemHigh",
	Callback = function(color)
        Settings.Color_Item_High = color
	end
})

local ColorSection = ESPTab:DrawSection({
	Name = "ESP 颜色调整",
	Position = 'right'	
})

ColorSection:AddColorPicker({
	Name = "怪物颜色",
	Default = Settings.Color_Mob,
	Flag = "Color_Mob",
	Callback = function(color)
        Settings.Color_Mob = color
	end
})

ColorSection:AddColorPicker({
	Name = "玩家颜色",
	Default = Settings.Color_Player,
	Flag = "Color_Player",
	Callback = function(color)
        Settings.Color_Player = color
	end
})

ColorSection:AddColorPicker({
	Name = "NPC 颜色",
	Default = Settings.Color_NPC,
	Flag = "Color_NPC",
	Callback = function(color)
        Settings.Color_NPC = color
	end
})

ColorSection:AddColorPicker({
	Name = "容器颜色",
	Default = Settings.Color_Container,
	Flag = "Color_Container",
	Callback = function(color)
        Settings.Color_Container = color
	end
})

Window:DrawCategory({ Name = "配置" })
local ConfigUI = Window:DrawConfig({
	Name = "配置管理",
	Icon = "folder",
	Config = ConfigManager
})

ConfigUI:Init()

Notifier.new({
    Title = "脚本加载成功",
    Content = "点击右上角Ck最小化/nbug反馈3395858053",
    Duration = 8,
    Icon = "rbxassetid://120245531583106"
})
print("感谢游玩")