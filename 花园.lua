local MaxFruits = 10
local AutoCollect = false
local AutoCollectAndSell = false
local AutoBuySeeds = false
local selectedSeed
local AutoSell = false
local AutoPlant = false
local AutoBuySprinkler = false
local AutoBuyWateringCan = false
game:GetService("Players").LocalPlayer.Idled:Connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/ProtectUI.lua"))()

local window = library:new("郝蕾脚本┋种植花园")

local Page = window:Tab("主要功能",'16060333448')

local Section = Page:section("功能",true)

Section:Slider("售卖要求最低背包数量", "", 50, 0, math.huge, false, function(value)
    MaxFruits = value
end)

Section:Toggle("自动收集加售卖", "", false, function(state)
    AutoCollectAndSell = state
    task.spawn(function()
        while task.wait(1) and AutoCollectAndSell do
            pcall(function()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if #game.Players.LocalPlayer.Backpack:GetChildren() > MaxFruits then
                        local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.NPCS["Sell Stands"]["Shop Stand"].CFrame* CFrame.new(0, 0, 3)
                        wait(0.5)
                        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
                        wait(1)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
                    end
                    for _, plot in pairs(workspace.Farm:GetChildren()) do
                        local important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
                        if important and important:FindFirstChild("Data") and important.Data:FindFirstChild("Owner") then
                            if important.Data.Owner.Value == game.Players.LocalPlayer.Name then
                                for _, prompt in ipairs(plot.Important.Plants_Physical:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        prompt.MaxActivationDistance = math.huge
                                        fireproximityprompt(prompt)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

Section:Toggle("自动收集", "", false, function(state)
    AutoCollect = state
    task.spawn(function()
        while task.wait(1) and AutoCollect do
            pcall(function()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, plot in pairs(workspace.Farm:GetChildren()) do
                        local important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
                        if important and important:FindFirstChild("Data") and important.Data:FindFirstChild("Owner") then
                            if important.Data.Owner.Value == game.Players.LocalPlayer.Name then
                                for _, prompt in ipairs(plot.Important.Plants_Physical:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        prompt.MaxActivationDistance = math.huge
                                        fireproximityprompt(prompt)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

Section:Toggle("自动收集2.0", "", false, function(state)
    AutoCollect = state
    task.spawn(function()
        while task.wait(1) and AutoCollect do
            pcall(function()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _, plot in pairs(workspace.Farm:GetChildren()) do
                        local important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
                        if important and important:FindFirstChild("Data") and important.Data:FindFirstChild("Owner") then
                            if important.Data.Owner.Value == game.Players.LocalPlayer.Name then
                                for _, prompt in ipairs(plot.Important.Plants_Physical:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        game.Players.LocalPlayer.Character.Humanoid:MoveTo(prompt.Parent.Position)
                                        prompt.MaxActivationDistance = math.huge
                                        fireproximityprompt(prompt)
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

Section:Toggle("自动售卖", "", false, function(state)
    AutoSell = state
    task.spawn(function()
        while task.wait(1) and AutoSell do
            pcall(function()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if #game.Players.LocalPlayer.Backpack:GetChildren() > MaxFruits then
                        local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.NPCS["Sell Stands"]["Shop Stand"].CFrame* CFrame.new(0, 0, 3)
                        wait(0.5)
                        game:GetService("ReplicatedStorage").GameEvents.Sell_Item:FireServer()
                        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
                        wait(1)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
                    end
                end
            end)
        end
    end)
end)

Section:Toggle("自动种植", "", false, function(state)
    AutoPlant = state
    task.spawn(function()
        while task.wait(1) and AutoPlant do
            pcall(function()
                if game.Players.LocalPlayer.Character.HumanoidRootPart then
                    for _, item in ipairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if item:IsA("Tool") and item.Name:find("Seed") then
                            seedType = item.Name:match("^(.-) Seed")
                            tool = item
                            break
                        end
                    end
                    if not tool then
                        for _, item in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") and item.Name:find("Seed") then
                                seedType = item.Name:match("^(.-) Seed")
                                tool = item
                                break
                            end
                        end
                    end
                    if tool and seedType then
                        if tool.Parent == game.Players.LocalPlayer.Backpack then
                            game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(tool)
                            repeat task.wait() until tool.Parent == game.Players.LocalPlayer.Character
                        end
                        game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Plant_RE"):FireServer(Vector3.new(math.floor(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.X), 0.1, math.floor(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Z)), seedType)
                    end
                end
            end)
        end
    end)
end)

Section:Toggle("显示种子刷新时间", "", false, function(state)
    local TimeGui = game.CoreGui:FindFirstChild("TimeGui")
    if not TimeGui then
        TimeGui = Instance.new("ScreenGui")
        TimeGui.Name = "TimeGui"
        TimeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        TimeGui.Parent = game.CoreGui

        local TimeLabel = Instance.new("TextLabel")
        TimeLabel.Name = "TimeLabel"
        TimeLabel.BackgroundColor3 = Color3.new(1, 1, 1)
        TimeLabel.BackgroundTransparency = 1
        TimeLabel.BorderColor3 = Color3.new(0, 0, 0)
        TimeLabel.Position = UDim2.new(0.80, 0, 0.00090, 0)
        TimeLabel.Size = UDim2.new(0, 135, 0, 50)
        TimeLabel.Font = Enum.Font.GothamSemibold
        TimeLabel.Text = "种子下次更新时间: " .. game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Frame.Frame.Timer.Text
        TimeLabel.TextColor3 = Color3.new(1, 1, 1)
        TimeLabel.TextScaled = true
        TimeLabel.TextSize = 14
        TimeLabel.TextWrapped = true
        TimeLabel.Parent = TimeGui

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 127, 0)),
            ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.60, Color3.fromRGB(139, 0, 255)),
            ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 127, 0)),
            ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 0))
        }
        UIGradient.Rotation = 360
        UIGradient.Parent = TimeLabel
    end
    TimeGui.Enabled = state
    TimeGui.TimeLabel.Visible = state

    local TweenService = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
    local tween = TweenService:Create(TimeGui.TimeLabel.UIGradient, tweeninfo, {Rotation = 360})
    tween:Play()

    if state then
        game:GetService("RunService").RenderStepped:Connect(function()
            TimeGui.TimeLabel.Text = "时间: " .. game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Frame.Frame.Timer.Text
        end)
    else
        for _, conn in ipairs(getconnections(game:GetService("RunService").RenderStepped)) do
            if conn.Function == function()
                TimeGui.TimeLabel.Text = "时间: " .. game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop.Frame.Frame.Timer.Text
            end then
                conn:Disconnect()
            end
        end
    end
end)

Section:Dropdown("选择种子", "请选择要购买的种子", {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape"}, function(value)
    selectedSeed = value
end)

Section:Toggle("自动购买种子", "", false, function(state)
    AutoBuySeeds = state
    task.spawn(function()
        while task.wait(0.2) and AutoBuySeeds do
            pcall(function()
                game:GetService("ReplicatedStorage").GameEvents.BuySeedStock:FireServer(selectedSeed)
            end)
        end
    end)
end)

Section:Button("购买种子", function()
    game:GetService("ReplicatedStorage").GameEvents.BuySeedStock:FireServer(selectedSeed)
end)

Section:Toggle("自动购买水壶", "", false, function(state)
    AutoBuyWateringCan = state
    task.spawn(function()
        while task.wait(1) and AutoBuyWateringCan do
            pcall(function()
                game:GetService("ReplicatedStorage").GameEvents.BuyGearStock:FireServer("Watering Can")
            end)
        end
    end)
end)