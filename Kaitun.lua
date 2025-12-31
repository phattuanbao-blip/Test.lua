repeat task.wait() until game:IsLoaded()

-- [[ DATABASE & SETTINGS ]]
local WorldData = {
    [2753915549] = { -- SEA 1
        {Lv = 0, Name = "Bandit", NPC = CFrame.new(1059, 15, 1545), QName = "BanditQuest1", QID = 1},
        {Lv = 10, Name = "Monkey", NPC = CFrame.new(-1601, 36, 153), QName = "JungleQuest", QID = 1},
        {Lv = 30, Name = "Pirate", NPC = CFrame.new(-1140, 4, 3827), QName = "BuggyQuest1", QID = 1},
        {Lv = 120, Name = "Chief Petty Officer", NPC = CFrame.new(-4853, 22, 4262), QName = "MarineQuest1", QID = 2},
        {Lv = 575, Name = "Military Soldier", NPC = CFrame.new(-5414, 15, -5747), QName = "MagmaQuest", QID = 1}
    },
    [4442272183] = { -- SEA 2
        {Lv = 700, Name = "Raider", NPC = CFrame.new(-427, 72, 1836), QName = "Area1Quest", QID = 1},
        {Lv = 1000, Name = "Don Swan", NPC = CFrame.new(2289, 15, 905), QName = "SwanQuest", QID = 1},
        {Lv = 1350, Name = "Arctic Warrior", NPC = CFrame.new(-6060, 15, -5005), QName = "SnowMountainQuest", QID = 1}
    },
    [7449423635] = { -- SEA 3
        {Lv = 1500, Name = "Pirate Millionaire", NPC = CFrame.new(-288, 13, 5366), QName = "MarineQuest2", QID = 1},
        {Lv = 1800, Name = "Forest Pirate", NPC = CFrame.new(-12106, 15, -10500), QName = "DeepForestQuest", QID = 1},
        {Lv = 2500, Name = "Sun-kissed Warrior", NPC = CFrame.new(-15644, 11, 444), QName = "CandyQuest", QID = 1}
    }
}

_G.Settings = {
    Kaitun = true,
    AutoStats = true,
    FastAttack = true,
    LongRange = true, 
    Hitbox = 75,
    Distance = 25,
    AutoCDK = true,
    AutoSoulGuitar = true,
    AutoRaid = true,
    AutoEvent = true
}

local plr = game.Players.LocalPlayer
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
local TW = game:GetService("TweenService")

-- [[ CORE FUNCTIONS ]]
function _tp(target)
    pcall(function()
        if not target then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if not root:FindFirstChild("Vel") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "Vel"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0,0,0); bv.Parent = root
        end
        local dist = (target.p - root.Position).Magnitude
        local speed = dist < 200 and 600 or 320
        TW:Create(root, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = target}):Play()
    end)
end

spawn(function()
    while task.wait() do
        if _G.Settings.FastAttack then
            pcall(function()
                local tool = plr.Character:FindFirstChildOfClass("Tool")
                if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
                    if _G.Settings.LongRange and tool:FindFirstChild("Handle") then
                        tool.Handle.Size = Vector3.new(_G.Settings.Hitbox, _G.Settings.Hitbox, _G.Settings.Hitbox)
                        tool.Handle.CanCollide = false
                    end
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                end
            end)
        end
    end
end)

-- [[ AUTOMATION MODULES ]]
spawn(function()
    while task.wait(0.1) do
        if os.date("*t").min == 59 then
            _G.Pause = true
            _tp(CFrame.new(-13480, 517, -185))
            task.wait(62)
            _G.Pause = false
        end
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Fruit") or v.Name:find("Gift")) then
                _tp(v.Handle.CFrame)
                firetouchinterest(plr.Character.HumanoidRootPart, v.Handle, 0)
                firetouchinterest(plr.Character.HumanoidRootPart, v.Handle, 1)
                CommF:InvokeServer("StoreFruit", v.Name, v)
            end
        end
        if _G.Settings.AutoEvent then CommF:InvokeServer("CandyRetriever", "Random Fruit", 1) end
    end
end)

spawn(function()
    while task.wait(5) do
        if _G.Settings.AutoRaid and plr.Data.Level.Value >= 1100 then
            if not plr.PlayerGui.Main.TopHUDList.RaidTimer.Visible then
                CommF:InvokeServer("RaidsNpc", "Select", "Flame")
                CommF:InvokeServer("RaidsNpc", "Start")
            end
            CommF:InvokeServer("Awakener", "Awake")
        end
    end
end)

-- [[ MAIN ENGINE ]]
spawn(function()
    while task.wait() do
        if _G.Settings.Kaitun and not _G.Pause then
            pcall(function()
                local lv = plr.Data.Level.Value
                if _G.Settings.AutoStats then
                    CommF:InvokeServer("AddPoint", "Melee", 3)
                    CommF:InvokeServer("AddPoint", "Defense", 3)
                end

                if lv >= 700 and game.PlaceId == 2753915549 then CommF:InvokeServer("DressAndGoToSecondSea")
                elseif lv >= 1500 and game.PlaceId == 4442272183 then CommF:InvokeServer("DressAndGoToThirdSea") end

                if not plr.PlayerGui.Main.Quest.Visible then
                    local target
                    for _, q in ipairs(WorldData[game.PlaceId]) do
                        if lv >= q.Lv then target = q end
                    end
                    if target then
                        _tp(target.NPC)
                        CommF:InvokeServer("StartQuest", target.QName, target.QID)
                    end
                else
                    local enemy = workspace.Enemies:FindFirstChildWhichIsA("Model") or workspace:FindFirstChildWhichIsA("Model")
                    if enemy and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                        _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.Settings.Distance, 0))
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == enemy.Name then
                                v.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame
                                v.HumanoidRootPart.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- [[ OPTIMIZATION ]]
setfpscap(60)
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
end
