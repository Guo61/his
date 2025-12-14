local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Confirmed = false

WindUI:Popup({
    Title = "JYC",
    Content = "欢迎使用JYC脚本\n需要时开启反挂机",
    Buttons = {
        {
            Title = "取消",
            Callback = function() end,
            Variant = "Secondary",
        },
        {
            Title = "继续",
            Icon = "arrow-right",
            Callback = function() Confirmed = true end,
            Variant = "Primary",
        }
    }
})

repeat wait() until Confirmed

local Window = WindUI:CreateWindow({
    Title = "J Y C",
    IconThemed = true,
    Author = "江砚辰",
    Folder = "JYC",
    Size = UDim2.fromOffset(560, 340),
    Transparent = true,
    Theme = "Dark",
    User = { Enabled = true },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
})

Window:Tag({
    Title = "v1.0",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
    Title = "三传奇", 
    Color = Color3.fromHex("#315dff")
})

local ranks = {"Rank 1", "Rank 2", "Rank 3", "Rank 4", "Rank 5", "Rank 6", "Rank 7", "Rank 8", "Rank 9", "Rank 10"}

_G.Stepped = nil
_G.Clipon = false
_G.rebirthLoop = false
_G.autoBrawl = false

local autoOrbStates = {
    orange = {isRunning = false, shouldStop = false},
    red = {isRunning = false, shouldStop = false},
    yellow = {isRunning = false, shouldStop = false},
    gem = {isRunning = false, shouldStop = false},
    blue = {isRunning = false, shouldStop = false}
}

function identifyDevice()
    local userInputService = game:GetService("UserInputService")
    local platform = userInputService:GetPlatform()
    
    if platform == Enum.Platform.Windows then
        return "电脑 (Windows)"
    elseif platform == Enum.Platform.OSX then
        return "电脑 (Mac)"
    elseif platform == Enum.Platform.Linux then
        return "电脑 (Linux)"
    elseif platform == Enum.Platform.IOS then
        return "移动端 (iOS)"
    elseif platform == Enum.Platform.Android then
        return "移动端 (Android)"
    elseif platform == Enum.Platform.XBoxOne then
        return "游戏主机 (XBox One)"
    elseif platform == Enum.Platform.PS4 then
        return "游戏主机 (PS4)"
    elseif platform == Enum.Platform.PS3 then
        return "游戏主机 (PS3)"
    elseif platform == Enum.Platform.XBox360 then
        return "游戏主机 (XBox 360)"
    elseif platform == Enum.Platform.WiiU then
        return "游戏主机 (Wii U)"
    elseif platform == Enum.Platform.NX then
        return "游戏主机 (Switch)"
    else
        return "其他设备 (" .. tostring(platform) .. ")"
    end
end

function getDeviceThumbnail()
    local userInputService = game:GetService("UserInputService")
    local platform = userInputService:GetPlatform()
    
    if platform == Enum.Platform.Windows then
        return "https://img.icons8.com/ios-filled/150/ffffff/windows10.png"
    elseif platform == Enum.Platform.OSX then
        return "https://img.icons8.com/ios-filled/150/ffffff/mac-client.png"
    elseif platform == Enum.Platform.Linux then
        return "https://img.icons8.com/ios-filled/150/ffffff/linux.png"
    elseif platform == Enum.Platform.IOS then
        return "https://img.icons8.com/ios-filled/150/ffffff/iphone.png"
    elseif platform == Enum.Platform.Android then
        return "https://img.icons8.com/ios-filled/150/ffffff/android.png"
    elseif platform == Enum.Platform.XBoxOne or platform == Enum.Platform.XBox360 then
        return "https://img.icons8.com/ios-filled/150/ffffff/xbox.png"
    elseif platform == Enum.Platform.PS4 or platform == Enum.Platform.PS3 then
        return "https://img.icons8.com/ios-filled/150/ffffff/play-station.png"
    elseif platform == Enum.Platform.WiiU or platform == Enum.Platform.NX then
        return "https://img.icons8.com/ios-filled/150/ffffff/nintendo-switch.png"
    else
        return "https://img.icons8.com/ios-filled/150/ffffff/device-unknown.png"
    end
end

local antiWalkFlingConn

local function enableAntiWalkFling()
    if antiWalkFlingConn then
        antiWalkFlingConn:Disconnect()
    end
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local MAX_VELOCITY_MAGNITUDE = 80
    local TELEPORT_BACK_ON_FLING = true
    local lastPositions = {}

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            local rootPart = character:WaitForChild("HumanoidRootPart")

            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            
            lastPositions[player.UserId] = rootPart.Position
        end)
    end)

    antiWalkFlingConn = RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                
                if rootPart and humanoid and humanoid.Health > 0 then
                    local currentVelocity = rootPart.AssemblyLinearVelocity
                    local velocityMagnitude = currentVelocity.Magnitude

                    if velocityMagnitude > MAX_VELOCITY_MAGNITUDE then
                        if TELEPORT_BACK_ON_FLING and lastPositions[player.UserId] then
                            rootPart.CFrame = CFrame.new(lastPositions[player.UserId])
                        end
                        
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    else
                        lastPositions[player.UserId] = rootPart.Position
                    end
                end
            end
        end
    end)
end

local function disableAntiWalkFling()
    if antiWalkFlingConn then
        antiWalkFlingConn:Disconnect()
        antiWalkFlingConn = nil
    end
end

local espEnabled = false
local espConnections = {}
local espHighlights = {}
local espNameTags = {}

local function createESP(player)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "JYC_ESP"
    highlight.Adornee = char
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    espHighlights[player] = highlight

    local nameTag = Instance.new("BillboardGui")
    nameTag.Name = "JYC_NameTag"
    nameTag.Adornee = humanoidRootPart
    nameTag.Size = UDim2.new(0, 150, 0, 20)
    nameTag.StudsOffset = Vector3.new(0, 2.8, 0)
    nameTag.AlwaysOnTop = true
    nameTag.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.TextScaled = false
    textLabel.Parent = nameTag
    espNameTags[player] = nameTag
end

local function removeESP(player)
    if espHighlights[player] and espHighlights[player].Parent then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
    if espNameTags[player] and espNameTags[player].Parent then
        espNameTags[player]:Destroy()
        espNameTags[player] = nil
    end
end

local function toggleESP(state)
    espEnabled = state
    if state then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                pcall(createESP, player)
            end
        end

        espConnections.playerAdded = game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Wait()
            pcall(createESP, player)
        end)
        espConnections.playerRemoving = game.Players.PlayerRemoving:Connect(function(player)
            removeESP(player)
        end)
    else
        if espConnections.playerAdded then espConnections.playerAdded:Disconnect() end
        if espConnections.playerRemoving then espConnections.playerRemoving:Disconnect() end
        for player, _ in pairs(espHighlights) do
            removeESP(player)
        end
        espHighlights = {}
        espNameTags = {}
    end
end

local selectedPlayer = nil
local playerDropdown

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local Tabs = {
    Main = Window:Tab({ Title = "主页", Icon = "crown" }),
    Extra = Window:Tab({ Title = "极速传奇", Icon = "zap" }),
    Ninja = Window:Tab({ Title = "忍者传奇", Icon = "swords" }),
    Power = Window:Tab({ Title = "力量传奇", Icon = "dumbbell" }),
}

Window:SelectTab(1)

Tabs.Main:Paragraph({
    Title = "By 江砚辰",
    Desc = "脚本免费 请勿倒卖\nQQ号:3395858053",
    Color = "Blue",
})

Tabs.Main:Paragraph({
    Title = "设备信息",
    Desc = "当前设备: " .. identifyDevice(),
    Image = getDeviceThumbnail(),
    ImageSize = 42,
    Thumbnail = getDeviceThumbnail(),
    ThumbnailSize = 80
})

Tabs.Main:Paragraph({
    Title = "666这么帅",
    Desc = "必须帅",
    Image = "https://raw.githubusercontent.com/Guo61/LED/refs/heads/main/1758434950279.png",
    ImageSize = 42,
    Thumbnail = "https://raw.githubusercontent.com/Guo61/Cat-/refs/heads/main/1756468641440.jpg",
    ThumbnailSize = 120
})

Tabs.Main:Button({  
    Title = "反挂机",  
    Desc = "不要随意开启!",  
    Callback = function()  
        WindUI:Notify({  
            Title = "JYC",  
            Content = "正在加载反挂机脚本...",  
            Duration = 3  
        })  

        local url = "https://raw.githubusercontent.com/Guo61/Cat-/refs/heads/main/%E5%8F%8D%E6%8C%82%E6%9C%BA.lua"

        local success, response = pcall(function()  
            return game:HttpGet(url, true)  
        end)  

        if success and response and #response > 100 then  
            local executeSuccess, executeError = pcall(function()  
                loadstring(response)()  
            end)  

            if executeSuccess then  
                WindUI:Notify({  
                    Title = "JYC",  
                    Content = "反挂机脚本加载并执行成功!",  
                    Duration = 5  
                })  
            else  
                WindUI:Notify({  
                    Title = "JYC",  
                    Content = "脚本执行错误: " .. tostring(executeError),  
                    Duration = 5  
                })  
            end  
        else  
            WindUI:Notify({  
                Title = "JYC",  
                Content = "反挂机脚本加载失败，请检查网络",  
                Duration = 5  
            })  
        end  
    end  
})

Tabs.Main:Button({
    Title = "显示FPS",
    Desc = "在屏幕上显示当前FPS",
    Callback = function()
        local FpsGui = Instance.new("ScreenGui") 
        local FpsXS = Instance.new("TextLabel") 
        FpsGui.Name = "FPSGui" 
        FpsGui.ResetOnSpawn = false 
        FpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
        FpsXS.Name = "FpsXS" 
        FpsXS.Size = UDim2.new(0, 100, 0, 50) 
        FpsXS.Position = UDim2.new(0, 10, 0, 10) 
        FpsXS.BackgroundTransparency = 1 
        FpsXS.Font = Enum.Font.SourceSansBold 
        FpsXS.Text = "FPS: 0" 
        FpsXS.TextSize = 20 
        FpsXS.TextColor3 = Color3.new(1, 1, 1) 
        FpsXS.Parent = FpsGui 
        
        local function updateFpsXS()
            local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
            FpsXS.Text = "FPS: " .. fps
        end 
        
        game:GetService("RunService").RenderStepped:Connect(updateFpsXS) 
        FpsGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        WindUI:Notify({
            Title = "JYC",
            Content = "FPS显示已开启",
            Duration = 3
        })
    end
})

Tabs.Main:Toggle({
    Title = "显示范围",
    Desc = "显示玩家范围",
    Callback = function(state)
        local HeadSize = 20
        local highlight = Instance.new("Highlight")
        highlight.Adornee = nil
        highlight.OutlineTransparency = 0
        highlight.FillTransparency = 0.7
        highlight.FillColor = Color3.fromHex("#0000FF")

        local function applyHighlight(character)
            if not character:FindFirstChild("JYC_RangeHighlight") then
                local clone = highlight:Clone()
                clone.Adornee = character
                clone.Name = "JYC_RangeHighlight"
                clone.Parent = character
            end
        end

        local function removeHighlight(character)
            local h = character:FindFirstChild("JYC_RangeHighlight")
            if h then
                h:Destroy()
            end
        end

        if state then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Name ~= game.Players.LocalPlayer.Name and player.Character then
                    applyHighlight(player.Character)
                end
            end
            game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    task.wait(1)
                    applyHighlight(character)
                end)
            end)
            game.Players.PlayerRemoving:Connect(function(player)
                if player.Character then
                    removeHighlight(player.Character)
                end
            end)
        else
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    removeHighlight(player.Character)
                end
            end
        end
    end
})

Tabs.Main:Button({
    Title = "半隐身",
    Desc = "悬浮窗关不掉",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Invisible-35376"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "隐身脚本已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "玩家入退提示",
    Desc = "从GitHub加载并执行提示脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/boyscp/scriscriptsc/main/bbn.lua"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "提示脚本已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "甩飞",
    Desc = "从GitHub加载并执行甩飞脚本",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "甩飞脚本已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Toggle({
    Title = "防甩飞",
    Desc = "不要和甩飞同时开启!",
    Callback = function(state)
        if state then
            enableAntiWalkFling()
            WindUI:Notify({
                Title = "防甩飞",
                Content = "防甩飞已开启",
                Duration = 3
            })
        else
            disableAntiWalkFling()
            WindUI:Notify({
                Title = "防甩飞",
                Content = "防甩飞已关闭",
                Duration = 3
            })
        end
    end
})

Tabs.Main:Toggle({
    Title = "人物透视 (ESP)",
    Desc = "显示其他玩家的透视框和名字",
    Callback = toggleESP
})

local playerNames = getPlayerNames()
playerDropdown = Tabs.Main:Dropdown({
    Title = "选择要传送的玩家",
    Values = playerNames,
    Callback = function(value)
        selectedPlayer = value
        WindUI:Notify({
            Title = "玩家选择",
            Content = "已选择玩家: " .. value,
            Duration = 2
        })
    end
})

Tabs.Main:Button({
    Title = "传送至选中玩家",
    Desc = "传送到选中的玩家",
    Callback = function()
        if not selectedPlayer then
            WindUI:Notify({
                Title = "传送失败",
                Content = "请先选择一个玩家",
                Duration = 3
            })
            return
        end
        
        local targetPlayer = game.Players:FindFirstChild(selectedPlayer)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            WindUI:Notify({
                Title = "传送成功",
                Content = "已传送到玩家: " .. selectedPlayer,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "传送失败",
                Content = "无法找到目标玩家或玩家没有角色",
                Duration = 3
            })
        end
    end
})

Tabs.Main:Button({
    Title = "刷新玩家列表",
    Desc = "手动刷新可传送的玩家列表",
    Callback = function()
        local newPlayers = getPlayerNames()
        playerDropdown:Refresh(newPlayers)
        WindUI:Notify({
            Title = "玩家列表",
            Content = "玩家列表已刷新，当前玩家数: " .. (#newPlayers),
            Duration = 3
        })
    end
})

Tabs.Main:Slider({
    Title = "设置速度",
    Desc = "可输入",
    Value = {
        Min = 0,
        Max = 520,
        Default = 25,
    },
    Callback = function(val)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then
            character = player.CharacterAdded:Wait()
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = val
        end
    end
})

Tabs.Main:Slider({
    Title = "设置跳跃高度",
    Desc = "可输入",
    Value = {
        Min = 0,
        Max = 200,
        Default = 50,
    },
    Callback = function(val)
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then
            character = player.CharacterAdded:Wait()
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = val
        end
    end
})

Tabs.Main:Button({
    Title = "飞行",
    Desc = "从GitHub加载并执行飞行脚本",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Guo61/Cat-/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%AC.lua"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "飞行脚本已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "无限跳",
    Desc = "概率关不了",
    Callback = function()
       loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
        WindUI:Notify({
            Title = "JYC",
            Content = "无限跳已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "自瞄",
    Desc = "宙斯自瞄",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20Aimbot.lua"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "自瞄已加载并执行",
            Duration = 3
        })
    end
})

Tabs.Main:Toggle({
    Title = "子弹追踪",
    Callback = function(state)
        WindUI:Notify({
            Title = "子弹追踪",
            Content = state and "已开启" or "已关闭",
            Duration = 2
        })
    end
})

Tabs.Main:Toggle({
    Title = "夜视",
    Callback = function(isEnabled)
        WindUI:Notify({
            Title = "夜视",
            Content = isEnabled and "已开启" or "已关闭",
            Duration = 2
        })
    end
})

Tabs.Main:Toggle({
    Title = "穿墙",
    Callback = function(NC)
        WindUI:Notify({
            Title = "穿墙",
            Content = NC and "已开启" or "已关闭",
            Duration = 2
        })
    end
})

Tabs.Main:Button({
    Title = "切换服务器",
    Desc = "切换到相同游戏的另一个服务器",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
        WindUI:Notify({
            Title = "服务器",
            Content = "正在切换服务器...",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "重新加入服务器",
    Desc = "尝试重新加入当前服务器",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        TeleportService:TeleportToPlaceInstance(placeId, jobId, game.Players.LocalPlayer)
        WindUI:Notify({
            Title = "服务器",
            Content = "正在重新加入服务器...",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "复制服务器邀请链接",
    Desc = "复制当前服务器的邀请链接到剪贴板",
    Callback = function()
        local inviteLink = "roblox://experiences/start?placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
        setclipboard(inviteLink)
        WindUI:Notify({
            Title = "服务器",
            Content = "邀请链接已复制到剪贴板",
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "复制服务器ID",
    Desc = "复制当前服务器的Job ID到剪贴板",
    Callback = function()
        setclipboard(game.JobId)
        WindUI:Notify({
            Title = "服务器",
            Content = "服务器ID已复制: " .. game.JobId,
            Duration = 3
        })
    end
})

Tabs.Main:Button({
    Title = "服务器信息",
    Desc = "显示当前服务器的信息",
    Callback = function()
        local players = game.Players:GetPlayers()
        local maxPlayers = game.Players.MaxPlayers
        local placeId = game.PlaceId
        local jobId = game.JobId
        local serverType = game:GetService("RunService"):IsStudio() and "Studio" or "Live"
        
        WindUI:Notify({
            Title = "服务器信息",
            Content = string.format("玩家数量: %d/%d\nPlace ID: %d\nJob ID: %s\n服务器类型: %s", #players, maxPlayers, placeId, jobId, serverType),
            Duration = 10
        })
    end
})

Tabs.Main:Paragraph({
    Title = "Love Players",
    Desc = "感谢游玩\nQQ号:3395858053",
    Color = "Green",
})

Tabs.Extra:Paragraph({
    Title = "提示!!!",
    Desc = "传送功能请勿在其他服务器执行\n该服务器功能暂未补全",
    Color = "Red",
})

Tabs.Extra:Section({ Title = "传送" })

local teleportLocations = {
    {"城市", CFrame.new(-534.38, 4.07, 437.75)},
    {"神秘洞穴", CFrame.new(-9683.05, 59.25, 3136.63)},
    {"草地挑战", CFrame.new(-1550.49, 34.51, 87.48)},
    {"海市蜃楼挑战", CFrame.new(1414.31, 90.44, -2058.34)},
    {"冰霜挑战", CFrame.new(2045.63, 64.57, 993.17)},
    {"绿色水晶", CFrame.new(385.60, 65.02, 19.00)},
    {"蓝色水晶", CFrame.new(-581.56, 4.12, 495.92)},
    {"紫色水晶", CFrame.new(-428.17, 4.12, 203.52)},
    {"黄色水晶", CFrame.new(-313.23, 4.12, -375.43)},
    {"欧米茄水晶", CFrame.new(4532.49, 74.45, 6398.68)},
}

for _, location in ipairs(teleportLocations) do
    Tabs.Extra:Button({
        Title = location[1],
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = location[2]
            WindUI:Notify({
                Title = "通知",
                Content = "传送成功",
                Duration = 1
            })
        end
    })
end

Tabs.Extra:Section({ Title = "自动" })

_G.auto_hoop = false

local function auto_hoop()
    while _G.auto_hoop do
        wait()
        local children = workspace.Hoops:GetChildren()
        for i, child in ipairs(children) do
            if child.Name == "Hoop" then
                child.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end    
        end
    end
end

Tabs.Extra:Toggle({
    Title = "自动跳圈",
    Desc = "单机以执行/关闭",
    Callback = function(Value)
        _G.auto_hoop = Value
        if Value then
            auto_hoop()
            WindUI:Notify({
                Title = "自动跳圈",
                Content = "自动跳圈已开启",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "自动跳圈",
                Content = "自动跳圈已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Extra:Toggle({
    Title = "自动重生",
    Desc = "ARS",
    Callback = function(ARS)
        if ARS then
            _G.rebirthLoop = true
            while _G.rebirthLoop and task.wait() do
                game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
            end
        else
            _G.rebirthLoop = false
        end
    end
})

Tabs.Extra:Button({
    Title = "自动重生和自动刷等级",
    Desc = "单击执行",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Guo61/1111/refs/heads/main/%E8%87%AA%E5%8A%A8%E5%88%B7.lua"))()
        WindUI:Notify({
            Title = "JYC",
            Content = "自动重生和刷等级脚本已加载",
            Duration = 3
        })
    end
})

local isRunning = false
local shouldStop = false

local function createOrbButton(title, orbType)
    Tabs.Extra:Button({
        Title = title,
        Desc = "单击以执行/停止",
        Callback = function()
            if not isRunning then
                spawn(function()
                    shouldStop = false
                    while true do
                        if shouldStop then
                            break
                        end
                        local args = {
                            "collectOrb",
                            orbType,
                            "City"
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("orbEvent"):FireServer(unpack(args))
                        wait(0.5)
                    end
                    isRunning = false
                end)
                isRunning = true
                WindUI:Notify({
                    Title = "通知",
                    Content = "正在执行",
                    Duration = 1
                })
            else
                shouldStop = true
                isRunning = false
                WindUI:Notify({
                    Title = "通知",
                    Content = "已停止执行",
                    Duration = 1
                })
            end
        end
    })
end

createOrbButton("自动吃橙球(city)", "Orange Orb")
createOrbButton("自动吃红球(city)", "Red Orb")
createOrbButton("自动吃黄球(city)", "Yellow Orb")
createOrbButton("自动吃蓝球(city)", "Blue Orb")

Tabs.Extra:Section({ Title = "速刷" })

local bugPets = false

Tabs.Extra:Toggle({
    Title = "经验速刷",
    Callback = function(Value)
        bugPets = Value
        if Value then
            WindUI:Notify({
                Title = "JYC",
                Content = "已开启",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "JYC",
                Content = "已关闭",
                Duration = 3
            })
        end
        
        while bugPets do
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", "City")
            game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest")
            wait(0.1)
        end
    end
})

Tabs.Extra:Toggle({
    Title = "自动比赛",
    Desc = "当有比赛时自动参加比赛",
    Callback = function(state)
        _G.autoRace = state
        if state then
            WindUI:Notify({
                Title = "自动比赛",
                Content = "自动比赛已开启",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "自动比赛",
                Content = "自动比赛已关闭",
                Duration = 2
            })
        end
        
        while _G.autoRace do
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("raceEvent"):FireServer("joinRace")
            end)
            wait(0.1)
        end
    end
})

Tabs.Extra:Section({ Title = "宠物" })

Tabs.Extra:Toggle({
    Title = "自动卡宠",
    Desc = "卡宠搭配速刷使用",
    Callback = function(state)
        _G.Evolve = state
        if state then
            WindUI:Notify({
                Title = "自动卡宠",
                Content = "自动卡宠已开启",
                Duration = 2
            })
            
            game.StarterGui:SetCore("SendNotification", { Title = "Advanced Logic"; Text = "请加入684407929{Advanced Logic}购买俄亥俄州最强脚本!" }) 
            spawn(function() 
                while wait() do 
                    game:GetService("ReplicatedStorage").rEvents.rebirthEvent:FireServer("rebirthRequest") 
                end 
            end) 
            while _G.Evolve do
                wait(0.1)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
                local A_1 = "collectOrb"
                local A_2 = "Yellow Orb"
                local A_3 = "City"
                local Event = game:GetService("ReplicatedStorage").rEvents.orbEvent
                Event:FireServer(A_1, A_2, A_3)
            end
        else
            WindUI:Notify({
                Title = "自动卡宠",
                Content = "自动卡宠已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Extra:Button({
    Title = "收集全部宝箱",
    Desc = "一键收集所有宝箱奖励",
    Callback = function()
        for _, v in pairs(game.ReplicatedStorage.chestRewards:GetChildren()) do
            game.ReplicatedStorage.rEvents.checkChestRemote:InvokeServer(v.Name)
        end
        WindUI:Notify({
            Title = "宝箱收集",
            Content = "已尝试收集所有宝箱",
            Duration = 3
        })
    end
})

Tabs.Extra:Button({
    Title = "解锁全部通行证",
    Desc = "一键解锁所有游戏通行证",
    Callback = function()
        for i, v in ipairs(game:GetService("ReplicatedStorage").gamepassIds:GetChildren()) do
            v.Parent = game.Players.LocalPlayer.ownedGamepasses
        end
        WindUI:Notify({
            Title = "通行证解锁",
            Content = "已尝试解锁所有通行证",
            Duration = 3
        })
    end
})

local petshow = {"all", "pet1", "pet2", "pet3"}
local EvolvePet = "all"

Tabs.Extra:Dropdown({
    Title = "选择进化的宠物",
    Desc = "选择要进化的特定宠物",
    Values = petshow,
    Callback = function(Value)
        EvolvePet = Value
        WindUI:Notify({
            Title = "宠物选择",
            Content = "已选择宠物: " .. Value,
            Duration = 2
        })
    end
})

Tabs.Extra:Button({
    Title = "进化选中宠物",
    Desc = "手动进化选中的宠物",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer("evolvePet", EvolvePet)
        WindUI:Notify({
            Title = "宠物进化",
            Content = "正在进化宠物: " .. EvolvePet,
            Duration = 2
        })
    end
})

local LS = {evolvepet = false}

Tabs.Extra:Toggle({
    Title = "自动进化选中宠物",
    Desc = "自动进化选中的特定宠物",
    Callback = function(state)
        LS.evolvepet = state
        if state then
            WindUI:Notify({
                Title = "自动进化",
                Content = "开始自动进化: " .. EvolvePet,
                Duration = 2
            })
            while LS.evolvepet do
                game:GetService("ReplicatedStorage").rEvents.petEvolveEvent:FireServer("evolvePet", EvolvePet)
                wait()
            end
        else
            WindUI:Notify({
                Title = "自动进化",
                Content = "自动进化已停止",
                Duration = 2
            })
        end
    end
})

Tabs.Extra:Paragraph({
    Title = "宠物商店",
    Desc = "尾迹或宠物满了都会导致功能失效",
    Color = "Orange",
})

local jc = {"火焰刺猬"}
local hc = {"融魂小狗","黑魂小鸟","永恒星云龙","超音速飞马","影锋小猫","终极超速小兔"}
local wj = {"第一尾迹"}

local selectedPet = nil
local selectedPetName = nil

Tabs.Extra:Dropdown({
    Title = "传说宠物",
    Values = jc,
    Callback = function(Value)
        selectedPet = Value
        if selectedPet == "火焰刺猬" then
            selectedPetName = "Flaming Hedgehog"
        end
        WindUI:Notify({
            Title = "宠物选择",
            Content = "已选择: " .. Value,
            Duration = 2
        })
    end
})

Tabs.Extra:Dropdown({
    Title = "欧米茄宠物",
    Values = hc,
    Callback = function(Value)
        selectedPet = Value
        if selectedPet == "融魂小狗" then
            selectedPetName = "Soul Fusion Dog"
        elseif selectedPet == "黑魂小鸟" then
            selectedPetName = "Dark Soul Birdie"
        elseif selectedPet == "永恒星云龙" then
            selectedPetName = "Eternal Nebula Dragon"
        elseif selectedPet == "超音速飞马" then
            selectedPetName = "Hypersonic Pegasus"
        elseif selectedPet == "影锋小猫" then
            selectedPetName = "Shadows Edge Kitty"
        elseif selectedPet == "终极超速小兔" then
            selectedPetName = "Ultimate Overdrive Bunny"
        end
        WindUI:Notify({
            Title = "宠物选择",
            Content = "已选择: " .. Value,
            Duration = 2
        })
    end
})

Tabs.Extra:Dropdown({
    Title = "传说尾迹",
    Values = wj,
    Callback = function(Value)
        selectedPet = Value
        if selectedPet == "第一尾迹" then
            selectedPetName = "1st Trail"
        end
        WindUI:Notify({
            Title = "尾迹选择",
            Content = "已选择: " .. Value,
            Duration = 2
        })
    end
})

local priceDisplay = Tabs.Extra:Paragraph({
    Title = "所需宝石",
    Desc = "请先选择宠物",
})

local currentSelectionDisplay = Tabs.Extra:Paragraph({
    Title = "当前选择",
    Desc = "未选择",
})

local function updatePriceDisplay()
    if selectedPetName then
        local petShopFolder = game:GetService("ReplicatedStorage"):FindFirstChild("cPetShopFolder")
        if petShopFolder then
            local petItem = petShopFolder:FindFirstChild(selectedPetName)
            if petItem and petItem:FindFirstChild("priceValue") then
                priceDisplay:SetDesc(petItem.priceValue.Value)
                currentSelectionDisplay:SetDesc(selectedPet)
                return
            end
        end
    end
    priceDisplay:SetDesc("无法获取价格")
    currentSelectionDisplay:SetDesc(selectedPet or "未选择")
end

_G.autoBuyPet = false

local function autoBuyPetFunction()
    while _G.autoBuyPet and selectedPetName do
        pcall(function()
            local petShopFolder = game:GetService("ReplicatedStorage"):FindFirstChild("cPetShopFolder")
            if petShopFolder then
                local petItem = petShopFolder:FindFirstChild(selectedPetName)
                if petItem then
                    game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(petItem)
                end
            end
        end)
        wait(0.1)
    end
end

Tabs.Extra:Toggle({
    Title = "自动购买宠物",
    Desc = "开启后会自动购买选中的宠物",
    Callback = function(Value)
        _G.autoBuyPet = Value
        if Value then
            if not selectedPetName then
                WindUI:Notify({
                    Title = "错误",
                    Content = "请先选择一个宠物",
                    Duration = 3
                })
                _G.autoBuyPet = false
                return
            end
            spawn(autoBuyPetFunction)
            WindUI:Notify({
                Title = "自动购买",
                Content = "开始自动购买: " .. selectedPet,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "自动购买",
                Content = "已停止自动购买",
                Duration = 2
            })
        end
    end
})

Tabs.Extra:Button({
    Title = "刷新价格",
    Desc = "更新选中宠物的价格显示",
    Callback = function()
        updatePriceDisplay()
        WindUI:Notify({
            Title = "刷新成功",
            Content = "价格信息已更新",
            Duration = 2
        })
    end
})

spawn(function()
    while wait(1) do
        updatePriceDisplay()
    end
end)

updatePriceDisplay()

Tabs.Ninja:Paragraph({
    Title = "忍者传奇",
    Desc = "执行以下功能时请手持剑\n传送功能请勿在其他服务器执行",
    Color = "Red",
})

Tabs.Ninja:Toggle({
    Title = "自动挥剑",
    Callback = function(ATHW)
        getgenv().autoswing = ATHW
        while getgenv().autoswing do
            if not getgenv().autoswing then return end
            
            for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool:FindFirstChild("ninjitsuGain") then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                    break
                end
            end
            
            local A_1 = "swingKatana"
            game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(A_1)
            wait()
        end
    end
})

Tabs.Ninja:Toggle({
    Title = "自动售卖",
    Callback = function(ATSELL)
        getgenv().autosell = ATSELL 
        while getgenv().autosell do
            if not getgenv().autosell then return end
            local sellArea = game:GetService("Workspace").sellAreaCircles["sellAreaCircle16"]
            if sellArea then
                sellArea.circleInner.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                wait(0.1)
                sellArea.circleInner.CFrame = CFrame.new(0,0,0)
                wait(0.1)
            end
        end
    end
})

Tabs.Ninja:Toggle({
    Title = "自动购买排名",
    Callback = function(ATBP)
        getgenv().autobuyranks = ATBP 
        while getgenv().autobuyranks do
            if not getgenv().autobuyranks then return end
            local deku1 = "buyRank"
            for i = 1, #ranks do
                game:GetService("Players").LocalPlayer.ninjaEvent:FireServer(deku1, ranks[i])
            end
            wait(0.1)
        end
    end
})

Tabs.Ninja:Toggle({
    Title = "自动购买腰带",
    Callback = function(ATBYD)
        getgenv().autobuybelts = ATBYD 
        while getgenv().autobuybelts do
            if not getgenv().autobuybelts then return end
            local A_1 = "buyAllBelts"
            local A_2 = "Inner Peace Island"
            local Event = game:GetService("Players").LocalPlayer.ninjaEvent
            Event:FireServer(A_1, A_2)
            wait(0.5)
        end
    end
})

Tabs.Ninja:Toggle({
    Title = "自动购买技能",
    Callback = function(ATB)
        getgenv().autobuyskills = ATB 
        while getgenv().autobuyskills do
            if not getgenv().autobuyskills then return end
            local A_1 = "buyAllSkills"
            local A_2 = "Inner Peace Island"
            local Event = game:GetService("Players").LocalPlayer.ninjaEvent
            Event:FireServer(A_1, A_2)
            wait(0.5)
        end
    end
})

Tabs.Ninja:Toggle({
    Title = "自动购买剑",
    Callback = function(ATBS)
        getgenv().autobuy = ATBS 
        while getgenv().autobuy do
            if not getgenv().autobuy then return end
            local A_1 = "buyAllSwords"
            local A_2 = "Inner Peace Island"
            local Event = game:GetService("Players").LocalPlayer.ninjaEvent
            Event:FireServer(A_1, A_2)
            wait(0.5)
        end
    end
})

Tabs.Ninja:Button({
    Title = "解锁所有岛",
    Callback = function()
        for _, v in next, game.workspace.islandUnlockParts:GetChildren() do
            if v then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.islandSignPart.CFrame
                wait(0.5)
            end
        end
        WindUI:Notify({
            Title = "解锁成功",
            Content = "所有岛屿已解锁",
            Duration = 2
        })
    end
})

Tabs.Ninja:Section({ Title = "传送功能" })

local basicIslands = {
    {"出生点", CFrame.new(25.665502548217773, 3.4228405952453613, 29.919952392578125)},
    {"附魔岛", CFrame.new(51.17238235473633, 766.1807861328125, -138.44842529296875)},
    {"神秘岛", CFrame.new(171.97178449902344, 4047.380859375, 42.0699577331543)},
    {"太空岛", CFrame.new(148.83824157714844, 5657.18505859375, 73.5014877319336)},
    {"冻土岛", CFrame.new(139.28330993652344, 9285.18359375, 77.36406707763672)},
    {"永恒岛", CFrame.new(149.34817504882812, 13680.037109375, 73.3861312866211)},
    {"沙暴岛", CFrame.new(133.37144470214844, 17686.328125, 72.00334167480469)},
    {"雷暴岛", CFrame.new(143.19349670410156, 24070.021484375, 78.05432891845703)},
    {"远古炼狱岛", CFrame.new(141.27163696289062, 28256.294921875, 69.3790283203125)},
    {"午夜暗影岛", CFrame.new(132.74267578125, 33206.98046875, 57.49557495117875)},
    {"神秘灵魂岛", CFrame.new(137.76148986816406, 39317.5703125, 61.06639862060547)},
    {"冬季奇迹岛", CFrame.new(137.2720184326172, 46010.5546875, 55.941951751708984)},
    {"黄金大师岛", CFrame.new(128.32339477539062, 52607.765625, 56.69411849975586)},
    {"龙传奇岛", CFrame.new(146.35226440429688, 59594.6796875, 77.53300476074219)}
}

for _, island in ipairs(basicIslands) do
    Tabs.Ninja:Button({
        Title = "传送到" .. island[1],
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = island[2]
            WindUI:Notify({
                Title = "传送成功",
                Content = "已传送到" .. island[1],
                Duration = 2
            })
        end
    })
end

Tabs.Power:Section({ Title = "战斗功能" })

Tabs.Power:Toggle({
    Title = "自动加入战斗",
    Desc = "自动加入战斗模式",
    Callback = function(Value)
        if Value then
            _G.autoJoinBrawl = true
            spawn(function()
                while _G.autoJoinBrawl do
                    game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl")
                    wait()
                end
            end)
            WindUI:Notify({
                Title = "自动加入战斗",
                Content = "已开启",
                Duration = 2
            })
        else
            _G.autoJoinBrawl = false
            WindUI:Notify({
                Title = "自动加入战斗",
                Content = "已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Power:Toggle({
    Title = "挥拳无CD",
    Desc = "移除挥拳冷却时间",
    Callback = function(Value)
        if Value then
            local punch = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch then
                local numberValue = punch:FindFirstChildOfClass("NumberValue")
                if numberValue then
                    numberValue.Value = 0
                end
            end
            WindUI:Notify({
                Title = "挥拳无CD",
                Content = "已开启",
                Duration = 2
            })
        else
            local punch = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Punch")
            if punch then
                local numberValue = punch:FindFirstChildOfClass("NumberValue")
                if numberValue then
                    numberValue.Value = 1
                end
            end
            WindUI:Notify({
                Title = "挥拳无CD",
                Content = "已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Power:Toggle({
    Title = "全图打人",
    Desc = "全图打人",
    Callback = function(Value)
        _G.fullMapAttack = Value
        if Value then
            spawn(function()
                while _G.fullMapAttack do
                    wait()
                    for _, player in pairs(game:GetService('Players'):GetPlayers()) do
                        if player.Name ~= game:GetService('Players').LocalPlayer.Name and player.Character then
                            pcall(function()
                                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    rootPart.Size = Vector3.new(1000000000, 1000000000, 1000000000)
                                    rootPart.Transparency = 1
                                    rootPart.BrickColor = BrickColor.new("Really red")
                                    rootPart.Material = "Neon"
                                    rootPart.CanCollide = false
                                end
                            end)
                        end
                    end
                end
            end)
            WindUI:Notify({
                Title = "全图打人",
                Content = "已开启",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "全图打人",
                Content = "已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动比赛开关",
    Callback = function(AR)
        _G.autoBrawl = AR
        while _G.autoBrawl do
            wait(2)
            game:GetService("ReplicatedStorage").Events.brawlEvent:FireServer("joinBrawl")
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动举哑铃",
    Callback = function(ATYL)
        _G.autoWeight = ATYL
        if ATYL then
            local part = Instance.new("Part", workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            part.Transparency = 1
            _G.weightPart = part
        else
            if _G.weightPart then
                _G.weightPart:Destroy()
                _G.weightPart = nil
            end
        end
        
        while _G.autoWeight do
            wait()
            if _G.weightPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.weightPart.CFrame + Vector3.new(0, 50, 0)
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and v.Name == "Weight" then
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
                game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            end
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动俯卧撑",
    Callback = function(ATFWC)
        _G.autoPushups = ATFWC
        if ATFWC then
            local part = Instance.new("Part", workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            part.Transparency = 1
            _G.pushupsPart = part
        else
            if _G.pushupsPart then
                _G.pushupsPart:Destroy()
                _G.pushupsPart = nil
            end
        end
        
        while _G.autoPushups do
            wait()
            if _G.pushupsPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.pushupsPart.CFrame + Vector3.new(0, 50, 0)
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and v.Name == "Pushups" then
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
                game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            end
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动仰卧起坐",
    Callback = function(ATYWQZ)
        _G.autoSitups = ATYWQZ
        if ATYWQZ then
            local part = Instance.new("Part", workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            part.Transparency = 1
            _G.situpsPart = part
        else
            if _G.situpsPart then
                _G.situpsPart:Destroy()
                _G.situpsPart = nil
            end
        end
        
        while _G.autoSitups do
            wait()
            if _G.situpsPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.situpsPart.CFrame + Vector3.new(0, 50, 0)
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and v.Name == "Situps" then
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
                game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            end
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动倒立身体",
    Callback = function(ATDL)
        _G.autoHandstands = ATDL
        if ATDL then
            local part = Instance.new("Part", workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            part.Transparency = 1
            _G.handstandsPart = part
        else
            if _G.handstandsPart then
                _G.handstandsPart:Destroy()
                _G.handstandsPart = nil
            end
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            end
        end
        
        while _G.autoHandstands do
            wait()
            if _G.handstandsPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.handstandsPart.CFrame + Vector3.new(0, 50, 0)
                for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and v.Name == "Handstands" then
                        v.Parent = game.Players.LocalPlayer.Character
                    end
                end
                game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            end
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动锻炼",
    Callback = function(ATAAA)
        _G.autoTrain = ATAAA
        if ATAAA then
            local part = Instance.new("Part", workspace)
            part.Size = Vector3.new(500, 20, 530.1)
            part.Position = Vector3.new(0, 100000, 133.15)
            part.CanCollide = true
            part.Anchored = true
            part.Transparency = 1
            _G.trainPart = part
        else
            if _G.trainPart then
                _G.trainPart:Destroy()
                _G.trainPart = nil
            end
        end
        
        while _G.autoTrain do
            wait()
            if _G.trainPart then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = _G.trainPart.CFrame + Vector3.new(0, 50, 0)
                for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and (v.Name == "Handstands" or v.Name == "Situps" or v.Name == "Pushups" or v.Name == "Weight") then
                        if v:FindFirstChildOfClass("NumberValue") then
                            v:FindFirstChildOfClass("NumberValue").Value = 0
                        end
                        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        game.Players.LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(v)
                        game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
                    end
                end
            end
        end
    end
})

Tabs.Power:Toggle({
    Title = "自动重生",
    Callback = function(ATRE)
        _G.autoRebirth = ATRE
        while _G.autoRebirth do
            wait()
            game:GetService("ReplicatedStorage").Events.rebirthRemote:InvokeServer("rebirthRequest")
        end
    end
})

Tabs.Power:Section({ Title = "抽宠功能" })

Tabs.Power:Button({
    Title = "蓝色水晶（1000水晶）（0重生）",
    Desc = "打开蓝色水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Blue Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开蓝色水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "绿色水晶（3000水晶）（0重生）",
    Desc = "打开绿色水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Green Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开绿色水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "冰霜水晶（5000水晶）（1重生）",
    Desc = "打开冰霜水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Frost Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开冰霜水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "神话水晶（8000水晶）（5重生）",
    Desc = "打开神话水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Mythical Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开神话水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "地狱火水晶（15000水晶）（15重生）",
    Desc = "打开地狱火水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Inferno Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开地狱火水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "传奇水晶（30000水晶）（30重生）",
    Desc = "打开传奇水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Legends Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开传奇水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "力量精英水晶（100万水晶）（30重生）",
    Desc = "打开力量精英水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Muscle Elite Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开力量精英水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Button({
    Title = "力量之王水晶（1.500万水晶）（5重生）",
    Desc = "打开力量之王水晶",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", "Galaxy Oracle Crystal")
        WindUI:Notify({
            Title = "抽宠",
            Content = "已打开力量之王水晶",
            Duration = 2
        })
    end
})

Tabs.Power:Section({ Title = "其他功能" })

Tabs.Power:Toggle({
    Title = "自动刷业报",
    Desc = "随机传送到其他玩家",
    Callback = function(Value)
        _G.autoKarma = Value
        if Value then
            spawn(function()
                while _G.autoKarma do
                    local players = game.Players:GetPlayers()
                    if #players > 1 then
                        local randomPlayer = players[math.random(1, #players)]
                        if randomPlayer ~= game.Players.LocalPlayer and randomPlayer.Character then
                            local head = randomPlayer.Character:FindFirstChild("Head")
                            if head then
                                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(head.Position)
                            end
                        end
                    end
                    wait(0.2)
                end
            end)
            WindUI:Notify({
                Title = "自动刷业报",
                Content = "已开启",
                Duration = 2
            })
        else
            WindUI:Notify({
                Title = "自动刷业报",
                Content = "已关闭",
                Duration = 2
            })
        end
    end
})

Tabs.Power:Section({ Title = "传送" })

Tabs.Power:Toggle({
    Title = "X-安全地方",
    Desc = "切换安全位置",
    Callback = function(Place)
        if Place then
            getgenv().place = true
            while getgenv().place do
                wait()
                game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = 
                CFrame.new(-51.6716728, 32.2157211, 1290.41211, 0.9945544, 1.23613528e-08, 
                0.104218982, -7.58742402e-09, 1, 4.62031657e-08, 0.104218982, 
                4.51608102e-08, 0.9945544)
            end
        else
            getgenv().place = false
            wait()
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = 
            CFrame.new(-34.1635208, 3.67689133, 219.640869, 0.599920511, 
            2.24152163e-09, 0.800059617, 4.46125981e-09, 1, -5.43559087e-10, 
            0.800059617, 3.89536625e-09, 0.599920511)
        end
    end
})

local powerTeleports = {
    {"出生点", CFrame.new(7, 3, 108)},
    {"冰霜健身房", CFrame.new(-2543, 13, -410)},
    {"神话健身房", CFrame.new(2177, 13, 1070)},
    {"永恒健身房", CFrame.new(-6686, 13, -1284)},
    {"传说健身房", CFrame.new(4676, 997, -3915)},
    {"肌肉之王健身房", CFrame.new(-8554, 22, -5642)},
    {"安全岛", CFrame.new(-39, 10, 1838)},
    {"幸运抽奖区域", CFrame.new(-2606, -2, 5753)},
}

for _, location in ipairs(powerTeleports) do
    Tabs.Power:Button({
        Title = "传送到" .. location[1],
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = location[2]
            WindUI:Notify({
                Title = "传送成功",
                Content = "已传送到" .. location[1],
                Duration = 2
            })
        end
    })
end

WindUI:Notify({
    Title = "JYC脚本",
    Content = "脚本加载完成，感谢使用！",
    Duration = 5
})

Window:OnClose(function()
    print("JYC脚本已关闭")
end)