_G.Keybind = _G.Keybind or "t"
_G.observationCD = _G.observationCD or 0.5

if not script then
    script = {}
    function script:Destroy() end
end

local code = [==[
return function()
-- SPECTER MELEE NO-CLIP FARMER v3.1 + Observation Hack GUI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------- CONFIGS -------------
local Stealth = { ENABLED=true, HUMANIZATION=0.9, RANDOM_DELAYS=true, MEMORY_CLEANING=true }
local Noclip = { Enabled=true, FlightSpeed=25, FlightHeight=10, MovementSpeed=32 }
local Melee = { AttackCooldown=0.35, LastAttack=0, CombatRange=12 }
local Farming = { Enabled=false, TotalKills=0, CurrentTarget=nil }
local ObservationHack = { Enabled=false }

------------- NO-CLIP -------------
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
    if distance < 5 then return true end
    direction = direction.Unit
    local tweenInfo = TweenInfo.new(distance / Noclip.FlightSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = { Position = position }
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    return tween.Completed:Wait()
end

------------- MELEE ATTACK -------------
local function PerformMeleeAttack()
    if tick() - Melee.LastAttack < Melee.AttackCooldown then return end
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
    Melee.LastAttack = tick()
    if math.random(1,4)==1 then task.wait(math.random(0.05,0.15)) end
end

local function AutoAttackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local targetHRP = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not targetHRP then return false end
    local optimalPos = targetHRP.Position + (hrp.Position - targetHRP.Position).Unit * Melee.CombatRange
    SmoothFlyTo(optimalPos)
    hrp.CFrame = CFrame.lookAt(hrp.Position, targetHRP.Position)
    while target:FindFirstChild("Humanoid") and target.Humanoid.Health>0 do
        if not character or not hrp then break end
        PerformMeleeAttack()
        local currentDistance = (hrp.Position - targetHRP.Position).Magnitude
        if currentDistance>Melee.CombatRange+5 then
            SmoothFlyTo(targetHRP.Position + (hrp.Position - targetHRP.Position).Unit * Melee.CombatRange)
        end
        task.wait(0.1)
    end
    return true
end

------------- QUEST SYSTEM -------------
local QuestSystem = { CurrentQuest=nil, CompletedQuests={} }

local function GetAvailableQuests()
    local available = {}
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            local name = npc.Name:lower()
            if not (name:find("boss") or name:find("raid") or name:find("dragon")) then
                if npc:FindFirstChild("ClickDetector") or npc:FindFirstChild("Dialog") then
                    table.insert(available,npc)
                end
            end
        end
    end
    table.sort(available,function(a,b) return a.Name<b.Name end)
    return available
end

local function AcceptQuest(npc)
    if not npc or not npc:FindFirstChild("ClickDetector") then return false end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    SmoothFlyTo(npc.Head.Position+Vector3.new(0,5,0))
    hrp.CFrame=CFrame.lookAt(hrp.Position,npc.Head.Position)
    task.wait(0.5)
    fireclickdetector(npc.ClickDetector)
    task.wait(1)
    QuestSystem.CurrentQuest = npc
    return true
end

local function CompleteQuest(npc)
    if not npc or not npc:FindFirstChild("ClickDetector") then return false end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    SmoothFlyTo(npc.Head.Position+Vector3.new(0,5,0))
    hrp.CFrame=CFrame.lookAt(hrp.Position,npc.Head.Position)
    task.wait(0.5)
    fireclickdetector(npc.ClickDetector)
    task.wait(1)
    table.insert(QuestSystem.CompletedQuests,npc.Name)
    QuestSystem.CurrentQuest=nil
    return true
end

local function FindQuestTargets()
    local targets = {}
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc.Humanoid.Health>0 then
            local name = npc.Name:lower()
            if not (name:find("boss") or name:find("raid") or name:find("dragon") or name:find("quest")) then
                table.insert(targets,npc)
            end
        end
    end
    return targets
end

------------- STEALTH -------------
local function StealthCleanup()
    if Stealth.MEMORY_CLEANING and math.random(1,100)==1 then collectgarbage("collect") end
    if Stealth.RANDOM_DELAYS and math.random(1,50)==1 then task.wait(math.random(0.1,1.5)*Stealth.HUMANIZATION) end
end

local function HumanLikeMovement()
    if math.random(1,30)==1 and LocalPlayer.Character then
        local hrp=LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos=hrp.Position+Vector3.new(math.random(-2,2),0,math.random(-2,2))
            SmoothFlyTo(pos)
        end
    end
end

------------- GUI PROFESSIONAL -------------
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="SpecterFarmGUI"
ScreenGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn=false

local MainFrame=Instance.new("Frame")
MainFrame.Size=UDim2.new(0,350,0,250)
MainFrame.Position=UDim2.new(0,20,0,20)
MainFrame.BackgroundColor3=Color3.fromRGB(25,25,35)
MainFrame.BorderSizePixel=0
MainFrame.Parent=ScreenGui

local Title=Instance.new("TextLabel")
Title.Text="SPECTER FARMER PRO"
Title.Size=UDim2.new(1,0,0,30)
Title.BackgroundColor3=Color3.fromRGB(20,20,30)
Title.TextColor3=Color3.fromRGB(0,255,200)
Title.Font=Enum.Font.Code
Title.Parent=MainFrame

local StatusLabel=Instance.new("TextLabel")
StatusLabel.Text="Main Farm: IDLE | Observation: IDLE"
StatusLabel.Size=UDim2.new(1,0,0,25)
StatusLabel.Position=UDim2.new(0,0,0,35)
StatusLabel.TextColor3=Color3.fromRGB(255,255,255)
StatusLabel.Font=Enum.Font.RobotoMono
StatusLabel.Parent=MainFrame

local KillsLabel=Instance.new("TextLabel")
KillsLabel.Text="Kills: 0"
KillsLabel.Size=UDim2.new(1,0,0,25)
KillsLabel.Position=UDim2.new(0,0,0,60)
KillsLabel.TextColor3=Color3.fromRGB(255,200,100)
KillsLabel.Font=Enum.Font.RobotoMono
KillsLabel.Parent=MainFrame

local ToggleFarmingBtn=Instance.new("TextButton")
ToggleFarmingBtn.Text="START FARMING"
ToggleFarmingBtn.Size=UDim2.new(0,150,0,30)
ToggleFarmingBtn.Position=UDim2.new(0,10,0,200)
ToggleFarmingBtn.BackgroundColor3=Color3.fromRGB(0,150,100)
ToggleFarmingBtn.TextColor3=Color3.fromRGB(255,255,255)
ToggleFarmingBtn.Font=Enum.Font.RobotoMono
ToggleFarmingBtn.Parent=MainFrame

local ToggleObservationBtn=Instance.new("TextButton")
ToggleObservationBtn.Text="Observation Hacki Farm"
ToggleObservationBtn.Size=UDim2.new(0,180,0,30)
ToggleObservationBtn.Position=UDim2.new(0,170,0,200)
ToggleObservationBtn.BackgroundColor3=Color3.fromRGB(150,100,0)
ToggleObservationBtn.TextColor3=Color3.fromRGB(255,255,255)
ToggleObservationBtn.Font=Enum.Font.RobotoMono
ToggleObservationBtn.Parent=MainFrame

local ExitButton=Instance.new("TextButton")
ExitButton.Text="EXIT"
ExitButton.Size=UDim2.new(0,100,0,30)
ExitButton.Position=UDim2.new(0,120,0,235)
ExitButton.BackgroundColor3=Color3.fromRGB(150,0,0)
ExitButton.TextColor3=Color3.fromRGB(255,255,255)
ExitButton.Font=Enum.Font.RobotoMono
ExitButton.Parent=MainFrame

------------- MAIN FARM LOGIC FUNCTIONS -------------
local function UpdateGUI()
    StatusLabel.Text="Main Farm: "..(Farming.Enabled and "FARMING" or "IDLE").." | Observation: "..(ObservationHack.Enabled and "ON" or "OFF")
    KillsLabel.Text="Kills: "..Farming.TotalKills
    ToggleFarmingBtn.Text=Farming.Enabled and "STOP FARMING" or "START FARMING"
end

ToggleFarmingBtn.MouseButton1Click:Connect(function()
    Farming.Enabled=not Farming.Enabled
    UpdateGUI()
    if Farming.Enabled then EnableNoclip() end
end)

ToggleObservationBtn.MouseButton1Click:Connect(function()
    ObservationHack.Enabled = not ObservationHack.Enabled
    UpdateGUI()
end)

ExitButton.MouseButton1Click:Connect(function()
    Farming.Enabled=false
    ObservationHack.Enabled=false
    ScreenGui:Destroy()
    script:Destroy()
end)

------------- OBSERVATION HACKI FARM -------------
local Mouse=LocalPlayer:GetMouse()
local Toggled=false
Mouse.KeyDown:Connect(function(Key)
    if Key==_G.Keybind then
        if ObservationHack.Enabled then
            Toggled = not Toggled
            while Toggled and ObservationHack.Enabled and task.wait() do
                local args={
                    [1]="Fighting Style",
                    [2]="T",
                    [3]=CFrame.new(0,0,0),
                    [4]=workspace.Map.Islands.Marineford.Model.Marineford:FindFirstChild("Marineford platform"):FindFirstChild("Marineford platform").MeshPart,
                    [5]=5
                }
                ReplicatedStorage.Remotes.requestAbility:FireServer(unpack(args))
                task.wait(_G.observationCD)
            end
        end
    end
end)

------------- MAIN FARM LOOP -------------
local function MainFarmLoop()
    while true do
        if not Farming.Enabled then task.wait(1) HumanLikeMovement() UpdateGUI() continue end
        StealthCleanup()
        UpdateGUI()
        local quests = GetAvailableQuests()
        if #quests>0 and not QuestSystem.CurrentQuest then AcceptQuest(quests[#quests]) end
        local targets=FindQuestTargets()
        if #targets>0 then
            local target=targets[1]
            Farming.CurrentTarget=target
            AutoAttackTarget(target)
            if not target:FindFirstChild("Humanoid") or (target:FindFirstChild("Humanoid") and target.Humanoid.Health<=0) then
                Farming.TotalKills=Farming.TotalKills+1
                UpdateGUI()
                if Farming.TotalKills%5==0 and QuestSystem.CurrentQuest then
                    CompleteQuest(QuestSystem.CurrentQuest)
                    QuestSystem.CurrentQuest=nil
                end
            end
        else HumanLikeMovement() end
        task.wait(0.1)
    end
end

EnableNoclip()
UpdateGUI()
coroutine.wrap(MainFarmLoop)()
end
]==]

local chunk, compileErr=loadstring(code)
if not chunk then warn("Loadstring compile error:",compileErr) return end
local ok,returned=pcall(chunk)
if not ok then warn("Chunk runtime error:",returned) return end
pcall(returned)
