repeat wait() until game:IsLoaded()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local boxfolder = workspace.Map.spawnPoints.Box

local safePos = Vector3.new(-821, 740, -21)

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

local normal = false
local safe = false
local selectedPlace = "Heaven Store"
local safeReturnPos = nil
local toggledSafe = false
local lastSafeTogglePos = nil
local returnFromFarmPos = nil

local pos = {
    ["AMM Cafe"] = Vector3.new(-82, 693, -501),
    ["Gacha Center"] = Vector3.new(-62, 694, -692),
    ["Heaven Store"] = Vector3.new(-96, 693, 0),
    ["Colosseum"] = Vector3.new(0, 705, 420),
    ["Field"] = Vector3.new(-194, 693, 0),
    ["Stand Storage"] = Vector3.new(-118, 693, -307)
}

local function nbf()
    while normal do
        if not hrp then
            if character then hrp = character:FindFirstChild("HumanoidRootPart") end
        end
        if not hrp then task.wait() continue end

        for _, part in pairs(boxfolder:GetChildren()) do
            local box = part:FindFirstChild("Box")
            if box then
                local base = box:FindFirstChild("Base")
                if base then
                    hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 2, 0))
                    task.wait(0.3)
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            fireproximityprompt(descendant)
                        end
                    end
                    break
                end
            end
        end
        task.wait()
    end
end

local function sbf()
    while safe do
        if not hrp then
            if character then hrp = character:FindFirstChild("HumanoidRootPart") end
        end
        if not hrp then task.wait() continue end

        local found = false
        for _, part in pairs(boxfolder:GetChildren()) do
            local box = part:FindFirstChild("Box")
            if box then
                local base = box:FindFirstChild("Base")
                if base then
                    hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 2, 0))
                    task.wait(0.3)
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            fireproximityprompt(descendant)
                        end
                    end
                    found = true
                    break
                end
            end
        end

        if not found then
            hrp.CFrame = CFrame.new(safePos)
        end

        task.wait()
    end
end

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "Heaven Stand",
    Icon = "door-open",
    Author = "_.1tableinsert on discord",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 200,
    HasOutline = true,
})

local Tabs = {
    main = Window:Tab({ Title = "Main", Icon = "pin" }),
}

Window:SelectTab(1)

Tabs.main:Section({ Title = "Farm" })

Tabs.main:Toggle({
    Title = "auto farm box",
    Default = false,
    Callback = function(state)
        normal = state
        if state then
            if hrp then
                returnFromFarmPos = hrp.Position
            end
            task.spawn(nbf)
        else
            if hrp and returnFromFarmPos then
                normal = false
                task.wait(0.2)
                hrp.CFrame = CFrame.new(returnFromFarmPos + Vector3.new(0, 1, 0))
            end
        end
    end
})

Tabs.main:Toggle({
    Title = "auto farm box (safe mode)",
    Default = false,
    Callback = function(state)
        safe = state
        if state then
            if hrp then
                safeReturnPos = hrp.Position
            end
            task.spawn(sbf)
        else
            safe = false
            if hrp and safeReturnPos then
                task.wait(0.2)
                hrp.CFrame = CFrame.new(safeReturnPos + Vector3.new(0, 1, 0))
                task.wait(0.05)
            end
        end
    end
})

Tabs.main:Toggle({
    Title = "save gpu usage",
    Default = false,
    Callback = function(state)
        game:GetService("RunService"):Set3dRenderingEnabled(not state)
    end
})

Tabs.main:Button({
    Title = "tp to safe pos",
    Callback = function()
        if not hrp then return end
        if not toggledSafe then
            lastSafeTogglePos = hrp.Position
            hrp.CFrame = CFrame.new(safePos)
            toggledSafe = true
        else
            if lastSafeTogglePos then
                hrp.CFrame = CFrame.new(lastSafeTogglePos)
            end
            toggledSafe = false
        end
    end
})

Tabs.main:Section({ Title = "^^ click again to teleport back ^^" })
Tabs.main:Section({ Title = "\nTeleport" })

Tabs.main:Dropdown({
    Title = "place to teleport",
    Values = { "Heaven Store", "Stand Storage", "AMM Cafe", "Field", "Gacha Center", "Colosseum" },
    Value = "Heaven Store",
    Callback = function(option)
        selectedPlace = option
    end
})

Tabs.main:Button({
    Title = "teleport",
    Callback = function()
        if hrp and pos[selectedPlace] then
            hrp.CFrame = CFrame.new(pos[selectedPlace])
        end
    end
})
