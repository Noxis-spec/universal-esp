-- universal-esp / main.lua
-- Drawing API + Highlight Version (Optimized for BEAR Alpha)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer

-- ==================== CONFIG ====================
local ESP_ENABLED = true
local SHOW_NAME = true
local SHOW_HEALTH = true
local TEAM_CHECK = true
local MAX_DISTANCE = 500
local COLOR_ENEMY = Color3.fromRGB(255, 60, 60)
-- ================================================

-- Проверка на наличие Drawing API (если исполнитель не поддерживает, скрипт не запустится)
if not Drawing then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ESP Error",
        Text = "Твой исполнитель не поддерживает Drawing API!",
        Duration = 5
    })
    return
end

-- ---------- GUI Parent ----------
local guiParent = game:GetService("CoreGui") 
local ok, gethui = pcall(function() return gethui() end)
if ok and gethui then guiParent = gethui end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalESP_Drawing"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

-- ---------- Кнопка ----------
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

-- Перетаскивание
local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = toggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

-- ---------- Drawing Objects & Highlight ----------
local espCache = {}

local function createESP(plr)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = COLOR_ENEMY
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Visible = false

    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Visible = false

    local highlight = Instance.new("Highlight")
    highlight.Name = "UniversalESP"
    highlight.FillColor = COLOR_ENEMY
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = plr.Character

    espCache[plr] = {
        box = box, name = name, healthBar = healthBar, highlight = highlight
    }
    return espCache[plr]
end

local function removeESP(plr)
    local esp = espCache[plr]
    if esp then
        esp.box:Remove()
        esp.name:Remove()
        esp.healthBar:Remove()
        if esp.highlight then esp.highlight:Destroy() end
        espCache[plr] = nil
    end
end

-- ---------- Главный цикл ----------
RunService.RenderStepped:Connect(function()
    if not ESP_ENABLED then
        for plr, _ in pairs(espCache) do removeESP(plr) end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == lp then removeESP(plr); continue end

        local char = plr.Character
        if not char then removeESP(plr); continue end

        local hum = char:FindFirstChildOfClass("Humanoid") or char:FindFirstChild("Humanoid")
        
        -- Умный поиск (GetDescendants + поддержка Part_)
        local targetPart = nil
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Torso" or part.Name == "UpperTorso") then
                targetPart = part
                break
            end
        end

        if not (targetPart and hum and hum.Health > 0) then removeESP(plr); continue end
        if TEAM_CHECK and lp.Team and plr.Team and lp.Team == plr.Team then removeESP(plr); continue end

        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        if distance > MAX_DISTANCE then removeESP(plr); continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then removeESP(plr); continue end

        local esp = espCache[plr]
        if not esp then esp = createESP(plr) end

        local height = math.clamp(1200 / distance, 30, 200)
        local width = height * 0.55

        -- Рисуем бокс
        esp.box.Size = Vector2.new(width, height)
        esp.box.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)
        esp.box.Visible = true

        -- Имя
        if SHOW_NAME then
            esp.name.Text = plr.Name
            esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - height / 2 - 15)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end

        -- Здоровье
        if SHOW_HEALTH and hum then
            local hpRatio = hum.Health / hum.MaxHealth
            local hbHeight = 4
            esp.healthBar.Size = Vector2.new(width * hpRatio, hbHeight)
            esp.healthBar.Position = Vector2.new(screenPos.X - width / 2, screenPos.Y + height / 2 + 2)
            esp.healthBar.Color = Color3.fromRGB(255 * (1 - hpRatio), 255 * hpRatio, 60)
            esp.healthBar.Visible = true
        else
            esp.healthBar.Visible = false
        end

        -- Highlight (подсветка)
        if esp.highlight then
            esp.highlight.Enabled = true
            esp.highlight.Parent = char
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)