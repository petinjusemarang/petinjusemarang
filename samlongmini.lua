-- Membuat GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local jumpButton = Instance.new("TextButton")
local noJumpButton = Instance.new("TextButton")
local teleportButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

jumpButton.Parent = frame
jumpButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jumpButton.Position = UDim2.new(0.1, 0, 0.15, 0)
jumpButton.Size = UDim2.new(0, 200, 0, 40)
jumpButton.Font = Enum.Font.SourceSans
jumpButton.Text = "Jump"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 24
jumpButton.BorderSizePixel = 0
jumpButton.TextStrokeTransparency = 0.8

noJumpButton.Parent = frame
noJumpButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
noJumpButton.Position = UDim2.new(0.1, 0, 0.45, 0)
noJumpButton.Size = UDim2.new(0, 200, 0, 40)
noJumpButton.Font = Enum.Font.SourceSans
noJumpButton.Text = "No Jump"
noJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noJumpButton.TextSize = 24
noJumpButton.BorderSizePixel = 0
noJumpButton.TextStrokeTransparency = 0.8

teleportButton.Parent = frame
teleportButton.BackgroundColor3 = Color3.fromRGB(149, 165, 166)
teleportButton.Position = UDim2.new(0.1, 0, 0.75, 0)
teleportButton.Size = UDim2.new(0, 200, 0, 40)
teleportButton.Font = Enum.Font.SourceSans
teleportButton.Text = "Teleport"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 24
teleportButton.BorderSizePixel = 0
teleportButton.TextStrokeTransparency = 0.8

minimizeButton.Parent = frame
minimizeButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
minimizeButton.Position = UDim2.new(0.8, 0, 0, 0)
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Font = Enum.Font.SourceSans
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 24
minimizeButton.BorderSizePixel = 0
minimizeButton.TextStrokeTransparency = 0.8

statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.fromRGB(39, 55, 70)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.Size = UDim2.new(0, 250, 0, 30)
statusLabel.Font = Enum.Font.ArialBold
statusLabel.Text = "Choose an option:"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 20

-- Status kontrol
local isMinimized = false
local isPaused = false
local currentScript = nil
local dragging = false
local dragStart = nil
local startPos = nil

-- Fungsi untuk mengeksekusi script dan menghentikan script yang sudah ada
local function executeScript(url)
    if currentScript then
        pcall(function() currentScript:Disconnect() end)
    end

    if not isPaused then
        local scriptFunc = loadstring(game:HttpGet(url))
        currentScript = scriptFunc()
    end
end

-- Fungsi untuk menghentikan eksekusi script
local function stopScript()
    if currentScript then
        pcall(function() currentScript:Disconnect() end)
        currentScript = nil
    end
end

-- Fungsi untuk meminimalkan dan membesarkan GUI
local function toggleMinimize()
    if isMinimized then
        frame.Size = UDim2.new(0, 250, 0, 300)
        frame.Visible = true
        minimizeButton.Text = "-"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
    else
        frame.Size = UDim2.new(0, 250, 0, 40)
        frame.Visible = true
        minimizeButton.Text = "+"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(22, 160, 133)
    end
    isMinimized = not isMinimized
end

-- Fungsi Tombol
jumpButton.MouseButton1Click:Connect(function()
    stopScript()
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/jump.lua")
    statusLabel.Text = "Jump script executed"
end)

noJumpButton.MouseButton1Click:Connect(function()
    stopScript()
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/nojump.lua")
    statusLabel.Text = "No Jump script executed"
end)

teleportButton.MouseButton1Click:Connect(function()
    stopScript()
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/teleport.lua")
    statusLabel.Text = "Teleport script executed"
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleMinimize()
end)

-- Fungsi Drag GUI
local function onDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end

local function onDragMove(input)
    if dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

local function onDragEnd(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

-- Menghubungkan fungsi drag ke seluruh frame
frame.InputBegan:Connect(onDrag)
frame.InputChanged:Connect(onDragMove)
frame.InputEnded:Connect(onDragEnd)

-- Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    statusLabel.Text = "Anti-AFK Active"
end)
