-- universal-esp / main.lua
-- Mobile-friendly ESP using Rayfield UI Library

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- ==================== ЗАГРУЗКА RAYFIELD ====================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)

if not success or not Rayfield then
    warn("Не удалось загрузить Rayfield. Проверь интернет или исполнитель.")
    return
end

-- ==================== НАСТРОЙКИ ====================
local ESP_ENABLED = true
local SHOW_NAME = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local TEAM_CHECK = true
local MAX_DISTANCE = 500
local COLOR_ENEMY = Color3.fromRGB(255, 60, 60)
-- =========================================================

-- ==================== СОЗДАНИЕ ОКНА ====================
local Window = Rayfield:CreateWindow({
    Name = "Universal ESP",
    LoadingTitle = "Universal ESP",
    LoadingSubtitle = "by Noxis-spec",
    Theme = "Default", -- Можно поменять на "Amethyst", "Dark" и т.д.
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "UniversalESP"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", nil)

-- ==================== ПЕРЕКЛЮЧАТЕЛИ ====================
MainTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = true,
    Flag = "ESP_Enabled",
    Callback = function(value)
        ESP_ENABLED = value
        if not value then
            -- Принудительно удаляем все ESP с экрана
            for _, plr in ipairs(Players:GetPlayers()) do
                local esp = plr:FindFirstChild("UniversalESP")
                if esp then esp:Destroy() end
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ESP_Names",
    Callback = function(value)
        SHOW_NAME = value
    end,
})

MainTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ESP_Health",
    Callback = function(value)
        SHOW_HEALTH = value
        if not value then
            for _, plr in ipairs(Players:GetPlayers()) do
                local esp = plr:FindFirstChild("UniversalESP")
                if esp then
                    local hb = esp:FindFirstChild("HealthBg")
                    if hb then hb.Visible = false end
                end
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ESP_Distance",
    Callback = function(value)
        SHOW_DISTANCE = value
        if not value then
            for _, plr in ipairs(Players:GetPlayers()) do
                local esp = plr:FindFirstChild("UniversalESP")
                if esp then
                    local dl = esp:FindFirstChild("Distance")
                    if dl then dl.Visible = false end
                end
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Team Check (Hide Teammates)",
    CurrentValue = true,
    Flag = "ESP_TeamCheck",
    Callback = function(value)
        TEAM_CHECK = value
    end,
})

-- ==================== ЛОГИКА ESP (БЕЗ ИЗМЕНЕНИЙ) ====================
local guiParent = game:GetService("CoreGui")
if not pcall(function() return guiParent end) then
    guiParent = lp:WaitForChild("PlayerGui")
end

local function createESP(plr)
    local esp = Instance.new("Folder")
    esp.Name = "UniversalESP"

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Parent = esp

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLOR_ENEMY
    stroke.Thickness = 1.5
    stroke.Parent = box

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "Name"
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextStrokeTransparency = 0
    nameLbl.Text = plr.Name
    nameLbl.Parent = esp

    local healthBg = Instance.new("Frame")
    healthBg.Name = "HealthBg"
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = esp

    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = healthBg

    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "Distance"
    distLbl.BackgroundTransparency = 1
    distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 10
    distLbl.Text = ""
    distLbl.Parent = esp

    esp.Parent = guiParent
    return esp
end

local function removeESP(plr)
    local esp = plr:FindFirstChild("UniversalESP")
    if esp then esp:Destroy() end
end

RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then
            removeESP(plr)
            continue
        end

        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not (hrp and hum and hum.Health > 0) then
            removeESP(plr)
            continue
        end

        if TEAM_CHECK and lp.Team and plr.Team and lp.Team == plr.Team then
            removeESP(plr)
            continue
        end

        local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
        if distance > MAX_DISTANCE then
            removeESP(plr)
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            removeESP(plr)
            continue
        end

        local esp = plr:FindFirstChild("UniversalESP")
        if not esp then
            esp = createESP(plr)
        end

        local height = math.clamp(1200 / distance, 30, 200)
        local width = height * 0.55

        local box = esp:FindFirstChild("Box")
        box.Size = UDim2.new(0, width, 0, height)
        box.Position = UDim2.new(0, screenPos.X - width / 2, 0, screenPos.Y - height / 2)

        local nameLbl = esp:FindFirstChild("Name")
        nameLbl.Visible = SHOW_NAME
        if SHOW_NAME then
            nameLbl.Text = plr.Name
            nameLbl.Size = UDim2.new(0, 160, 0, 14)
            nameLbl.Position = UDim2.new(0, screenPos.X - 80, 0, screenPos.Y - height / 2 - 16)
        end

        local healthBg = esp:FindFirstChild("HealthBg")
        local healthFill = healthBg:FindFirstChild("HealthFill")
        healthBg.Visible = SHOW_HEALTH
        if SHOW_HEALTH then
            local hpRatio = hum.Health / hum.MaxHealth
            healthBg.Size = UDim2.new(0, width, 0, 4)
            healthBg.Position = UDim2.new(0, screenPos.X - width / 2, 0, screenPos.Y + height / 2 + 2)
            healthFill.Size = UDim2.new(hpRatio, 0, 1, 0)
            healthFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - hpRatio)),
                math.floor(255 * hpRatio),
                60
            )
        end

        local distLbl = esp:FindFirstChild("Distance")
        distLbl.Visible = SHOW_DISTANCE
        if SHOW_DISTANCE then
            distLbl.Text = string.format("%d studs", math.floor(distance))
            distLbl.Size = UDim2.new(0, 100, 0, 12)
            distLbl.Position = UDim2.new(0, screenPos.X - 50, 0, screenPos.Y + height / 2 + 8)
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)