local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada./main/%E9%9C%96%E6%BA%BA%E8%84%9A%E6%9C%ACUI.lua"))()

local window = library:new("Test")

local Page = window:Tab("主要功能",'16060333448')

local Section = Page:section("功能",true)

Section:Toggle("自动收集矿物", "", false, function(state)
    while state and task.wait() do
        for _, v in pairs(workspace.Items:GetChildren()) do
            if v then
                local args = {
                    v.Name
                }
                game:GetService("ReplicatedStorage"):FindFirstChild("shared/network/MiningNetwork@GlobalMiningEvents").CollectItem:FireServer(unpack(args))
            end
        end
    end
end)

Section:Toggle("自动收集矿物", "", false, function(state)
    while state and task.wait() do
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v:GetAttribute("Name") == "Trader Tom" then
                game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = v:FindFirstChild("HumanoidRootPart").CFrame
                game:GetService("ReplicatedStorage").Ml.SellInventory:FireServer()
                break
            end
        end
    end
end)