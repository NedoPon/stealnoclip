-- Проверка на дублирование: ищем существующий GUI в CoreGui или PlayerGui
local Player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local GUI_NAME = "AntiWallLaserHub_v1"
local ExistingGui = CoreGui:FindFirstChild(GUI_NAME) or Player:FindFirstChildOfClass("PlayerGui"):FindFirstChild(GUI_NAME)

if ExistingGui then
    -- Если скрипт уже запущен, не создаем копию, а просто уведомляем (или можно её удалить)
    print("[Hub] Скрипт уже запущен!")
    return
end

-- Переменные состояний (флаги функций)
local NoclipEnabled = false
local AntiLaserEnabled = false

-- === СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ===
local TargetGuiParent = CoreGui:ClassName == "CoreGui" and CoreGui or Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetGuiParent

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать окно по экрану
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Wall & Laser Bypass"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Кнопка закрытия (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    NoclipEnabled = false
    AntiLaserEnabled = false
    ScreenGui:Destroy()
end)

-- Кнопка 1: Обход стен (Noclip)
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(1, -20, 0, 40)
NoclipBtn.Position = UDim2.new(0, 10, 0, 50)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
NoclipBtn.Text = "Noclip: OFF"
NoclipBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
NoclipBtn.Font = Enum.Font.SourceSans
NoclipBtn.TextSize = 16
NoclipBtn.Parent = MainFrame

local Corner1 = Instance.new("UICorner")
Corner1.CornerRadius = UDim.new(0, 6)
Corner1.Parent = NoclipBtn

-- Кнопка 2: Уничтожение Лазеров (Anti-Laser)
local LaserBtn = Instance.new("TextButton")
LaserBtn.Size = UDim2.new(1, -20, 0, 40)
LaserBtn.Position = UDim2.new(0, 10, 0, 105)
LaserBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
LaserBtn.Text = "Anti-Laser: OFF"
LaserBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
LaserBtn.Font = Enum.Font.SourceSans
LaserBtn.TextSize = 16
LaserBtn.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 6)
Corner2.Parent = LaserBtn


-- === ЛОГИКА ФУНКЦИЙ ===

-- 1. Логика Noclip (Каждый кадр отключает коллизию)
RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    NoclipEnabled = not NoclipEnabled
    if NoclipEnabled then
        NoclipBtn.Text = "Noclip: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        NoclipBtn.Text = "Noclip: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        NoclipBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- 2. Логика Anti-Laser (Уничтожает или делает безопасными объекты-лазеры)
-- Функция сканирует Workspace на наличие парт с именами "Laser", "Kill", "Dead" или с ярким неоновым красным цветом
local function bypassLasers()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Проверка по ключевым словам в названии или по свойствам смертоносных лазеров
            if string.find(string.lower(obj.Name), "laser") or 
               string.find(string.lower(obj.Name), "kill") or 
               (obj.Material == Enum.Material.Neon and (obj.Color.R > 0.8 and obj.Color.G < 0.2)) then
                
                -- Делаем лазер полностью неосязаемым и прозрачным (или можно вызвать obj:Destroy())
                obj.CanTouch = false
                obj.CanCollide = false
                obj.Transparency = 0.7
            end
        end
    end
end

-- Цикл проверки лазеров (работает раз в секунду, если включен, чтобы обрабатывать новые лазеры)
task.spawn(function()
    while true do
        if AntiLaserEnabled then
            pcall(bypassLasers)
        end
        task.wait(1)
    end
end)

LaserBtn.MouseButton1Click:Connect(function()
    AntiLaserEnabled = not AntiLaserEnabled
    if AntiLaserEnabled then
        LaserBtn.Text = "Anti-Laser: ON"
        LaserBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        LaserBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pcall(bypassLasers) -- Мгновенный первый запуск
    else
        LaserBtn.Text = "Anti-Laser: OFF"
        LaserBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        LaserBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

print("[Hub] Скрипт успешно загружен!")
