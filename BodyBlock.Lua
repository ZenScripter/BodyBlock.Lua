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
