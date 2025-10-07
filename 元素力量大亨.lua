local setting = {
    autobuild = false,
    autocollect = false,
    autocollectcrate = false,
    autocollectdollar = false,
    autocollectchest = false
}

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "通用子弹追踪",
    Icon = "rbxassetid://129260712070622",
    IconThemed = true,
    Author = "郝蕾",
    Folder = "郝蕾Hub",
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
    Title = "打开UI",
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

Main:Toggle({
    Title = "自动建造",
    Image = "bird",
    Value = false,
    Callback = function(state)
        setting.autobuild = state
        task.spawn(function()
            while setting.autobuild and task.wait() do
                for _,v in next,workspace.Tycoons:GetChildren() do
                    if v.Name == game.Players.LocalPlayer.Name then
                        for _,a in next,v.Buttons:GetChildren() do
                            if a.Button.Color == Color3.fromRGB(0,127,0) then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = a.Button.CFrame
                            end
                        end
                    end
                end
            end
        end)
    end
})

Main:Toggle({
    Title = "自动收集钱",
    Image = "bird",
    Value = false,
    Callback = function(state)
        setting.autocollect = state
        task.spawn(function()
            while setting.autocollect do
                for _,v in next,workspace.Tycoons:GetChildren() do
                    if v.Name == game.Players.LocalPlayer.Name then
                        oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Auxiliary.Collector.Collect.CFrame
                        wait(1.5)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
                    end
                end
                task.wait(5)
            end
        end)
    end
})

Main:Toggle({
    Title = "自动收集掉落的dollar",
    Image = "bird",
    Value = false,
    Callback = function(state)
        setting.autocollectdollar = state
        task.spawn(function()
            while setting.autocollectdollar and task.wait() do
                for _,v in next,workspace:GetChildren() do
                    if v.Name == "Dollar" then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    end
                end
            end
        end)
    end
})

Main:Toggle({
    Title = "自动收集气球箱",
    Image = "bird",
    Value = false,
    Callback = function(state)
        setting.autocollectcrate = state
        task.spawn(function()
            while setting.autocollectcrate and task.wait() do
                for _,v in next,workspace:GetChildren() do
                    if v.Name == "BalloonCrate" then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Crate.CFrame
                        fireproximityprompt(v.Crate.ProximityPrompt)
                    end
                end
            end
        end)
    end
})

Main:Toggle({
    Title = "自动收集金钱箱",
    Image = "bird",
    Value = false,
    Callback = function(state)
        setting.autocollectchest = state
        task.spawn(function()
            while setting.autocollectchest and task.wait() do
                for _, v in pairs(workspace.Treasure.Chests:GetChildren()) do
                    if v.Name == "Chest" then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        fireproximityprompt(v.ProximityPrompt)
                    end
                end
            end
        end)
    end
})

Main:Button({
    Title = "自动收集箱",
    Desc = "bird",
    Callback = function()
        local oldpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        wait(0.5)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace.Map.Center.CFrame
        wait(0.3)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
    end
})