repeat wait() until game:IsLoaded()
setfpscap(60000)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local boxfolder = workspace.Map.spawnPoints.Box
local VirtualInputManager = game:GetService("VirtualInputManager")

local firePrompt = function()
    if fireproximityprompt then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                fireproximityprompt(d)
            end
        end
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    end
end

local safePos = Vector3.new(-821, 740, -21)

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end)

local normal = false
local safe = false
local autoSell = false
local selectedPlace = "Heaven Store"
local safeReturnPos = nil
local toggledSafe = false
local lastSafeTogglePos = nil
local returnFromFarmPos = nil
local saveDeathPos = false
local lastDeathPos = nil

local pos = {
    ["AMM Cafe"] = Vector3.new(-82, 693, -501),
    ["Gacha Center"] = Vector3.new(-62, 694, -692),
    ["Heaven Store"] = Vector3.new(-96, 693, 0),
    ["Colosseum"] = Vector3.new(0, 705, 420),
    ["Field"] = Vector3.new(-194, 693, 0),
    ["Stand Storage"] = Vector3.new(-118, 693, -307)
}

local function sell()
    local args = {
        buffer.fromstring("\006"),
        {
            {
                true,
                true
            }
        }
    }
    game.ReplicatedStorage.Utility.Warp.Index.Event.Reliable:FireServer(unpack(args))
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    hum.Died:Connect(function()
        if saveDeathPos then
            lastDeathPos = root.Position
        end
    end)
end)

local function teleportToLastDeath()
    if saveDeathPos and lastDeathPos then
        task.wait(0.07)
        local newChar = player.Character or player.CharacterAdded:Wait()
        local newRoot = newChar:WaitForChild("HumanoidRootPart")
        newRoot.CFrame = CFrame.new(lastDeathPos)
    end
end

player.CharacterAdded:Connect(function()
    if saveDeathPos and lastDeathPos then
        teleportToLastDeath()
    end
end)

local function nbf()
    while normal do
        if not hrp then task.wait(0.2) continue end
        for _, part in pairs(boxfolder:GetChildren()) do
            local box = part:FindFirstChild("Box")
            local base = box and box:FindFirstChild("Base")
            if base then
                hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 2, 0))
                task.wait(0.3)
                firePrompt()
                break
            end
        end
        task.wait(0.5)
    end
end

local function sbf()
    while safe do
        if not hrp then task.wait(0.2) continue end
        local found = false
        for _, part in pairs(boxfolder:GetChildren()) do
            local box = part:FindFirstChild("Box")
            local base = box and box:FindFirstChild("Base")
            if base then
                hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 2, 0))
                task.wait(0.3)
                firePrompt()
                found = true
                break
            end
        end
        if not found then
            hrp.CFrame = CFrame.new(safePos)
        end
        task.wait(0.6)
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
Window:SetToggleKey(Enum.KeyCode.P)

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
            returnFromFarmPos = hrp and hrp.Position
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
            safeReturnPos = hrp and hrp.Position
            task.spawn(sbf)
        else
            safe = false
            task.wait(0.2)
            if hrp and safeReturnPos then
                hrp.CFrame = CFrame.new(safeReturnPos + Vector3.new(0, 1, 0))
                task.wait(0.05)
                if normal then
                    task.spawn(nbf)
                end
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
Tabs.main:Section({ Title = "Item" })

local Paragraph = Tabs.main:Paragraph({
    Title = "Item count",
    Desc = "",
})

task.spawn(function()
    while true do
        task.wait(0.05)
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            Paragraph:SetDesc("Items: " .. #backpack:GetChildren())
        end
    end
end)

Tabs.main:Button({
    Title = "sell inventory",
    Callback = function()
        sell()
    end
})

Tabs.main:Button({
    Title = "sell in-hand",
    Callback = function()
        local args = {
            buffer.fromstring("\006"),
            {
                {}
            }
        }
        game.ReplicatedStorage.Utility.Warp.Index.Event.Reliable:FireServer(unpack(args))
    end
})
Tabs.main:Section({ Title = "Teleport" })
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
Tabs.main:Section({ Title = "Misc" })

Tabs.main:Toggle({
    Title = "tp to death pos",
    Default = false,
    Callback = function(state)
        saveDeathPos = state
        if not state then
            lastDeathPos = nil
        end
    end
})

Tabs.main:Button({
    Title = "open stand storage",
    Callback = function()
        player.PlayerGui.MainScreen.Main.Storage.Visible = true
    end
})

Tabs.main:Section({ Title = "Gacha" })

local function buycoin()
    local args = {
        buffer.fromstring("\022"),
        {
            {
                "Coin"
            }
        }
    }
    game:GetService("ReplicatedStorage").Utility.Warp.Index.Event.Reliable:FireServer(unpack(args))
end

local function spin()
    local args = {
        buffer.fromstring("\013"),
        {
            {
                1
            }
        }
    }
    game:GetService("ReplicatedStorage").Utility.Warp.Index.Event.Reliable:FireServer(unpack(args))
end

local function spin1()
    local args = {
        buffer.fromstring("\013"),
        {
            {
                10
            }
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Utility"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
end

Tabs.main:Button({
    Title = "buy coin (1)",
    Callback = function()
        buycoin()
    end
})

Tabs.main:Button({
    Title = "buy coin (10)",
    Callback = function()
        for i = 1, 10 do
            buycoin()
        end
    end
})

Tabs.main:Button({
    Title = "Spin 1",
    Callback = function()
        spin()
    end
})

Tabs.main:Button({
    Title = "Spin 10",
    Callback = function()
        spin1()
    end
})
