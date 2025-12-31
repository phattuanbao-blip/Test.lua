repeat task.wait() until game:IsLoaded()

-- [ 1. HỆ THỐNG BIẾN & THIẾT LẬP ]
do
    ply = game.Players
    plr = ply.LocalPlayer
    replicated = game:GetService("ReplicatedStorage")
    TW = game:GetService("TweenService")
    Enemies = workspace.Enemies
    vim1 = game:GetService("VirtualInputManager")
    World1 = game.PlaceId == 2753915549
    World2 = game.PlaceId == 4442272183
    World3 = game.PlaceId == 7449423635
    Sec = 0.1
    _G.AutoFarm = true
    _G.SelectWeapon = "Melee" -- Có thể đổi thành "Sword" hoặc "Blox Fruit"
end

-- [ 2. DATA TỌA ĐỘ TRÍCH XUẤT TỪ FILE ]
local PosMsList = {
    ["Pirate Millionaire"] = CFrame.new(-712.827, 98.577, 5711.954),
    ["Pistol Billionaire"] = CFrame.new(-723.433, 147.429, 5931.993),
    ["Dragon Crew Warrior"] = CFrame.new(7021.504, 55.762, -730.129),
    ["Dragon Crew Archer"] = CFrame.new(6625, 378, 244),
    ["Female Islander"] = CFrame.new(4692.793, 797.976, 858.848),
    ["Venomous Assailant"] = CFrame.new(4902, 670, 39),
    ["Marine Commodore"] = CFrame.new(2401, 123, -7589),
    ["Marine Rear Admiral"] = CFrame.new(3588, 229, -7085),
    ["Fishman Raider"] = CFrame.new(-10941, 332, -8760),
    ["Fishman Captain"] = CFrame.new(-11035, 332, -9087),
    ["Forest Pirate"] = CFrame.new(-13446, 413, -7760),
    ["Mythological Pirate"] = CFrame.new(-13510, 584, -6987),
    ["Jungle Pirate"] = CFrame.new(-11778, 426, -10592),
    ["Musketeer Pirate"] = CFrame.new(-13282, 496, -9565),
    ["Reborn Skeleton"] = CFrame.new(-8764, 142, 5963),
    ["Living Zombie"] = CFrame.new(-10227, 421, 6161),
    ["Demonic Soul"] = CFrame.new(-9579, 6, 6194),
    ["Posessed Mummy"] = CFrame.new(-9579, 6, 6194),
    ["Peanut Scout"] = CFrame.new(-1993, 187, -10103),
    ["Peanut President"] = CFrame.new(-2215, 159, -10474),
    ["Ice Cream Chef"] = CFrame.new(-877, 118, -11032),
    ["Ice Cream Commander"] = CFrame.new(-877, 118, -11032),
    ["Cookie Crafter"] = CFrame.new(-2021, 38, -12028),
    ["Cake Guard"] = CFrame.new(-2024, 38, -12026),
    ["Baking Staff"] = CFrame.new(-1932, 38, -12848),
    ["Head Baker"] = CFrame.new(-1932, 38, -12848),
    ["Cocoa Warrior"] = CFrame.new(95, 73, -12309),
    ["Chocolate Bar Battler"] = CFrame.new(647, 42, -12401),
    ["Sweet Thief"] = CFrame.new(116, 36, -12478),
    ["Candy Rebel"] = CFrame.new(47, 61, -12889),
    ["Ghost"] = CFrame.new(5251, 5, 1111)
}

-- [ 3. HÀM DI CHUYỂN & CHIẾN ĐẤU ]
local block = Instance.new("Part", workspace)
block.Size = Vector3.new(1, 1, 1)
block.Anchored = true
block.CanCollide = false
block.Transparency = 1

function _tp(target)
    pcall(function()
        local distance = (target.Position - block.Position).Magnitude
        local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
        TW:Create(block, tweenInfo, {CFrame = target}):Play()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = block.CFrame
        end
    end)
end

function BringEnemy(PosMon)
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.PrimaryPart.Position - PosMon).Magnitude <= 300 then
                v.PrimaryPart.CFrame = CFrame.new(PosMon)
                v.PrimaryPart.CanCollide = false
                v.Humanoid.WalkSpeed = 0
            end
        end
    end
end

-- [ 4. HỆ THỐNG NHẬN NHIỆM VỤ ]
function GetQuest()
    local a = plr.Data.Level.Value
    if World3 then
        if a >= 1500 and a <= 1574 then return "MarineQuest2", 1, "Pirate Millionaire"
        elseif a >= 1575 and a <= 1624 then return "MarineQuest2", 2, "Pistol Billionaire"
        elseif a >= 1800 and a <= 1849 then return "DeepForestQuest", 1, "Forest Pirate"
        -- Tự động thêm các mốc level khác từ file nếu cần
        else return "MarineQuest2", 1, "Pirate Millionaire" end
    end
end

-- [ 5. VÒNG LẶP CHÍNH ]
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                if not plr.PlayerGui.Main.Quest.Visible then
                    local QName, QID, MobName = GetQuest()
                    local PosQ = PosMsList[MobName]
                    if PosQ then
                        _tp(PosQ)
                        replicated.Remotes.CommF_:InvokeServer("StartQuest", QName, QID)
                    end
                else
                    local QName, QID, MobName = GetQuest()
                    local v = workspace.Enemies:FindFirstChild(MobName) or workspace:FindFirstChild(MobName)
                    
                    if v and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        local PosMon = v.HumanoidRootPart.Position
                        BringEnemy(PosMon)
                        _tp(v.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        
                        -- Tấn công
                        local tool = plr.Backpack:FindFirstChild(_G.SelectWeapon) or plr.Character:FindFirstChild(_G.SelectWeapon)
                        if tool then 
                            plr.Character.Humanoid:EquipTool(tool)
                            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                        end
                    else
                        if PosMsList[MobName] then _tp(PosMsList[MobName]) end
                    end
                end
            end)
        end
    end
end)

-- [ 6. TỐI ƯU HÓA & TIỆN ÍCH ]
spawn(function()
    while task.wait(5) do
        -- Tự tăng Stats: Melee và Defense
        replicated.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 3)
        replicated.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 3)
        
        -- Cất trái ác quỷ
        for _, item in pairs(plr.Backpack:GetChildren()) do
            if item.Name:find("Fruit") then
                replicated.Remotes.CommF_:InvokeServer("StoreFruit", item.Name, item)
            end
        end
    end
end)
