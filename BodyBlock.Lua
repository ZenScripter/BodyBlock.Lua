-- BodyBlock Rayfield Full Loadstring
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- đảm bảo RemoteEvent tồn tại
local SetBodyBlockSettings = ReplicatedStorage:FindFirstChild("SetBodyBlockSettings")
if not SetBodyBlockSettings then
    SetBodyBlockSettings = Instance.new("RemoteEvent")
    SetBodyBlockSettings.Name = "SetBodyBlockSettings"
    SetBodyBlockSettings.Parent = ReplicatedStorage
end

local BodyBlockActivate = ReplicatedStorage:FindFirstChild("BodyBlockActivate")
if not BodyBlockActivate then
    BodyBlockActivate = Instance.new("RemoteEvent")
    BodyBlockActivate.Name = "BodyBlockActivate"
    BodyBlockActivate.Parent = ReplicatedStorage
end

-- Load Rayfield
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/Rayfield.lua"))()
end)
if not success or not Rayfield then
    warn("❌ Rayfield failed to load")
    return
end

-- State
local autoEnabled = false
local currentRange = 4
local AIM_DURATION = 0.24
local AIM_STEP = 0.12

local function sendSettings()
    local payload = {autoEnabled = autoEnabled, range = tonumber(currentRange) or 4}
    payload.range = math.clamp(payload.range,1,10)
    pcall(function() SetBodyBlockSettings:FireServer(payload) end)
end

-- Smooth face function
local function smoothFaceTarget(rootPart, targetPos, duration)
    if not rootPart or not targetPos then return end
    local elapsed = 0
    while elapsed < duration and rootPart.Parent do
        local fromC = rootPart.CFrame
        local toC = CFrame.new(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
        rootPart.CFrame = fromC:Lerp(toC, elapsed/duration)
        elapsed = elapsed + AIM_STEP
        task.wait(AIM_STEP)
    end
    if rootPart and rootPart.Parent then
        rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
    end
end

-- Create GUI
task.spawn(function()
    local Window = Rayfield:CreateWindow({
        Name = "Body Block (007n7)",
        LoadingTitle = "Body Block Rayfield GUI",
        LoadingSubtitle = "v1.0",
        ConfigurationSaving = {Enabled=true, FolderName="BodyBlockConfig", FileName="Settings"},
        Discord={Enabled=false}
    })

    local Tab = Window:CreateTab("Auto BodyBlock",4483362458)

    Tab:CreateToggle({
        Name="Enable Auto BodyBlock",
        CurrentValue=autoEnabled,
        Flag="AutoBodyBlockToggle",
        Callback=function(value)
            autoEnabled = value
            sendSettings()
        end
    })

    Tab:CreateSlider({
        Name="Custom Range (studs)",
        Range={1,10},
        Increment=1,
        Suffix="studs",
        CurrentValue=currentRange,
        Flag="RangeSlider",
        Callback=function(value)
            currentRange = value
            sendSettings()
        end
    })

    Tab:CreateButton({
        Name="Apply Settings",
        Callback=function()
            sendSettings()
        end
    })
end)

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
            delay(1.6,function() pcall(function() track:Stop() end) end)
        end
    end
end)

-- Gửi setting lần đầu khi load
sendSettings()
