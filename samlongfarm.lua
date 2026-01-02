-- GUI Samlong CDID with Rounded Corners, Clean Layout & Draggable
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local player            = Players.LocalPlayer

-- Root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name               = "SamlongGui"
screenGui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
screenGui.Parent             = player:WaitForChild("PlayerGui")

local rootGui = screenGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name            = "MainFrame"
mainFrame.Size            = UDim2.new(0, 320, 0, 300)
mainFrame.Position        = UDim2.new(0.5, -160, 0.5, -150)
mainFrame.BackgroundColor3= Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent          = screenGui

-- Rounded Corners & Border
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local uiStrokeMain = Instance.new("UIStroke", mainFrame)
uiStrokeMain.Thickness   = 2
uiStrokeMain.Color       = Color3.fromRGB(50, 50, 60)

-- Drag
local dragging, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Title Bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SAMLONG CDID"
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(240,240,245)

local closeButton = Instance.new("TextButton", titleBar)
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.TextColor3 = Color3.fromRGB(200,200,205)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Content
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.Size = UDim2.new(1, 0, 1, -80)
contentFrame.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.Padding = UDim.new(0, 12)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Button Factory
local function createButton(text, callback)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 135, 240)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Job Overlay
local function mountJobOverlay(startText, onStart)
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("SamlongJokiUI") then
        CoreGui.SamlongJokiUI:Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "SamlongJokiUI"
    gui.ResetOnSpawn = false

    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 300, 0, 60)
    btn.Position = UDim2.new(0.5, 0, 0.5, 0)
    btn.AnchorPoint = Vector2.new(0.5,0.5)
    btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    btn.Text = startText
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

    btn.MouseButton1Click:Connect(function()
        btn.Visible = false
        pcall(onStart)
    end)
end

-- ================= BUTTONS =================

-- Script Cadangan
createButton("Script Cadangan", function()
    rootGui.Enabled = false
    mountJobOverlay("Mulai", function()
        script_key = "ARL587cb17a235da7ed2503f4f80"
        loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/e05bef9ffd37684c"))()
    end)
end)

-- Uang Jatim
createButton("Uang Jatim", function()
    rootGui.Enabled = false
    mountJobOverlay("Mulai (reset HWID)", function()
        script_key = "phplKytbwSpUNwhVruyoOFmOuFHunJcT"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bimoraa/Euphoria/refs/heads/main/loader.luau"))()
    end)
end)

-- Joki Minigame
createButton("Joki Minigame", function()
    rootGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua"))()
end)

-- 🔥 QUEST NATAL (BARU)
createButton("Quest Natal", function()
    rootGui.Enabled = false
    mountJobOverlay("Mulai Quest Natal", function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/65696e4e3d9a66dba100768030b88e0b.lua"))()
    end)
end)

-- Status
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -30)
statusLabel.BackgroundColor3 = Color3.fromRGB(18,18,22)
statusLabel.Text = "Ready"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(200,200,205)
Instance.new("UICorner", statusLabel).CornerRadius = UDim.new(0,12)
