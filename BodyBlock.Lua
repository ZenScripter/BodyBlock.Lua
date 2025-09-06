local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Remote Event
local SetBodyBlockSettings = ReplicatedStorage:FindFirstChild("SetBodyBlockSettings")
if not SetBodyBlockSettings then
    SetBodyBlockSettings = Instance.new("RemoteEvent")
    SetBodyBlockSettings.Name = "SetBodyBlockSettings"
    SetBodyBlockSettings.Parent = ReplicatedStorage
end

local BodyBlockActivate = ReplicatedStorage:WaitForChild("BodyBlockActivate")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/Rayfield.lua"))()

-- state
local autoEnabled = false
local currentRange = 4
local AIM_DURATION = 0.24
local AIM_STEP = 0.12

local function sendSettings()
    local payload = {
        autoEnabled = autoEnabled and true or false,
        range = tonumber(currentRange) or 4
    }
    if payload.range < 1 then payload.range = 1 end
    if payload.range > 10 then payload.range = 10 end
    pcall(function() SetBodyBlockSettings:FireServer(payload) end)
end

-- Smooth face function
local function smoothFaceTarget(rootPart, targetPos, duration)
    if not rootPart or not targetPos then return end
    local elapsed = 0
    while elapsed < duration and rootPart.Parent do
        local fromC = rootPart.CFrame
        local toC = CFrame.new(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
        local alpha = math.clamp(elapsed / duration, 0, 1)
        rootPart.CFrame = fromC:Lerp(toC, alpha)
        elapsed = elapsed + AIM_STEP
        task.wait(AIM_STEP)
    end
    if rootPart and rootPart.Parent then
        rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
    end
end

-- BodyBlock GUI
local Window = Rayfield:CreateWindow({
    Name = "Body Block (007n7)",
    LoadingTitle = "Body Block Rayfield GUI",
    LoadingSubtitle = "v1.0",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BodyBlockConfig",
        FileName = "Settings"
    }
})

local Tab = Window:CreateTab("Auto BodyBlock", 4483362458)

Tab:CreateToggle({
    Name = "Enable Auto BodyBlock",
    CurrentValue = autoEnabled,
    Flag = "AutoBodyBlockToggle",
    Callback = function(value)
        autoEnabled = value
        sendSettings()
    end
})

Tab:CreateSlider({
    Name = "Custom Range (studs)",
    Range = {1,10},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = currentRange,
    Flag = "RangeSlider",
    Callback = function(value)
        currentRange = value
        sendSettings()
    end
})

Tab:CreateButton({
    Name = "Apply Settings",
    Callback = function()
        sendSettings()
    end
})

-- BodyBlock event client-side
BodyBlockActivate.OnClientEvent:Connect(function(attackerUserId)
    local attacker = Players:GetPlayerByUserId(attackerUserId)
    if not attacker or not attacker.Character then return end
    local attRoot = attacker.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not attRoot or not myRoot then return end

    -- smooth face
    task.spawn(function()
        smoothFaceTarget(myRoot, attRoot.Position, AIM_DURATION)
    end)

    -- play animation
    local humanoid = myChar:FindFirstChildOfClass("Humanoid")
    local anim = ReplicatedStorage:FindFirstChild("BodyBlockAnim")
    if anim and humanoid then
        local ok, track = pcall(function() return humanoid:LoadAnimation(anim) end)
        if ok and track then
            pcall(function() track:Play() end)
            delay(1.6, function() pcall(function() track:Stop() end) end)
        end
    end
end)

-- gửi lần đầu khi load
sendSettings()
