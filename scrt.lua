--// GUI + Script Toggle
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local guiEnabled = false
local minimized = false
local url = "https://discord.com/api/webhooks/1419147952441659443/dIRrwy1GIBYU6S2CsAapfdy37ZILtQXKdARz9Kzcmc7WDvF32McPxmaMzh-_cNWrg_Ru"

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "🌙 Mirage/FullMoon Checker"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton", Frame)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 20

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", Frame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.Text = "🔴 OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 20

-- Status Label
local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(0.9, 0, 0, 20)
Status.Position = UDim2.new(0.05, 0, 0.8, 0)
Status.Text = "Status: Idle"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.SourceSans
Status.TextSize = 16

-- Webhook Function
local function Webhook(IsMirage, IsFullMoon)
    local msg = {
        ["content"] = "@everyone",
        ["embeds"] = {{
            ["color"] = tonumber(0x00FFFF),
            ["title"] = "🌌 Mirage & FullMoon Checker",
            ["fields"] = {
                {["name"] = "Username", ["value"] = "||"..player.Name.."||"},
                {["name"] = "Mirage Island", ["value"] = tostring(IsMirage)},
                {["name"] = "Full Moon", ["value"] = tostring(IsFullMoon)},
                {["name"] = "JobId", ["value"] = game.JobId},
                {["name"] = "Teleport Script", ["value"] = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport","'..game.JobId..'")'}
            },
            ["footer"] = {["text"] = "🔔 Script by Ayman"}
        }}
    }
    syn.request({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(msg)
    })
end

-- Main Loop
task.spawn(function()
    while true do
        if guiEnabled then
            local moonId = Lighting.Sky and Lighting.Sky.MoonTextureId
            local fullMoon = (moonId == "http://www.roblox.com/asset/?id=9709149431")
            local mirage = false
            for _, v in pairs(Workspace.Map:GetChildren()) do
                if v.Name == "MysticIsland" then
                    mirage = true
                end
            end
            Status.Text = "Status: Scanning..."
            if mirage or fullMoon then
                Webhook(mirage, fullMoon)
                Status.Text = "✅ Found: Sending to Discord"
                task.wait(30) -- cooldown to avoid spam
            end
        end
        task.wait(5)
    end
end)

-- Toggle Script ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    if guiEnabled then
        ToggleBtn.Text = "🟢 ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        Status.Text = "Status: Running"
    else
        ToggleBtn.Text = "🔴 OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        Status.Text = "Status: Idle"
    end
end)

-- Minimize GUI
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _, child in pairs(Frame:GetChildren()) do
            if child ~= MinimizeBtn and child ~= Title then
                child.Visible = false
            end
        end
        Frame.Size = UDim2.new(0, 150, 0, 30)
        MinimizeBtn.Text = "+"
    else
        for _, child in pairs(Frame:GetChildren()) do
            child.Visible = true
        end
        Frame.Size = UDim2.new(0, 250, 0, 120)
        MinimizeBtn.Text = "-"
    end
end)
