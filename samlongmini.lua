-- Membuat GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local jumpButton = Instance.new("TextButton")
local noJumpButton = Instance.new("TextButton")
local pauseButton = Instance.new("TextButton")
local statusLabel = Instance.new("TextLabel")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = screenGui
frame.BackgroundColor3 = Color3.new(0.176, 0.176, 0.176)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.Size = UDim2.new(0, 200, 0, 200)

jumpButton.Parent = frame
jumpButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
jumpButton.Position = UDim2.new(0.1, 0, 0.15, 0)
jumpButton.Size = UDim2.new(0, 160, 0, 40)
jumpButton.Font = Enum.Font.SourceSans
jumpButton.Text = "Jump"
jumpButton.TextColor3 = Color3.new(1, 1, 1)
jumpButton.TextSize = 24

noJumpButton.Parent = frame
noJumpButton.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
noJumpButton.Position = UDim2.new(0.1, 0, 0.45, 0)
noJumpButton.Size = UDim2.new(0, 160, 0, 40)
noJumpButton.Font = Enum.Font.SourceSans
noJumpButton.Text = "No Jump"
noJumpButton.TextColor3 = Color3.new(1, 1, 1)
noJumpButton.TextSize = 24

pauseButton.Parent = frame
pauseButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
pauseButton.Position = UDim2.new(0.1, 0, 0.75, 0)
pauseButton.Size = UDim2.new(0, 160, 0, 40)
pauseButton.Font = Enum.Font.SourceSans
pauseButton.Text = "Pause"
pauseButton.TextColor3 = Color3.new(1, 1, 1)
pauseButton.TextSize = 24

statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.new(0.196, 0.196, 0.196)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Font = Enum.Font.ArialBold
statusLabel.Text = "Choose an option:"
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextSize = 20

-- Status kontrol
local isPaused = false
local currentScript = nil

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

pauseButton.MouseButton1Click:Connect(function()
    isPaused = not isPaused
    if isPaused then
        stopScript()
        statusLabel.Text = "Script Paused"
        pauseButton.Text = "Resume"
    else
        statusLabel.Text = "Choose an option:"
        pauseButton.Text = "Pause"
    end
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    statusLabel.Text = "Anti-AFK Active"
end)
