-- Membuat GUI di bagian tengah layar
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local optionFrame = Instance.new("Frame")
local jokiUangButton = Instance.new("TextButton")
local jokiMinigameButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- Posisi di tengah
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.2 -- 80% transparansi

-- Judul
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SAMLONG CDID"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.TextStrokeTransparency = 0.5

-- Frame untuk tombol pilihan
optionFrame.Parent = mainFrame
optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
optionFrame.Position = UDim2.new(0, 0, 0.25, 0)
optionFrame.Size = UDim2.new(1, 0, 0, 120)
optionFrame.BorderSizePixel = 0

-- Tombol Joki Uang
jokiUangButton.Parent = optionFrame
jokiUangButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jokiUangButton.Position = UDim2.new(0.1, 0, 0.1, 0)
jokiUangButton.Size = UDim2.new(0.8, 0, 0, 40)
jokiUangButton.Font = Enum.Font.Gotham
jokiUangButton.Text = "Joki Uang"
jokiUangButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jokiUangButton.TextSize = 16
jokiUangButton.BorderSizePixel = 0

-- Tombol Joki Minigame
jokiMinigameButton.Parent = optionFrame
jokiMinigameButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jokiMinigameButton.Position = UDim2.new(0.1, 0, 0.55, 0)
jokiMinigameButton.Size = UDim2.new(0.8, 0, 0, 40)
jokiMinigameButton.Font = Enum.Font.Gotham
jokiMinigameButton.Text = "Joki Minigame"
jokiMinigameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jokiMinigameButton.TextSize = 16
jokiMinigameButton.BorderSizePixel = 0

-- Label Status
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(39, 55, 70)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16

-- Fungsi untuk menyembunyikan GUI
local function hideGUI()
    mainFrame.Visible = false -- Menyembunyikan GUI
end

-- Fungsi untuk mengeksekusi script
local function executeScript(script)
    local success, response = pcall(function()
        return loadstring(game:HttpGet(script))()
    end)

    if not success then
        warn("Error executing script: " .. response)
        statusLabel.Text = "Error executing script"
    end
end

-- Tombol Fungsi Joki Uang
jokiUangButton.MouseButton1Click:Connect(function()
    hideGUI() -- Menyembunyikan GUI
    -- Script khusus untuk Joki Uang
    script_key="AQrlbjFnTfgpymdjoFWKdKjuBfUDzIuy";

    getgenv().beta = false -- Versi beta off
    getgenv().autoFarmValue = true -- AutoFarm aktif
    getgenv().alwaysRojod = true -- Always Rojod
    getgenv().timeToTeleports = 45
    getgenv().timeToShad = 1
    getgenv().timeToRecall = 1

    loadstring(game:HttpGet("https://getsades.net"))() -- Eksekusi script
end)

-- Tombol Fungsi Joki Minigame
jokiMinigameButton.MouseButton1Click:Connect(function()
    hideGUI() -- Menyembunyikan GUI
    executeScript("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua") -- Menjalankan skrip joki minigame
end)
