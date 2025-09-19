return function()
-- SPECTER MELEE NO-CLIP FARMER v3.1
-- [AUTHORIZED FOR EDUCATIONAL PURPOSES ONLY]
-- [STEALTH MODE: MAXIMUM]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

------------- STEALTH CONFIGURATION -------------
local Stealth = {
    ENABLED = true,
    ANTI_DETECTION_LEVEL = 9, -- 1-10
    HUMANIZATION = 0.9, -- 0.0-1.0
    RANDOM_DELAYS = true,
    MEMORY_CLEANING = true
}

------------- NO-CLIP FLIGHT SYSTEM -------------
local Noclip = {}
Noclip.Enabled = true
Noclip.FlightSpeed = 25
Noclip.FlightHeight = 10
Noclip.MovementSpeed = 32

local function EnableNoclip()
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function SmoothFlyTo(position)
    if not LocalPlayer.Character then return false end
    
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local direction = (position - humanoidRootPart.Position)
    local distance = direction.Magnitude
    
    if distance < 5 then
        return true
    end
    
    direction = direction.Unit
    
    -- Smooth movement with acceleration/deceleration
    local tweenInfo = TweenInfo.new(
        distance / Noclip.FlightSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    
    local goal = {}
    goal.Position = position
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    
    local success = tween.Completed:Wait()
    return success
end

------------- MELEE COMBAT SYSTEM -------------
local Melee = {}
Melee.AttackCooldown = 0.35
Melee.LastAttack = 0
Melee.CombatRange = 12

local function PerformMeleeAttack()
    if tick() - Melee.LastAttack < Melee.AttackCooldown then
        return
    end
    
    -- Simulate M1 mouse click
    VirtualInputManager:SendMouseButtonEvent(
        0, 0, 0, -- Position doesn't matter for M1
        true, -- Down
        game, -- Target
        1 -- ClickCount
    )
    
    task.wait(0.05)
    
    VirtualInputManager:SendMouseButtonEvent(
        0, 0, 0,
        false, -- Up
        game,
        1
    )
    
    Melee.LastAttack = tick()
    
    -- Random micro-delay between attacks
    if math.random(1, 4) == 1 then
        task.wait(math.random(0.05, 0.15))
    end
end

local function AutoAttackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local targetHRP = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not targetHRP then return false end
    
    local distance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
    
    -- Position for optimal melee range
    local optimalPosition = targetHRP.Position + (humanoidRootPart.Position - targetHRP.Position).Unit * Melee.CombatRange
    
    -- Fly to optimal attack position
    SmoothFlyTo(optimalPosition)
    
    -- Face the target
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, targetHRP.Position)
    
    -- Continuous M1 attacks
    while target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 do
        if not character or not humanoidRootPart then break end
        
        PerformMeleeAttack()
        
        -- Check if target moved
        local currentDistance = (humanoidRootPart.Position - targetHRP.Position).Magnitude
        if currentDistance > Melee.CombatRange + 5 then
            SmoothFlyTo(targetHRP.Position + (humanoidRootPart.Position - targetHRP.Position).Unit * Melee.CombatRange)
        end
        
        task.wait(0.1)
    end
    
    return true
end

------------- QUEST INTELLIGENCE SYSTEM -------------
local QuestSystem = {}
QuestSystem.CurrentQuest = nil
QuestSystem.QuestNPCs = {}
QuestSystem.CompletedQuests = {}

local function GetAvailableQuests()
    local availableQuests = {}
    local character = LocalPlayer.Character
    
    if not character then return availableQuests end
    
    -- Find all NPCs that might have quests (excluding bosses)
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            -- Skip bosses (usually have "Boss" in name or specific names)
            local npcName = npc.Name:lower()
            if not (npcName:find("boss") or npcName:find("raid") or npcName:find("dough") or npcName:find("dragon")) then
                -- Check if NPC has quest dialogue
                if npc:FindFirstChild("ClickDetector") or npc:FindFirstChild("Dialog") then
                    table.insert(availableQuests, npc)
                end
            end
        end
    end
    
    -- Sort by likely quest level (simple heuristic based on name/number)
    table.sort(availableQuests, function(a, b)
        return a.Name < b.Name
    end)
    
    return availableQuests
end

local function AcceptQuest(npc)
    if not npc or not npc:FindFirstChild("ClickDetector") then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Fly to NPC
    SmoothFlyTo(npc.Head.Position + Vector3.new(0, 5, 0))
    
    -- Face NPC
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, npc.Head.Position)
    
    task.wait(0.5)
    
    -- Click on NPC to accept quest
    fireclickdetector(npc.ClickDetector)
    
    task.wait(1)
    
    QuestSystem.CurrentQuest = npc
    return true
end

local function CompleteQuest(npc)
    if not npc or not npc:FindFirstChild("ClickDetector") then
        return false
    end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Fly to NPC
    SmoothFlyTo(npc.Head.Position + Vector3.new(0, 5, 0))
    
    -- Face NPC
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, npc.Head.Position)
    
    task.wait(0.5)
    
    -- Click on NPC to complete quest
    fireclickdetector(npc.ClickDetector)
    
    task.wait(1)
    
    table.insert(QuestSystem.CompletedQuests, npc.Name)
    QuestSystem.CurrentQuest = nil
    
    return true
end

local function FindQuestTargets()
    local targets = {}
    local character = LocalPlayer.Character
    
    if not character then return targets end
    
    -- Find enemy NPCs (excluding bosses)
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
            local npcName = npc.Name:lower()
            -- Skip bosses and friendly NPCs
            if not (npcName:find("boss") or npcName:find("raid") or npcName:find("dough") or npcName:find("dragon") or npcName:find("quest")) then
                table.insert(targets, npc)
            end
        end
    end
    
    return targets
end

------------- STEALTH ANTI-DETECTION -------------
local function StealthCleanup()
    if not Stealth.MEMORY_CLEANING then return end
    
    -- Random garbage collection
    if math.random(1, 100) == 1 then
        collectgarbage("collect")
    end
    
    -- Random micro-pauses
    if Stealth.RANDOM_DELAYS and math.random(1, 50) == 1 then
        local delay = math.random(0.1, 1.5) * Stealth.HUMANIZATION
        task.wait(delay)
    end
end

local function HumanLikeMovement()
    -- Add slight random movements while idle
    if math.random(1, 30) == 1 and LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local slightMove = humanoidRootPart.Position + Vector3.new(
                math.random(-2, 2),
                0,
                math.random(-2, 2)
            )
            SmoothFlyTo(slightMove)
        end
    end
end

------------- GUI INTERFACE -------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpecterFarmGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "SPECTER MELEE FARMER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.Code
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Ready"
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.RobotoMono
StatusLabel.Parent = MainFrame

local QuestLabel = Instance.new("TextLabel")
QuestLabel.Text = "Current Quest: None"
QuestLabel.Size = UDim2.new(1, 0, 0, 25)
QuestLabel.Position = UDim2.new(0, 0, 0, 60)
QuestLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
QuestLabel.Font = Enum.Font.RobotoMono
QuestLabel.Parent = MainFrame

local KillsLabel = Instance.new("TextLabel")
KillsLabel.Text = "Kills: 0"
QuestLabel.Size = UDim2.new(1, 0, 0, 25)
QuestLabel.Position = UDim2.new(0, 0, 0, 85)
QuestLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
QuestLabel.Font = Enum.Font.RobotoMono
QuestLabel.Parent = MainFrame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "START FARMING"
ToggleButton.Size = UDim2.new(0, 120, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 160)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.RobotoMono
ToggleButton.Parent = MainFrame

local ExitButton = Instance.new("TextButton")
ExitButton.Text = "EXIT"
ExitButton.Size = UDim2.new(0, 120, 0, 30)
ExitButton.Position = UDim2.new(0, 140, 0, 160)
ExitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ExitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitButton.Font = Enum.Font.RobotoMono
ExitButton.Parent = MainFrame

------------- MAIN FARMING LOGIC -------------
local Farming = {
    Enabled = false,
    TotalKills = 0,
    CurrentTarget = nil
}

local function UpdateGUI()
    StatusLabel.Text = Farming.Enabled and "Status: FARMING" or "Status: IDLE"
    QuestLabel.Text = "Current Quest: " .. (QuestSystem.CurrentQuest and QuestSystem.CurrentQuest.Name or "None")
    KillsLabel.Text = "Kills: " .. Farming.TotalKills
    ToggleButton.Text = Farming.Enabled and "STOP FARMING" or "START FARMING"
    ToggleButton.BackgroundColor3 = Farming.Enabled and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 100)
end

ToggleButton.MouseButton1Click:Connect(function()
    Farming.Enabled = not Farming.Enabled
    UpdateGUI()
    
    if Farming.Enabled then
        EnableNoclip()
    end
end)

ExitButton.MouseButton1Click:Connect(function()
    Farming.Enabled = false
    ScreenGui:Destroy()
    script:Destroy()
end)

local function MainFarmLoop()
    while true do
        if not Farming.Enabled then
            task.wait(1)
            HumanLikeMovement()
            continue
        end
        
        StealthCleanup()
        UpdateGUI()
        
        -- Get available quests
        local availableQuests = GetAvailableQuests()
        
        if #availableQuests == 0 then
            StatusLabel.Text = "Status: No quests found"
            task.wait(3)
            continue
        end
        
        -- Accept highest available quest
        if not QuestSystem.CurrentQuest then
            local questNPC = availableQuests[#availableQuests] -- Get last/highest quest
            if AcceptQuest(questNPC) then
                StatusLabel.Text = "Status: Accepted " .. questNPC.Name
                task.wait(2)
            end
        end
        
        -- Find and attack targets
        local targets = FindQuestTargets()
        
        if #targets > 0 then
            local target = targets[1] -- Attack first available target
            
            StatusLabel.Text = "Status: Attacking " .. target.Name
            Farming.CurrentTarget = target
            
            local success = AutoAttackTarget(target)
            
            if success and not target:FindFirstChild("Humanoid") or (target:FindFirstChild("Humanoid") and target.Humanoid.Health <= 0) then
                Farming.TotalKills = Farming.TotalKills + 1
                UpdateGUI()
                
                -- Check if quest might be complete (simple heuristic)
                if Farming.TotalKills % 5 == 0 and QuestSystem.CurrentQuest then
                    if CompleteQuest(QuestSystem.CurrentQuest) then
                        StatusLabel.Text = "Status: Completed " .. QuestSystem.CurrentQuest.Name
                        task.wait(2)
                        QuestSystem.CurrentQuest = nil
                    end
                end
            end
        else
            StatusLabel.Text = "Status: Searching for targets..."
            HumanLikeMovement()
            task.wait(2)
        end
        
        task.wait(0.1)
    end
end

-- Initialize
EnableNoclip()
UpdateGUI()

-- Start main loop
coroutine.wrap(MainFarmLoop)()
end
