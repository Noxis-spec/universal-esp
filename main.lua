-- universal-esp / main.lua
-- Standalone version (No external libraries)
-- Deep Search Fix for BEAR (Alpha) SmartBone2 models

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- ==================== CONFIG ====================
local ESP_ENABLED = true
local SHOW_NAME = true
local SHOW_HEALTH = true
local SHOW_DISTANCE = true
local TEAM_CHECK = true          -- Скрывать союзников (если есть команды)
local MAX_DISTANCE = 500         -- Максимальная дистанция (в стадах)
local COLOR_ENEMY = Color3.fromRGB(255, 60, 60)
-- ================================================

-- ---------- GUI Parent ----------
local guiParent
do
    local ok, res = pcall(function() return gethui() end)
    if ok and res then 
        guiParent = res
    else
        local ok2, res2 = pcall(function() return game:GetService("CoreGui") end)
        if ok2 and res2 then 
            guiParent = res2
        else 
            guiParent = lp:WaitForChild("PlayerGui") 
        end
    end
end

for _, obj in ipairs(guiParent:GetChildren()) do
    if obj.Name == "UniversalESP" then obj:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalESP"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = guiParent

-- ---------- Кнопка Включения/Выключения ----------
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 110, 0, 32)
toggleBtn.Position = UDim2.new(0, 12, 0.5, -16)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "ESP: ON"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = toggleBtn

-- ---------- Перетаскивание кнопки ----------
local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    toggleBtn.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    toggleBtn.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
    if not ESP_ENABLED then
        for _, plr in ipairs(Players:GetPlayers()) do
            local esp = plr:FindFirstChild("UniversalESP")
            if esp then esp:Destroy() end
        end
    end
end)

-- ---------- Создание элементов ESP ----------
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

    esp.Parent = screenGui
    return esp
end

local function removeESP(plr)
    local esp = plr:FindFirstChild("UniversalESP")
    if esp then esp:Destroy() end
end

-- ---------- Главный цикл обновления ----------
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then
            removeESP(plr)
            continue
        end

        local char = plr.Character
        if not char then 
            removeESP(plr)
            continue
        end

        local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
        
        -- УМНЫЙ ПОИСК: перебираем ВСЕ дочерние элементы (GetDescendants)
        -- Ищем строго "HumanoidRootPart", чтобы не зацепить "Part_HumanoidRootPart"
        local targetPart = nil
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso" then
                    targetPart = part
                    break -- Нашли нужную деталь, останавливаем поиск
                end
            end
        end

        if not (targetPart and hum and hum.Health > 0) then
            removeESP(plr)
            continue
        end

        if TEAM_CHECK and lp.Team and plr.Team and lp.Team == plr.Team then
            removeESP(plr)
            continue
        end

        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        if distance > MAX_DISTANCE then
            removeESP(plr)
            continue
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
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