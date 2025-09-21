-- LOADSTRING-FRIENDLY GUI WRAPPER WITH STATUS NOTIFICATION

local url = "https://discord.com/api/webhooks/1419147952441659443/dIRrwy1GIBYU6S2CsAapfdy37ZILtQXKdARz9Kzcmc7WDvF32McPxmaMzh-_cNWrg_Ru"
local running = false
local loopTask = nil

-- === ORIGINAL FUNCTIONALITY ===
local Moon = game:GetService("Lighting").Sky.MoonTextureId
local map = game:GetService("Workspace").Map:GetChildren()
local Moonstatus = ""
local MirageStatus = ""

local function Webhook(url,IsMirage,IsFullMoon,msgTitle)
    local msg = {
        ["content"] = "@everyone",
        ["embeds"] = {{
            ["color"] = tonumber(0x000000),
            ["title"] = msgTitle or "Webhook ngu cac",
            ["fields"] = {
                {["name"]="Username", ["value"]="||"..game.Players.LocalPlayer.Name.."||", ["inline"]=false},
                {["name"]="Mirage Island:", ["value"]=IsMirage, ["inline"]=false},
                {["name"]="FullMoon:", ["value"]=IsFullMoon, ["inline"]=false},
                {["name"]="JobId:", ["value"]=game.JobId, ["inline"]=false},
                {["name"]="Script:", ["value"]='game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport","'..game.JobId..'")', ["inline"]=false},
            },
            ["footer"]={["icon_url"]="", ["text"]="Blox Fruit Checking From IceLion32#7923"}
        }}
    }
    syn.request({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = game:GetService("HttpService"):JSONEncode(msg)
    })
end

local function Loop()
    while running do
        if Moon == "http://www.roblox.com/asset/?id=9709149431" then
            Moonstatus = "True"
        else
            Moonstatus = "False"
        end
        for i,v in pairs(map) do
            if v.Name == "MysticIsland" then
                MirageStatus = "True"
            else
                MirageStatus = "False"
            end
        end
        if MirageStatus=="True" or Moonstatus == "True" then
            Webhook(url,MirageStatus,Moonstatus)
        end
        task.wait(1)
    end
end

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxCheckGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 120)
Frame.Position = UDim2.new(0.5, -150, 0.5, -60)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "Blox Fruits Moon/Mirage Checker"
Title.TextColor3 = Color3.fromRGB(0,255,200)
Title.BackgroundColor3 = Color3.fromRGB(15,15,20)
Title.Font = Enum.Font.Code
Title.TextScaled = true
Title.Parent = Frame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1,0,0,25)
StatusLabel.Position = UDim2.new(0,0,0,35)
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255,255,255)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextScaled = true
StatusLabel.Parent = Frame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,120,0,30)
ToggleBtn.Position = UDim2.new(0.5,-60,0,65)
ToggleBtn.Text = "ON"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,150,100)
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Font = Enum.Font.RobotoMono
ToggleBtn.TextScaled = true
ToggleBtn.Parent = Frame

-- Show/Hide Button (round, bottom)
local ShowHideBtn = Instance.new("TextButton")
ShowHideBtn.Size = UDim2.new(0,50,0,50)
ShowHideBtn.Position = UDim2.new(0.5,-25,1,0)
ShowHideBtn.AnchorPoint = Vector2.new(0.5,0)
ShowHideBtn.Text = "▲"
ShowHideBtn.BackgroundColor3 = Color3.fromRGB(50,50,55)
ShowHideBtn.TextColor3 = Color3.fromRGB(0,255,200)
ShowHideBtn.TextScaled = true
ShowHideBtn.BorderSizePixel = 0
ShowHideBtn.Parent = Frame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,25,0,25)
CloseBtn.Position = UDim2.new(1,-30,0,5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,0,0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25,25,30)
CloseBtn.Font = Enum.Font.RobotoMono
CloseBtn.TextScaled = true
CloseBtn.Parent = Frame

-- === GUI LOGIC ===
ToggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        StatusLabel.Text = "Status: ON"
        Webhook(url,"N/A","N/A","Script Turned ON") -- Notify Discord
        loopTask = coroutine.wrap(Loop)()
        loopTask()
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    else
        StatusLabel.Text = "Status: OFF"
        Webhook(url,"N/A","N/A","Script Turned OFF") -- Notify Discord
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,150,100)
    end
end)

ShowHideBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    running = false
    Webhook(url,"N/A","N/A","Script Closed") -- Notify Discord
    ScreenGui:Destroy()
end)
