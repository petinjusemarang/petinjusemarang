@@ -1,9 +1,13 @@
-- Membuat GUI
-- Membuat GUI minimalis di bagian kanan layar
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local mainFrame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local teleportFrame = Instance.new("Frame")
local teleportBoxshopButton = Instance.new("TextButton")
local teleportDealerButton = Instance.new("TextButton")
local actionFrame = Instance.new("Frame")
local jumpButton = Instance.new("TextButton")
local noJumpButton = Instance.new("TextButton")
local teleportButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local exitButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")
@@ -12,125 +16,150 @@ local statusLabel = Instance.new("TextLabel")
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.Size = UDim2.new(0, 250, 0, 300)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

jumpButton.Parent = frame
jumpButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jumpButton.Position = UDim2.new(0.1, 0, 0.2, 0)
jumpButton.Size = UDim2.new(0, 200, 0, 40)
jumpButton.Font = Enum.Font.GothamBold
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Position = UDim2.new(1, -180, 0.5, -150) -- Posisi di kanan tengah
mainFrame.Size = UDim2.new(0, 160, 0, 300) -- Ukuran lebih slim
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.2 -- 80% transparansi

-- Judul
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Teleport GUI"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.TextStrokeTransparency = 0.5

-- Frame untuk tombol teleport
teleportFrame.Parent = mainFrame
teleportFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportFrame.Position = UDim2.new(0, 0, 0.15, 0)
teleportFrame.Size = UDim2.new(1, 0, 0, 80) -- Ukuran lebih kecil
teleportFrame.BorderSizePixel = 0

-- Tombol Teleport Boxshop
teleportBoxshopButton.Parent = teleportFrame
teleportBoxshopButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
teleportBoxshopButton.Position = UDim2.new(0.1, 0, 0.1, 0)
teleportBoxshopButton.Size = UDim2.new(0.8, 0, 0, 30)
teleportBoxshopButton.Font = Enum.Font.Gotham
teleportBoxshopButton.Text = "Boxshop"
teleportBoxshopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBoxshopButton.TextSize = 16
teleportBoxshopButton.BorderSizePixel = 0

-- Tombol Teleport Dealer
teleportDealerButton.Parent = teleportFrame
teleportDealerButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
teleportDealerButton.Position = UDim2.new(0.1, 0, 0.55, 0) -- Jarak diatur agar lebih rapi
teleportDealerButton.Size = UDim2.new(0.8, 0, 0, 30)
teleportDealerButton.Font = Enum.Font.Gotham
teleportDealerButton.Text = "Dealer"
teleportDealerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportDealerButton.TextSize = 16
teleportDealerButton.BorderSizePixel = 0

-- Frame untuk tombol aksi
actionFrame.Parent = mainFrame
actionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
actionFrame.Position = UDim2.new(0, 0, 0.45, 0)
actionFrame.Size = UDim2.new(1, 0, 0, 80) -- Ukuran lebih kecil
actionFrame.BorderSizePixel = 0

-- Tombol Jump
jumpButton.Parent = actionFrame
jumpButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
jumpButton.Position = UDim2.new(0.1, 0, 0.1, 0)
jumpButton.Size = UDim2.new(0.35, 0, 0, 30)
jumpButton.Font = Enum.Font.Gotham
jumpButton.Text = "Jump"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 24
jumpButton.TextSize = 16
jumpButton.BorderSizePixel = 0
jumpButton.TextStrokeTransparency = 0.8

noJumpButton.Parent = frame
-- Tombol No Jump
noJumpButton.Parent = actionFrame
noJumpButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
noJumpButton.Position = UDim2.new(0.1, 0, 0.4, 0)
noJumpButton.Size = UDim2.new(0, 200, 0, 40)
noJumpButton.Font = Enum.Font.GothamBold
noJumpButton.Position = UDim2.new(0.55, 0, 0.1, 0)
noJumpButton.Size = UDim2.new(0.35, 0, 0, 30)
noJumpButton.Font = Enum.Font.Gotham
noJumpButton.Text = "No Jump"
noJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noJumpButton.TextSize = 24
noJumpButton.TextSize = 16
noJumpButton.BorderSizePixel = 0
noJumpButton.TextStrokeTransparency = 0.8

teleportButton.Parent = frame
teleportButton.BackgroundColor3 = Color3.fromRGB(149, 165, 166)
teleportButton.Position = UDim2.new(0.1, 0, 0.6, 0)
teleportButton.Size = UDim2.new(0, 200, 0, 40)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.Text = "Teleport"
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.TextSize = 24
teleportButton.BorderSizePixel = 0
teleportButton.TextStrokeTransparency = 0.8

minimizeButton.Parent = frame

-- Tombol Minimize
minimizeButton.Parent = mainFrame
minimizeButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
minimizeButton.Position = UDim2.new(0.78, 0, 0, 0)
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(0.75, 0, 0, 0)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 24
minimizeButton.TextSize = 20
minimizeButton.BorderSizePixel = 0
minimizeButton.TextStrokeTransparency = 0.8

exitButton.Parent = frame
-- Tombol Exit
exitButton.Parent = mainFrame
exitButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
exitButton.Position = UDim2.new(0.88, 0, 0, 0)
exitButton.Size = UDim2.new(0, 40, 0, 40)
exitButton.Position = UDim2.new(0.85, 0, 0, 0)
exitButton.Size = UDim2.new(0, 30, 0, 30)
exitButton.Font = Enum.Font.GothamBold
exitButton.Text = "X"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 24
exitButton.TextSize = 20
exitButton.BorderSizePixel = 0
exitButton.TextStrokeTransparency = 0.8

statusLabel.Parent = frame
-- Label Status
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(39, 55, 70)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.Size = UDim2.new(0, 250, 0, 30)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Font = Enum.Font.Gotham
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
statusLabel.TextSize = 16

-- Fungsi untuk mengeksekusi script dan menghentikan script yang sudah ada
local function executeScript(url)
    if currentScript then
        pcall(function() currentScript:Disconnect() end)
    end

    if not isPaused then
        local scriptFunc = loadstring(game:HttpGet(url))
        currentScript = scriptFunc()
    end
-- Fungsi untuk teleport ke boxshop
local function teleportToBoxshop()
    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-2200, 50, 1377) -- Mengangkat posisi
    statusLabel.Text = "Teleported to Boxshop"
end

-- Fungsi untuk menghentikan eksekusi script
local function stopScript()
    if currentScript then
        pcall(function() currentScript:Disconnect() end)
        currentScript = nil
    end
-- Fungsi untuk teleport ke dealer
local function teleportToDealer()
    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(539, 50, -1965) -- Mengangkat posisi
    statusLabel.Text = "Teleported to Dealer"
end

-- Fungsi untuk meminimalkan dan membesarkan GUI
local function toggleMinimize()
    if isMinimized then
        frame.Size = UDim2.new(0, 250, 0, 300)
        minimizeButton.Text = "-"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
-- Fungsi untuk mengeksekusi script dari URL
local function executeScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        loadstring(response)() -- Menjalankan script
    else
        frame.Size = UDim2.new(0, 250, 0, 40)
        minimizeButton.Text = "+"
        minimizeButton.BackgroundColor3 = Color3.fromRGB(22, 160, 133)
        warn("Error fetching script: " .. response)
        statusLabel.Text = "Error executing script"
    end
    isMinimized = not isMinimized
end

-- Fungsi untuk menutup GUI
local function closeGui()
    screenGui:Destroy()
-- Fungsi untuk menghentikan script (tambahkan logika sesuai kebutuhan Anda)
local function stopScript()
    -- Logic to stop the script goes here (if needed)
end

-- Fungsi Tombol
-- Tombol Fungsi
teleportBoxshopButton.MouseButton1Click:Connect(teleportToBoxshop)
teleportDealerButton.MouseButton1Click:Connect(teleportToDealer)

jumpButton.MouseButton1Click:Connect(function()
    stopScript()
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/jump.lua")
@@ -143,52 +172,15 @@ noJumpButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "No Jump script executed"
end)

teleportButton.MouseButton1Click:Connect(function()
    stopScript()
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/teleport.lua")
    statusLabel.Text = "Teleport script executed"
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleMinimize()
    if mainFrame.Size.Y.Scale == 0 then
        mainFrame.Size = UDim2.new(0, 160, 0, 300)
    else
        mainFrame.Size = UDim2.new(0, 160, 0, 40)
    end
end)

exitButton.MouseButton1Click:Connect(function()
    closeGui()
    screenGui:Destroy()
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
