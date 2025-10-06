local locations = {
    ["传送到出生点"] = CFrame.new(-3338.31982, 10.04874, 3741.84033),
    ["传送到医院"] = CFrame.new(-5471.48242, 14.14942, 4259.75342),
    ["传送到手机店"] = CFrame.new(-6789.20410, 11.19769, 1762.68726),
    ["传送到火锅店"] = CFrame.new(-5912.84766, 12.21728, 1058.29443),
    ["传送到蜜雪冰城"] = CFrame.new(-6984.87158, 9.33285, 1734.77075),
    ["传送到小区"] = CFrame.new(-2187.54126, 22.09299, -636.70490),
    ["传送到洗车店"] = CFrame.new(-2578.51025, 23.33292, -588.55847),
    ["传送到卡车召唤地"] = CFrame.new(10559.13672, 39.31749, 3236.51929),
    ["传送到庆都山山顶"] = CFrame.new(-15042.90332, 325.29852, 22355.17773),
    ["传送到庆都山山底"] = CFrame.new(-15580.13574, 8.09993, 21171.93945),
    ["传送到小学"] = CFrame.new(-13888.13867, 10.94349, 11059.04590),
    ["传送到签挂美食"] = CFrame.new(-10332.76367, 10.43998, 7114.16064),
    ["传送到驾校"] = CFrame.new(-8912.12109, 9.96374, 7302.56836)
}

local teams = {
    ["变成平民"] = "Civilian",
    ["变成混合冰淇淋"] = "Mixue Ice Cream",
    ["变成咖啡师"] = "Teawen Barista",
    ["变成送货司机"] = "Delivery Driver",
    ["变成出租车司机"] = "Taxi Driver",
    ["变成线上计程车"] = "Ole Online Taxi Sharing",
    ["变成卡车司机"] = "Trucker",
    ["变成超市收银员"] = "Grocery Cashier",
    ["变成罪犯"] = "Criminal",
    ["变成学生"] = "Student",
    ["变成老师"] = "Teacher",
    ["变成商店员工"] = "Store Worker",
    ["变成变pao商店工人"] = "Pao Store Worker",
    ["变成救援人员"] = "Paramedic",
    ["变成巴车司机"] = "Bus Driver"
}
local KG_UI = loadstring(game:HttpGet("https://raw.github.com/520-Ghost/-/main/UI_2.lua"))()
local KG = KG_UI:new("KG┇河北唐县") 

local KG_UI_Tab = KG:Tab("玩家区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("玩家区内容",true)

KG_Tab:Slider("速度", "Slider", 16, 16, 1000, false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

KG_Tab:Slider("跳跃", "Slider", 50, 50, 1000, false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)

KG_Tab:Toggle("无限跳","Toggle",false,function(Value)
        Jump = Value
        game.UserInputService.JumpRequest:Connect(function()
            if Jump then
                game.Players.LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    end)
    
KG_Tab:Textbox("旋转速度", "SpinSpeed", "输入", function(Value)
    local speed = tonumber(Value)
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")
    humanoid.AutoRotate = false

    if not spinVelocity then
        spinVelocity = Instance.new("AngularVelocity")
        spinVelocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
        spinVelocity.MaxTorque = math.huge
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
        spinVelocity.Parent = humRoot
        spinVelocity.Name = "Spinbot"
    else
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
    end
end)

KG_Tab:Button("停止旋转", function()
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")

    local spinbot = humRoot:FindFirstChild("Spinbot")
    if spinbot then
        spinbot:Destroy()
        spinVelocity = nil
    end
    humanoid.AutoRotate = true 
end)

KG_Tab:Button("飞行",function()
loadstring(game:HttpGet("https://pastebin.com/raw/UVAj0uWu"))()
end)

KG_Tab:Button("重生",function()
game.Players.LocalPlayer.Character.Humanoid.Health=0
end)

local KG_UI_Tab = KG:Tab("天气区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("天气区内容",true)

KG_Tab:Textbox("修改时间", "", "输入",function(arg)
game:GetService("ReplicatedStorage"):WaitForChild("DataStructure"):WaitForChild("ManageServer"):FireServer("time", arg)
end)





local KG_UI_Tab = KG:Tab("传送区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("传送区内容",true)
for name, cf in pairs(locations) do
    KG_Tab:Button(name, function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cf
    end)
end

local KG_UI_Tab = KG:Tab("职业区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("职业区内容",true)

for btnName, teamName in pairs(teams) do
    KG_Tab:Button(btnName, function()
        game:GetService("ReplicatedStorage").TeamSwitch:FireServer(teamName)
    end)
end

local KG_UI_Tab = KG:Tab("车皮区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("车皮区内容",true)

KG_Tab:Label("1.请你不要上你的车辆")
KG_Tab:Button("2.点我", function()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-3307.947021484375, 10.250053405761719, 3920.100830078125)

end)

local KG_UI_Tab = KG:Tab("买车区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("手动买车区内容",true)







local KG_UI_Tab = KG:Tab("刷钱区", "128586210657724")
local KG_Tab = KG_UI_Tab:section("刷钱区内容",true)-