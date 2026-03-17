local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char.HumanoidRootPart
local gemsFolder = workspace.RobbingFolder
local currentTycoon = nil
local gemsEnabled = false
local buyEnabled = false
local cashEnabled = false
local rebirthEnabled = false

local g = getinfo or debug.getinfo
local d = false
local h = {}

local x, y

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local a = rawget(v, "Detected")
        local b = rawget(v, "Kill")
    
        if typeof(a) == "function" and not x then
            x = a
            
            local o; o = hookfunction(x, function(c, f, n)
                if c ~= "_" then
                    if d then
                        warn("idk")
                    end
                end
                
                return true
            end)

            table.insert(h, x)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
            y = b
            local o; o = hookfunction(y, function(f)
                if d then
                    warn("idk")
                end
            end)

            table.insert(h, y)
        end
    end
end

local o; o = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local a, f = ...

    if x and a == x then
        if d then
            warn("idk")
        end

        return coroutine.yield(coroutine.running())
    end
    
    return o(...)
end))

setthreadidentity(7)

local RF = game:GetService("ReplicatedStorage")
    :WaitForChild("ACS_Engine")
    :WaitForChild("Events")
    :WaitForChild("Damage")

local mt = getrawmetatable(game)
local oldIndex = mt.__index
local oldNamecall = mt.__namecall

lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

-- ANTI AFK
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    game.Players.LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

local flying = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 50

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

local function startFly()
    flying = true
    local cam = workspace.CurrentCamera
    local hum = char:FindFirstChildOfClass("Humanoid")
    hum.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.zero

    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.P = 10000

    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
        bodyVelocity.Velocity = dir * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end
task.spawn(function()
    local ogCFrame = lp.Character:GetPivot()
    local middleCFrame = CFrame.new(-816.998291, 348.65094, 334.041504, 0.118985146, -7.769992e-9, -0.99289602, -2.8016989e-14, 1, -7.825587e-9, 0.99289602, 9.311565e-10, 0.118985146)

    lp.Character:PivotTo(middleCFrame)
    notify("Us Scripts", "Loading all bases...")
    task.wait(3)
    lp.Character:PivotTo(ogCFrame)
end)

while not currentTycoon do
    for _, tycoon in pairs(workspace["The Nuke Tycoon Entirely Model"].Tycoons:GetChildren()) do
        if tycoon.Owner.Value == lp then
            currentTycoon = tycoon
        end
    end
    if not currentTycoon then
        notify("Choose a tycoon", "Please pick a tycoon")
    end
    task.wait(1)
end

local giver = currentTycoon.Essentials.Giver

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "Nuke Tycoon | Us Scripts",
Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
LoadingTitle = "Nuke Tycoon | Us Scripts",
LoadingSubtitle = "made by us.",
ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

DisableRayfieldPrompts = false,
DisableBuildWarnings = false -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.
})

local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image

local Section = Tab:CreateSection("Tycoon")
Section:Set("Tycoon")

-- AUTO BUY BUTTONS
Tab:CreateToggle({
    Name = "Auto Buy Buttons",
    CurrentValue = false,
    Flag = "ToggleBuy",
    Callback = function(Value)
        buyEnabled = Value

        task.spawn(function()
            while buyEnabled do
                if not currentTycoon or not currentTycoon:FindFirstChild("Buttons") then
                    task.wait(1)
                    continue
                end

                local buttons = {}

                for _, button in pairs(currentTycoon.Buttons:GetChildren()) do
                    if button:FindFirstChild("ACS_NoDamage")
                    and button:FindFirstChild("Price")
                    and button:FindFirstChild("Rebirths")
                    and button.ACS_NoDamage:FindFirstChild("UI")
                    and button.ACS_NoDamage.UI.Enabled == true
                    and lp.leaderstats.Rebirths.Value >= button.Rebirths.Value then
                        table.insert(buttons, button)
                    end
                end

                if #buttons == 0 then
                    task.wait(1)
                    continue
                end

                table.sort(buttons, function(a, b)
                    local aU = a.Name:lower():find("uranium")
                    local bU = b.Name:lower():find("uranium")
                    if aU ~= bU then
                        return aU ~= nil
                    end
                    return a.Price.Value < b.Price.Value
                end)

                for _, button in ipairs(buttons) do
                    if not buyEnabled then break end
                    firetouchinterest(button.ACS_NoDamage, hrp, 0)
                    task.wait()
                    firetouchinterest(button.ACS_NoDamage, hrp, 1)
                end

                task.wait(0.5)
            end
        end)
    end,
})

-- AUTO REBIRTH
Tab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "ToggleRebirth",
    Callback = function(Value)
        rebirthEnabled = Value

        task.spawn(function()
            while rebirthEnabled do
                if lp:FindFirstChild("CanRebirth") and lp.CanRebirth.Value == true then
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("RebirthEvent (Don't Move)")
                        :FireServer()

                    task.wait(3)

                    -- refresh tycoon after rebirth
                    repeat task.wait(1) until currentTycoon and currentTycoon:FindFirstChild("Buttons")
                end
                task.wait(1)
            end
        end)
    end,
})

-- AUTO CASH
Tab:CreateToggle({
    Name = "Auto Claim Cash",
    CurrentValue = false,
    Flag = "ToggleCash",
    Callback = function(Value)
        cashEnabled = Value

        task.spawn(function()
            while cashEnabled do
                local startPos = char:GetPivot().Position
                local goalPos = giver.Position

                local distance = (startPos - goalPos).Magnitude
                local steps = math.clamp(distance / 2, 10, 100)

                for i = 1, steps do
                    if not cashEnabled then break end
                    local pos = startPos:Lerp(goalPos, i / steps)
                    char:PivotTo(CFrame.new(pos))
                    task.wait()
                end

                if not cashEnabled then break end

                firetouchinterest(giver, hrp, 0)
                firetouchinterest(giver, hrp, 1)

                task.wait(0.5)
            end
        end)
        cashEnabled = false

        repeat task.wait() until not cashEnabled
        task.wait(3) -- small buffer
        
        -- safe to teleport
    end,
})


-- UI
local Divider = Tab:CreateDivider()
Divider:Set(true)

local Section = Tab:CreateSection("Gems")
Section:Set("Gems")

-- GEMS TOGGLE
local Toggle = Tab:CreateToggle({
    Name = "Auto Rob Gems",
    CurrentValue = false,
    Flag = "Toggle3",
    Callback = function(Value)
        gemsEnabled = Value

        task.spawn(function()
            while gemsEnabled do
                -- Pause gems if cash is running
                if cashEnabled then
                    task.wait(1)
                    continue
                end

                local prompt = nil

                for _, base in pairs(gemsFolder:GetChildren()) do
                    if base:IsA("BasePart")
                    and base:FindFirstChild("Chosen")
                    and base.Chosen.Value == true
                    and base.Name ~= lp.Team.Name then
                        
                        if base:FindFirstChild("ProximityPrompt") then
                            prompt = base.ProximityPrompt
                            break
                        end
                    end
                end

                if not prompt then
                    task.wait(1)
                    continue
                end

                local originalCFrame = lp.Character:GetPivot()

                lp.Character:PivotTo(prompt.Parent.CFrame)
                task.wait(2)

                fireproximityprompt(prompt)

                while prompt.Parent:FindFirstChild("Chosen") and prompt.Parent.Chosen.Value == true do
                    if not gemsEnabled then break end
                    task.wait()
                end
                task.wait(1) -- anti cheat

                lp.Character:PivotTo(originalCFrame)
                task.wait(1)
            end
        end)
    end,
})


local Label = Tab:CreateLabel("Turn off cash collector to use auto gems", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

local Tab1 = Window:CreateTab("Movement", 4483362458) -- Title, Image
local Section = Tab1:CreateSection("Movement")
Section:Set("Movement")

Tab1:CreateInput({
    Name = "Walk Speed",
    CurrentValue = "",
    PlaceholderText = "Default: 16",
    RemoveTextAfterFocusLost = false,
    Flag = "InputWalkSpeed",
    Callback = function(Text)
        local val = tonumber(Text)
        if val then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end,
})

Tab1:CreateInput({
    Name = "Jump Power",
    CurrentValue = "",
    PlaceholderText = "Default: 50",
    RemoveTextAfterFocusLost = false,
    Flag = "InputJumpPower",
    Callback = function(Text)
        local val = tonumber(Text)
        if val then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = val end
        end
    end,
})
local noclipEnabled = false

Tab1:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "ToggleNoClip",
    Callback = function(Value)
        noclipEnabled = Value

        task.spawn(function()
            while noclipEnabled do
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
                task.wait(0.05)
            end
        end)
    end,
})


Tab1:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "ToggleFly",
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end,
})

Tab1:CreateInput({
    Name = "Fly Speed",
    CurrentValue = "",
    PlaceholderText = "Default: 50",
    RemoveTextAfterFocusLost = false,
    Flag = "InputFlySpeed",
    Callback = function(Text)
        local val = tonumber(Text)
        if val then flySpeed = val end
    end,
})

local Tab3 = Window:CreateTab("Misc", 4483362458)
local Section = Tab3:CreateSection("Misc")
Section:Set("Misc")

local Toggle = Tab3:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Flag = "Toggle_BlockDamage",
    Callback = function(Value)
        if Value then
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if self == RF and method == "InvokeServer" then
                    return nil
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        else
            -- Restore it
            setreadonly(mt, false)
            mt.__namecall = oldNamecall
            setreadonly(mt, true)
        end
    end,
})

local Button = Tab3:CreateButton({
   Name = "Claim Volcano",
   Callback = function()
    if cashEnabled then return end
        local ogCFrame = lp.Character:GetPivot()
        local middleCFrame = CFrame.new(-816.998291, 348.65094, 334.041504, 0.118985146, -7.769992e-9, -0.99289602, -2.8016989e-14, 1, -7.825587e-9, 0.99289602, 9.311565e-10, 0.118985146)

        lp.Character:PivotTo(middleCFrame)
        task.wait(0.5)
        lp.Character:PivotTo(ogCFrame)
   end,
})
local Label = Tab3:CreateLabel("Turn off cash collector to use claim volcano", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme
