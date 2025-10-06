local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

OrionLib:MakeNotification({
	Name = "郝蕾中心",
	Content = "正在加载 郝蕾中心-住宅大屠杀",
	Image = "rbxthumb://type=Asset&id=5107182114&w=150&h=150",
	Time = 2
})

local Window = OrionLib:MakeWindow({Name = "郝蕾中心-住宅大屠杀", HidePremium = false, SaveConfig = true, IntroText = "郝蕾中心-住宅大屠杀", ConfigFolder = "BeiFengResidenceMassacre"})

local Back = Window:MakeTab({
	Name = "郝蕾中心",
	Icon = "rbxassetid://14380684950",
	PremiumOnly = false
})

Back:AddButton({
	Name = "返回郝蕾中心",
	Callback = function()
		loadstring(game:HttpGet(("https://raw.githubusercontent.com/UWUBeiFeng/Scripts/main/BeiFengCenter.lua"),true))()
	end
})

local Home = Window:MakeTab({
	Name = "主要功能",
	Icon = "rbxassetid://14361559991",
	PremiumOnly = false
})

Home:AddButton({
	Name = "传送至 手电筒",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-29.9, 7.8, -76.4)
	end 
})

Home:AddButton({
	Name = "传送至 木板放置工具",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-34.5, 23.8, -66.5)
	end 
})

Home:AddButton({
	Name = "传送至 梯子",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-67.4, 4.2, -133.2)
	end 
})

Home:AddButton({
	Name = "传送至 电力箱",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2.3, 4.7, -93.6)
	end 
})

Home:AddButton({
	Name = "传送至 加油小屋",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-79.2, 4.8, -126.1)
	end 
})

Home:AddButton({
	Name = "传送至 柜子1",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-4.3, 7.8, -39.5)
	end 
})

Home:AddButton({
	Name = "传送至 柜子2",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-22.1, 23.8, -69.3)
	end 
})

Home:AddButton({
	Name = "传送至 监控查看位置",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-20.4, 25.8, -80.5)
	end 
})

Home:AddButton({
	Name = "传送至 监控1",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-14.6, 4.2, -120.4)
	end 
})

Home:AddButton({
	Name = "传送至 监控2",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-49.6, 4.2, -93.2)
	end 
})

Home:AddButton({
	Name = "传送至 监控3",
	Callback = function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-18.4, 4.2, 25.1)
	end 
})

OrionLib:Init()