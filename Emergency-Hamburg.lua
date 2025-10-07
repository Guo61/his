if game:GetService("Players").LocalPlayer.PlayerScripts.Code.controllers:FindFirstChild("antiCheatController") or game:GetService("StarterPlayer").StarterPlayerScripts.Code.controllers:FindFirstChild("antiCheatController") then
    game:GetService("Players").LocalPlayer.PlayerScripts.Code.controllers.antiCheatController:Destroy()
    game:GetService("StarterPlayer").StarterPlayerScripts.Code.controllers.antiCheatController:Destroy()
end

local Module  =  game:GetService("Players").LocalPlayer.PlayerScripts.Code.controllers.character.characterStaminaController
local ClassModule = require(Module).CharacterStaminaController
function seat()
    local invisChair = Instance.new("Seat")
    invisChair.Name = "invisChair"
    invisChair.Size = Vector3.new(2, 0.5, 2)
    invisChair.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
    invisChair.Transparency = 1
    invisChair.CanCollide = false
    invisChair.Parent = workspace
    local weld = Instance.new("Weld")
    weld.Part0 = invisChair
    weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character:FindFirstChild("UpperTorso")
    weld.C0 = CFrame.new(0, -2, 0)
    weld.C1 = CFrame.new(0, 0, 0)
    weld.Parent = invisChair
end
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Emergency-Hamburg",
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

local a = {
    AimPolice = false,
    inffuel = false,
    godcar = false
}

Main:Toggle({
    Title = "秒互动",
    Value = false,
    Image = "check",
    Callback = function(state)
        game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(v)
            if state then
                fireproximityprompt(v)
            end
        end)
    end
})

Main:Toggle({
    Title = "自瞄警察",
    Image = "bird",
    Value = a.AimPolice,
    Callback = function(state)
        a.AimPolice = state
        spawn(function()
            while a.AimPolice and wait() do
                local closestPlayer = nil
                local closestDistance = math.huge
                for _, v in next, game.Players:GetChildren() do
                    if v ~= game.Players.LocalPlayer and v.Team.Name == "Police" then
                        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = v.Character
                            end
                        end
                    end
                end
                if closestPlayer then
                    workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.p, closestPlayer.HumanoidRootPart.Position)
                end
            end
        end)
    end
})

Main:Dropdown({
    Title = "选择传送地点",
    Values = {"珠宝店", "银行", "加油站"},
    Value = "自定义",
    Callback = function(Value)
        if Value == "珠宝店" then
            seat()
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(-392.137543, 5.61012459, 3555.52368, -0.983945966, -2.48897312e-08, -0.178466663, -3.10434913e-08, 1, 3.1688753e-08, 0.178466663, 3.67202482e-08, -0.983945966))
        elseif Value == "银行" then
            seat()
            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(-491.811249, 44.6140022, -1371.96912, 0.836383462, 1.53147379e-08, -0.548144758, -3.39736133e-08, 1, -2.38992186e-08, 0.548144758, 3.86113683e-08, 0.836383462))
        elseif Value == "加油站" then
            seat()
            game.Players.LocalPlayer.Character:PivotTo(workspace.Buildings["GasStation-GasNGo"].SlidingDoor.Sensor.CFrame)
        end
    end
})

Main:Button({
    Title = "传送车到银行门口",
    Desc = "点击开始",
    Callback = function()
        workspace.Vehicles[game.Players.LocalPlayer.Name]:PivotTo(-1168.36731, 7.74999905, 3178.19653, 0.0031938646, -2.57360213e-08, 0.999994874, 2.03339923e-09, 1, 2.57296584e-08, -0.999994874, 1.95121186e-09, 0.0031938646)
    end
})

Main:Button({
    Title = "无限体力",
    Desc = "点击开始",
    Callback = function()
        hookfunction(ClassModule.useStamina, function()
            return true
        end)
    end
})

Main:Slider({
    Title = "最大速度",
    Desc = "Speed",
    Value = {
        Min = 1,
        Max = 999999,
        Default = 200,
    },
    Callback = function(Value)
        workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("MaxSpeed", Value)
    end
})

Main:Slider({
    Title = "倒档速度",
    Desc = "Speed",
    Value = {
        Min = 1,
        Max = 999999,
        Default = 200,
    },
    Callback = function(Value)
        workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("ReverseMaxSpeed", Value)
    end
})

Main:Toggle({
    Title = "无限燃料",
    Value = false,
    Image = "check",
    Callback = function(state)
        a.inffuel = state
        while a.inffuel and wait() do
            workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("CurrentFuel", 100)
            workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("currentFuel", 100)
        end
    end
})

Main:Toggle({
    Title = "无敌车",
    Value = false,
    Image = "check",
    Callback = function(state)
        a.godcar = state
        while a.godcar and wait() do
            workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("CurrentHealth", 1)
            workspace.Vehicles[game.Players.LocalPlayer.Name]:SetAttribute("currentHealth", 1)
        end
    end
})