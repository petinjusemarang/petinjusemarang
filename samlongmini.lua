-- Membuat GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local jumpButton = Instance.new("TextButton")
local noJumpButton = Instance.new("TextButton")
local teleportButton1 = Instance.new("TextButton")
local teleportButton2 = Instance.new("TextButton")
local exitButton = Instance.new("TextButton")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true

jumpButton.Parent = frame
jumpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpButton.Position = UDim2.new(0.1, 0, 0.1, 0)
jumpButton.Size = UDim2.new(0.8, 0, 0.15, 0)
jumpButton.Font = Enum.Font.SourceSans
jumpButton.Text = "Jump Mode"
jumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpButton.TextSize = 18

noJumpButton.Parent = frame
noJumpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
noJumpButton.Position = UDim2.new(0.1, 0, 0.3, 0)
noJumpButton.Size = UDim2.new(0.8, 0, 0.15, 0)
noJumpButton.Font = Enum.Font.SourceSans
noJumpButton.Text = "No Jump Mode"
noJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noJumpButton.TextSize = 18

teleportButton1.Parent = frame
teleportButton1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
teleportButton1.Position = UDim2.new(0.1, 0, 0.5, 0)
teleportButton1.Size = UDim2.new(0.8, 0, 0.15, 0)
teleportButton1.Font = Enum.Font.SourceSans
teleportButton1.Text = "Teleport 1"
teleportButton1.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton1.TextSize = 18

teleportButton2.Parent = frame
teleportButton2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
teleportButton2.Position = UDim2.new(0.1, 0, 0.7, 0)
teleportButton2.Size = UDim2.new(0.8, 0, 0.15, 0)
teleportButton2.Font = Enum.Font.SourceSans
teleportButton2.Text = "Teleport 2"
teleportButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton2.TextSize = 18

exitButton.Parent = frame
exitButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
exitButton.Position = UDim2.new(0.85, 0, 0, 0)
exitButton.Size = UDim2.new(0.15, 0, 0.15, 0)
exitButton.Font = Enum.Font.SourceSans
exitButton.Text = "X"
exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitButton.TextSize = 18

-- Fungsi untuk teleportasi pemain
local function teleportPlayer(position)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Fungsi untuk tombol-tombol
jumpButton.MouseButton1Click:Connect(function()
    print("Jump mode activated") -- Tambahkan fungsi yang sesuai dengan kebutuhan
end)

noJumpButton.MouseButton1Click:Connect(function()
    print("No jump mode activated") -- Tambahkan fungsi yang sesuai dengan kebutuhan
end)

teleportButton1.MouseButton1Click:Connect(function()
    teleportPlayer(Vector3.new(-225, -2, 24)) -- Lokasi teleport pertama
end)

teleportButton2.MouseButton1Click:Connect(function()
    teleportPlayer(Vector3.new(-2200.85, 24.02, 1379.30)) -- Lokasi teleport kedua
end)

exitButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
