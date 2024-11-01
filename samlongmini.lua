-- Membuat GUI minimalis di bagian kanan layar
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local teleportFrame = Instance.new("Frame")
local teleportBoxshopButton = Instance.new("TextButton")
local teleportDealerButton = Instance.new("TextButton")
local actionFrame = Instance.new("Frame")
local jumpButton = Instance.new("TextButton")
local noJumpButton = Instance.new("TextButton")
local minimizeButton = Instance.new("TextButton")
local exitButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
jumpButton.TextSize = 16
jumpButton.BorderSizePixel = 0

-- Tombol No Jump
noJumpButton.Parent = actionFrame
noJumpButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
noJumpButton.Position = UDim2.new(0.55, 0, 0.1, 0)
noJumpButton.Size = UDim2.new(0.35, 0, 0, 30)
noJumpButton.Font = Enum.Font.Gotham
noJumpButton.Text = "No Jump"
noJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noJumpButton.TextSize = 16
noJumpButton.BorderSizePixel = 0

-- Tombol Minimize
minimizeButton.Parent = mainFrame
minimizeButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
minimizeButton.Position = UDim2.new(0.75, 0, 0, 0)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 20
minimizeButton.BorderSizePixel = 0

-- Tombol Exit
exitButton.Parent = mainFrame
exitButton.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
exitButton.Position = UDim2.new(0.85, 0, 0, 0)
exitButton.Size = UDim2.new(0, 30, 0, 30)
exitButton.Font = Enum.Font.GothamBold
exitButton.Text = "X"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 20
exitButton.BorderSizePixel = 0

-- Label Status
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(39, 55, 70)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Choose an option:"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16

-- Fungsi untuk teleport ke boxshop
local function teleportToBoxshop()
    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(-2200, 50, 1377) -- Mengangkat posisi
    statusLabel.Text = "Teleported to Boxshop"
end

-- Fungsi untuk teleport ke dealer
local function teleportToDealer()
    local player = game.Players.LocalPlayer
    player.Character.HumanoidRootPart.CFrame = CFrame.new(539, 50, -1965) -- Mengangkat posisi
    statusLabel.Text = "Teleported to Dealer"
end

-- Fungsi untuk mengeksekusi script dari URL
local function executeScript(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        loadstring(response)() -- Menjalankan script
    else
        warn("Error fetching script: " .. response)
        statusLabel.Text = "Error executing script"
    end
end

-- Fungsi untuk menghentikan script (tambahkan logika sesuai kebutuhan Anda)
local function stopScript()
    -- Logic to stop the script goes here (if needed)
end

-- Tombol Fungsi
teleportBoxshopButton.MouseButton1Click:Connect(teleportToBoxshop)
teleportDealerButton.MouseButton1Click:Connect(teleportToDealer)

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

minimizeButton.MouseButton1Click:Connect(function()
    if mainFrame.Size.Y.Scale == 0 then
        mainFrame.Size = UDim2.new(0, 160, 0, 300)
    else
        mainFrame.Size = UDim2.new(0, 160, 0, 40)
    end
end)

exitButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

