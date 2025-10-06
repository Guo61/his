local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./main/%E9%9C%96%E6%BA%BA%E8%84%9A%E6%9C%ACUI.lua"))()

local window = library:new("Test")

local Page = window:Tab("主要功能",'16060333448')

local Section = Page:section("功能",true)

Section:Toggle("自动收集食物", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Food" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集手电筒", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Flashlight" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集近战武器", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Melee" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)
Section:Toggle("自动收集枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Gun" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动收集药品", "", false, function(state)
    while state and task.wait() do
        for _,v in next,workspace.Map.Util.Items:GetChildren() do
            if v.ToolStats.ItemType.Value == "Health" then
                game:GetService("ReplicatedStorage").Remotes.RequestPickupItem:FireServer(v)
            end
        end
    end
end)

Section:Toggle("自动装弹", "", false, function(state)
    while state and task.wait() do
        game:GetService("ReplicatedStorage").Remotes.Weapon.GunReloaded:FireServer(v, 1)
    end
end)

Section:Toggle("自动开枪", "", false, function(state)
    while state and task.wait() do
        for _, v in next, game.Players.LocalPlayer.Backpack:GetChildren() do
            if v:FindFirstChild("ToolStats") and v.ToolStats:FindFirstChild("Ammo") then
                for _,e in next,workspace.Enemies:GetChildren() do
                    if e.Humanoid.Health > 0 then
                        local BulletsPerShot = v.ToolStats.BulletsPerShot.Value
                        local DirectionTbl = {}
                        for i = 1, BulletsPerShot do
                            table.insert(DirectionTbl, Vector3.new(e.Head.Position.X, e.Head.Position.Y, e.Head.Position.Z).Unit)
                        end
                        local args = {
                            [1] = {
                                ["FiringPlayer"] = game:GetService("Players").LocalPlayer,
                                ["FiredTime"] = os.time,
                                ["FiringPlayerUserId"] = game.Players.LocalPlayer.UserId,
                                ["Origin"] = Vector3.new(game.Players.LocalPlayer.Character:GetPivot().Position),
                                ["UID"] = game.Players.LocalPlayer.UserId .. "_1",
                                ["WeaponInstance"] = v,
                                ["ThisBulletProperties"] = {
                                    ["BulletSpread"] = v.ToolStats.BulletSpread.Value,
                                    ["BulletsPerShot"] = v.ToolStats.BulletsPerShot.Value,
                                    ["BulletPenetration"] = v.ToolStats.BulletPenetration.Value,
                                    ["BulletSpeed"] = v.ToolStats.BulletSpeed.Value,
                                    ["FireSound"] = v.ToolStats.FireSound.Value,
                                    ["BulletSize"] = v.ToolStats.BulletSize.Value
                                },
                                ["DirectionTbl"] = DirectionTbl
                            }
                        }
                        game:GetService("ReplicatedStorage").Remotes.Weapon.GunFired:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

Section:Toggle("修改超级枪", "", false, function(state)
    while state and task.wait() do
        for _,v in next,game.Players.Backpack:GetChildren() do
            if v.ToolStats:FindFirstChild("Ammo") then
                v.ToolStats.ReloadTime.Value = 0
                v.ToolStats.FireDelay.Value = 0
                v.ToolStats.Ammo.Value = math.huge
                v.ToolStats.Damage.Value = math.huge
            end
        end
    end
end)
Section:Toggle("无限体力和饥饿度", "", false, function(state)
    while state and task.wait() do
        game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value = math.huge
        game.Players.LocalPlayer.Character.CharacterData.Energy.Value = game.Players.LocalPlayer.Character.CharacterData.MaxEnergy.Value
        game.Players.LocalPlayer.Character.CharacterData.Stamina.Value = game.Players.LocalPlayer.Character.CharacterData.MaxStamina.Value
    end
end)

Section:Toggle("夜晚自动躲避", "", false, function(state)
    while state and task.wait() do
        if game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value == "Night" then
        oldpos = game.Players.LocalPlayer.Character:GetPivot().Position
        repeat task.wait()
        game.Players.LocalPlayer.Character:PivotTo(CFrame.new(306.18927001953125, 36.67450714111328, -519.2435913085938))
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
        until game:GetService("ReplicatedStorage").GameInfo.TimeOfDay.Value ~= "Night"
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldpos
        else
            task.wait()
        end
    end
end)