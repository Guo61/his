local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/bailib/Roblox/refs/heads/main/main/ESP.lua"))()
local data = loadstring(game:HttpGet("https://raw.githubusercontent.com/bailib/Roblox/refs/heads/main/main/data.lua"))()
local language = loadstring(game:HttpGet("https://raw.githubusercontent.com/bailib/Roblox/refs/heads/main/main/language.lua"))()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:Notify({
    Title = language[game.Players.LocalPlayer.LocaleId].NotificationText,
    Content = language[game.Players.LocalPlayer.LocaleId].NotificationContent,
    Duration = 5,
})

ESP.AddFolder("HiderESPFolder")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character
local hum = Character.HumanoidRootPart
local camera = workspace.CurrentCamera

local Window = WindUI:CreateWindow({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].Title,
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = language[game.Players.LocalPlayer.LocaleId].Author,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(300, 270),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Callback = function() print("clicked") end,
        Anonymous = false
    },
    SideBarWidth = 200,
    -- HideSearchBar = true,
    ScrollBarEnabled = true,
    -- Background = "rbxassetid://13511292247", -- rbxassetid only
})
Window:EditOpenButton({
    Title = language[game.Players.LocalPlayer.LocaleId].OpenText,
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"), 
        Color3.fromHex("F89B29")
    ),
    Draggable = true,
})

MainSection = Window:Section({
    Title = "main",
    Opened = true,
})

Main = MainSection:Tab({ Title = "Main", Icon = "Sword" })
Source = MainSection:Tab({ Title = "Source", Icon = "Sword" })

Source:Code({
    Code = request({Url="https://raw.githubusercontent.com/bailib/Roblox/refs/heads/main/Game/Animal%20Hide%20and%20Seek.luau"}).Body,
})

Main:Toggle({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].AimbotHider,
    Image = "bird",
    Value = data["Animal Hide and Seek"].AimHider,
    Callback = function(state)
        data["Animal Hide and Seek"].AimHider = state
        spawn(function()
            while data["Animal Hide and Seek"].AimHider and wait() do
                local closestPlayer = nil
                local closestDistance = math.huge
                for _, v in next, Players:GetChildren() do
                    if v ~= Player and v.Team.Name == "Hider" and v.Character.Humanoid.Health > 0 then
                        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (Player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = v.Character
                            end
                        end
                    end
                end
                if closestPlayer then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.p, closestPlayer.HumanoidRootPart.Position)
                end
            end
        end)
    end
})

Main:Toggle({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].ESPHider,
    Image = "bird",
    Value = data["Animal Hide and Seek"].ESPHider,
    Callback = function(state)
        data["Animal Hide and Seek"].ESPHider = state
        if data["Animal Hide and Seek"].ESPHider then
            for _,v in pairs(Players:GetChildren()) do
                if v ~= Player and v.Team.Name == "Hider" then
                    ESP.AddESP("HiderESPFolder", "玩家" .. v.Name, v.Character, Color3.new(0,0,1))
                end
            end
        else
            ESP.Clear("HiderESPFolder")
        end
    end
})

Main:Toggle({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].AutoCoin,
    Image = "bird",
    Value = data["Animal Hide and Seek"].AutoCoin,
    Callback = function(state)
        data["Animal Hide and Seek"].AutoCoin = state
        spawn(function()
            while data["Animal Hide and Seek"].AutoCoin and wait() do
                for _,v in next,workspace.CurrentMap.SPAWNED_COINS:GetChildren() do
                    if v then
                        firetouchinterest(v.Hitbox, hum, 0)
                        firetouchinterest(v.Hitbox, hum, 1)
                    end
                end
            end
        end)
    end
})

Main:Toggle({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].AlwaysSeeker,
    Image = "bird",
    Value = data["Animal Hide and Seek"].AlwaysSeeker,
    Callback = function(state)
        data["Animal Hide and Seek"].AlwaysSeeker = state
        spawn(function()
            while data["Animal Hide and Seek"].AlwaysSeeker and wait() do
                if Player.PlayerGui.MainGui.GameFrame.RoleSelectionFrame.Visible == true then
                    Player.PlayerGui.MainGui.GameFrame.RoleSelectionFrame.CanvasGroup.MainContainer.KillerChanceTxt.Text = "Chance for killer: 100%"
                    Player.PlayerGui.MainGui.GameFrame.RoleSelectionFrame.CanvasGroup.MainContainer.RoleTxt.Text = "killer"
                end
                if Player.Team.Name ~= "Seeker" then
                    Player.Team = game:GetService("Teams").Seeker
                end
            end
        end)
    end
})

Main:Toggle({
    Title = language[game.Players.LocalPlayer.LocaleId]["Animal Hide and Seek"].AutoWalk,
    Image = "bird",
    Value = data["Animal Hide and Seek"].AutoWalk,
    Callback = function(state)
        data["Animal Hide and Seek"].AutoWalk = state
        spawn(function()
            while data["Animal Hide and Seek"].AutoWalk and wait() do
                local nearestPlayer, minDistance = nil, math.huge
                for _, player in ipairs(Players:GetChildren()) do
                    if player ~= Player and player.Character and player.Team.Name == "Hider" then
                        if player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (player.Character.HumanoidRootPart.Position - hum.Position).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                nearestPlayer = player
                            end
                        end
                    end
                end
                if nearestPlayer then
                    Character.Humanoid:MoveTo(nearestPlayer.Character.HumanoidRootPart.Position)
                end
            end
        end)
    end
})