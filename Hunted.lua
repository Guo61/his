local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./main/%E9%9C%96%E6%BA%BA%E8%84%9A%E6%9C%ACUI.lua"))()
local window = library:new("Haunted [horror] 黑暗欺骗")

local Page = window:Tab("主要功能",'16060333448')
local Main = Page:section("主要功能",true)

local Page = window:Tab("传送功能",'16060333448')
local Player = Page:section("传送功能",true)
local setting = {
    player = {
        list = {},
        select = "",
        autotp = false
    },
    auto = {
        autoshard = false,
        autotpshard = false,
        autotweenshard = false,
        evade = false,
        notify = false
    },
    esp = {
        shardesp = false,
        enemyesp = false
    },
    win = {
        first = false,
        second = false
    }
}

local ESPFloder = Instance.new("Folder")
ESPFloder.Parent = workspace
ESPFloder.Name = "ShardESPFloder"

local ESPFloder = Instance.new("Folder")
ESPFloder.Parent = workspace
ESPFloder.Name = "EnemyESPFloder"

local function ESPS(Text, Adornee, Color)
    if not Adornee:FindFirstChild("ROLESPBillboardGui") then
        local ROLESPBillboardGui = Instance.new("BillboardGui")
        ROLESPBillboardGui.Parent = workspace.ShardESPFloder
        ROLESPBillboardGui.Adornee = Adornee
        ROLESPBillboardGui.Size = UDim2.new(0, 20, 0, 20)
        ROLESPBillboardGui.StudsOffset = Vector3.new(0, 3, 0)
        ROLESPBillboardGui.AlwaysOnTop = true
        local ROLESPTextLabel = Instance.new("TextLabel")
        ROLESPTextLabel.Parent = ROLESPBillboardGui
        ROLESPTextLabel.Size = UDim2.new(1, 0, 1, 0)
        ROLESPTextLabel.BackgroundTransparency = 1
        ROLESPTextLabel.Text = Text
        ROLESPTextLabel.TextColor3 = Color
        ROLESPTextLabel.TextStrokeTransparency = 0.5
        ROLESPTextLabel.TextScaled = true
    end
end

local function ESPM(Text, Adornee, Color)
    if not Adornee:FindFirstChild("ROLESPBillboardGui") then
        local ROLESPBillboardGui = Instance.new("BillboardGui")
        ROLESPBillboardGui.Parent = workspace.EnemyESPFloder
        ROLESPBillboardGui.Adornee = Adornee
        ROLESPBillboardGui.Size = UDim2.new(0, 20, 0, 20)
        ROLESPBillboardGui.StudsOffset = Vector3.new(0, 3, 0)
        ROLESPBillboardGui.AlwaysOnTop = true
        local ROLESPTextLabel = Instance.new("TextLabel")
        ROLESPTextLabel.Parent = ROLESPBillboardGui
        ROLESPTextLabel.Size = UDim2.new(1, 0, 1, 0)
        ROLESPTextLabel.BackgroundTransparency = 1
        ROLESPTextLabel.Text = Text
        ROLESPTextLabel.TextColor3 = Color
        ROLESPTextLabel.TextStrokeTransparency = 0.5
        ROLESPTextLabel.TextScaled = true
    end
end

for i, v in pairs(game.Players:GetChildren()) do
    setting.player.list[v.Name] = v.Name
end

Player:Dropdown("选择玩家", "", setting.player.list, function(value)
    setting.player.select = value
end)

Player:Toggle("传送玩家", "", setting.player.autotp, function(state)
    setting.player.autotp = state
    task.spawn(function()
        while setting.player.autotp and task.wait() do
            if setting.player.select then
                if game.Players:FindFirstChild(setting.player.select) and game.Players:FindFirstChild(setting.player.select).Character and game.Players:FindFirstChild(setting.player.select).Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players:FindFirstChild(setting.player.select).Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end)
end)

Main:Toggle("秒收集碎片", "", setting.auto.autoshard, function(state)
    setting.auto.autoshard = state
    task.spawn(function()
        while setting.auto.autoshard and task.wait() do
            for _,v in next,workspace.Shards:GetChildren() do
                firetouchinterest(v, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                firetouchinterest(v, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            end
        end
    end)
end)

Main:Toggle("传送收集碎片", "", setting.auto.autotpshard, function(state)
    setting.auto.autotpshard = state
    task.spawn(function()
        while setting.auto.autotpshard and task.wait() do
            for _,v in next,workspace.Shards:GetChildren() do
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
            end
        end
    end)
end)

Main:Toggle("平滑收集碎片", "", setting.auto.autotweenshard, function(state)
    setting.auto.autotweenshard = state
    task.spawn(function()
        while setting.auto.autotweenshard and task.wait() do
            for _, v in next, workspace.Shards:GetChildren() do
                local tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = v.CFrame})
                tween:Play()
                while tween.Playing do
                    task.wait()
                end
            end
        end
    end)
end)

Main:Toggle("怪物来临提醒", "", setting.auto.evade, function(state)
    setting.auto.notify = state
    task.spawn(function()
        while setting.auto.notify and task.wait() do
            for _, v in next, workspace.Terrain.Enemies:GetChildren() do
                if v:IsA("Model") and (v:GetPivot().Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude < 35 then
                    Httadmin.send("warn!!!!", "敌人来袭", 10, "rbxassetid://78892482588180")
                end
            end
        end
    end)
end)

Main:Toggle("自动躲避怪物", "", setting.auto.evade, function(state)
    setting.auto.evade = state
    task.spawn(function()
        while setting.auto.evade and task.wait() do
            for _, v in next, workspace.Terrain.Enemies:GetChildren() do
                if v:IsA("Model") and (v:GetPivot().Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude < 15 then
                    local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
                else
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Position = oldpos
                    game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end)
end)

Main:Toggle("透视碎片", "", setting.esp.shardesp, function(state)
    setting.esp.shardesp = state
    if setting.esp.shardesp then
        for _,v in next,workspace.Shards:GetChildren() do
            if v.Name == "Shard" then
                ESPS("•普通碎片•", v, Color3.new(0.5, 0, 0.5))
            elseif v.Name == "RedShard" then
                ESPS("•侦查碎片•", v, Color3.new(1, 0, 0))
            elseif v.Name == "OrangeShard" then
                ESPS("•震撼碎片•", v, Color3.new(1, 0.5, 0))
            end
        end
        workspace.Shards.ChildAdded:Connect(function(v)
            if setting.esp.shardesp then
                if v.Name == "Shard" then
                    ESPS("•普通碎片•", v, Color3.new(0.5, 0, 0.5))
                elseif v.Name == "RedShard" then
                    ESPS("•侦查碎片•", v, Color3.new(1, 0, 0))
                elseif v.Name == "OrangeShard" then
                    ESPS("•震撼碎片•", v, Color3.new(1, 0.5, 0))
                end
            end
        end)
    else
        workspace.ShardESPFloder:ClearAllChildren()
    end
end)

Main:Toggle("透视怪物", "", setting.esp.enemyesp, function(state)
    setting.esp.enemyesp = state
    if setting.esp.enemyesp then
        for _,v in next,workspace.Terrain.Enemies:GetChildren() do
            if v:IsA("Model") then
                ESPM("•怪物" .. v.Name .. "•", v, Color3.new(0, 1, 0))
            end
        end
        workspace.Terrain.Enemies.ChildAdded:Connect(function(v)
            if setting.esp.enemyesp then
                if v:IsA("Model") then
                    ESPM("•怪物" .. v.Name .. "•", v, Color3.new(0, 1, 0))
                end
            end
        end)
    else
        workspace.EnemyESPFloder:ClearAllChildren()
    end
end)

Main:Button("传送雕像", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Hotel.Maze.Rooms.Main.RingAltar.Parts.RingAltar.CFrame
end)

Main:Toggle("自动完成水晶(开局使用)", "", setting.win.first, function(state)
    setting.win.first = state
    task.spawn(function()
        while setting.win.first and wait() do
            firetouchinterest(workspace.Hotel.Events.CardboardFall.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
            firetouchinterest(workspace.Hotel.Events.CardboardFall.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            wait(1)
            firetouchinterest(workspace.Hotel.Events.ElevatorOpen.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
            firetouchinterest(workspace.Hotel.Events.ElevatorOpen.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            wait(2)
            firetouchinterest(workspace.Hotel.Events.ElevatorReturn.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
            firetouchinterest(workspace.Hotel.Events.ElevatorReturn.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            wait(6)
            firetouchinterest(workspace.Hotel.Events.Tutorial.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
            firetouchinterest(workspace.Hotel.Events.Tutorial.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            wait(5)
            for _,v in next,workspace.Shards:GetChildren() do
                firetouchinterest(v, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
                firetouchinterest(v, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            end
            wait(5)
            repeat task.wait()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Hotel.Maze.Rooms.Main.RingAltar.Parts.RingAltar.CFrame
            until not workspace.Hotel.Maze.Rooms.Main.RingAltar.Parts.RingAltar:FindFirstChild("Orb")
        end
    end)
end)

Main:Toggle("自动完成追逐(追逐战使用)", "", setting.win.second, function(state)
    setting.win.second = state
    task.spawn(function()
        while setting.win.second and wait() do
            
            firetouchinterest(workspace.Hotel.Events.MonkeyJumpReception.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
            firetouchinterest(workspace.Hotel.Events.MonkeyJumpReception.Object, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
            wait(0.5)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Portals.EntrancePortal.TeleportReference.CFrame
        end
    end)
end)