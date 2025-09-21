--!strict
-- BLOX FRUITS MOON & MIRAGE CHECKER WITH GUI & WEBHOOK
-- [LOADSTRING READY]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Webhook URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1419147952441659443/dIRrwy1GIBYU6S2CsAapfdy37ZILtQXKdARz9Kzcmc7WDvF32McPxmaMzh-_cNWrg_Ru"

-- Script State
local ScriptEnabled = false
local MoonStatus = "False"
local MirageStatus = "False"

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoonMirageGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 120)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Moon & Mirage Checker"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.Code
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.RobotoMono
StatusLabel.TextScaled = true
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 35)
ToggleButton.Position = UDim2.new(0.5, -60, 1, -40)
ToggleButton.Text = "TURN ON"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.RobotoMono
ToggleButton.TextScaled = true
ToggleButton.Parent = MainFrame

-- Show/Hide Button (round, bottom center)
local ShowHideButton = Instance.new("TextButton")
ShowHideButton.Size = UDim2.new(0, 60, 0, 60)
ShowHideButton.Position = UDim2.new(0.5, -30, 1, -70)
ShowHideButton.Text = "▲"
ShowHideButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ShowHideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowHideButton.Font = Enum.Font.RobotoMono
ShowHideButton.TextScaled = true
ShowHideButton.AutoButtonColor = true
ShowHideButton.Parent = ScreenGui
ShowHideButton.BackgroundTransparency = 0
ShowHideButton.BorderSizePixel = 0
ShowHideButton.ClipsDescendants = true
ShowHideButton.TextStrokeTransparency = 0.7
ShowHideButton.TextWrapped = true
ShowHideButton.AnchorPoint = Vector2.new(0.5, 0.5)
ShowHideButton.Text = "▲"
ShowHideButton.TextScaled = true
ShowHideButton.TextWrapped = true
ShowHideButton.TextYAlignment = Enum.TextYAlignment.Center
ShowHideButton.TextXAlignment = Enum.TextXAlignment.Center
ShowHideButton.BackgroundTransparency = 0
ShowHideButton.ZIndex = 2
ShowHideButton.Roundify = true
ShowHideButton.Parent = ScreenGui
ShowHideButton.BorderSizePixel = 0
ShowHideButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ShowHideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowHideButton.AnchorPoint = Vector2.new(0.5, 0)
ShowHideButton.Position = UDim2.new(0.5, 0, 1, -35)
ShowHideButton.Text = "▲"
ShowHideButton.TextScaled = true
ShowHideButton.TextWrapped = true
ShowHideButton.TextYAlignment = Enum.TextYAlignment.Center
ShowHideButton.TextXAlignment = Enum.TextXAlignment.Center
ShowHideButton.BorderSizePixel = 0
ShowHideButton.AutoButtonColor = true
ShowHideButton.ZIndex = 2
ShowHideButton.BackgroundTransparency = 0
ShowHideButton.ClipsDescendants = true
ShowHideButton.Size = UDim2.new(0,60,0,60)
ShowHideButton.Position = UDim2.new(0.5,-30,1,-35)
ShowHideButton.Text = "▲"
ShowHideButton.BackgroundColor3 = Color3.fromRGB(0,150,200)
ShowHideButton.Font = Enum.Font.SourceSansBold

-- Function to send webhook
local function SendWebhook(message)
    if WEBHOOK_URL == "" then return end
    local data = {
        ["content"] = message
    }
    syn.request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

-- Toggle script
ToggleButton.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ToggleButton.Text = "TURN OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
        StatusLabel.Text = "Status: RUNNING"
        SendWebhook("Moon & Mirage script is now **RUNNING** for "..LocalPlayer.Name)
    else
        ToggleButton.Text = "TURN ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0,150,100)
        StatusLabel.Text = "Status: OFF"
        SendWebhook("Moon & Mirage script is now **OFF** for "..LocalPlayer.Name)
    end
end)

-- Show/Hide GUI
ShowHideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ShowHideButton.Text = MainFrame.Visible and "▲" or "▼"
end)

-- Main loop
coroutine.wrap(function()
    while true do
        if ScriptEnabled then
            -- Check Moon
            if Lighting:FindFirstChild("Sky") then
                if Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=9709149431" then
                    MoonStatus = "True"
                else
                    MoonStatus = "False"
                end
            end

            -- Check Mirage
            MirageStatus = "False"
            for _,v in pairs(Workspace.Map:GetChildren()) do
                if v.Name == "MysticIsland" then
                    MirageStatus = "True"
                end
            end

            if MoonStatus=="True" or MirageStatus=="True" then
                SendWebhook("Moon: "..MoonStatus.." | Mirage: "..MirageStatus.." | Player: "..LocalPlayer.Name)
            end
        end
        task.wait(5)
    end
end)()
