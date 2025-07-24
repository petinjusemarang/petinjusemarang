-- GUI Samlong CDID with Rounded Corners, Clean Layout & Draggable
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SamlongGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 300)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Rounded Corners & Border Stroke
local uiCornerMain = Instance.new("UICorner", mainFrame)
uiCornerMain.CornerRadius = UDim.new(0, 12)
local uiStrokeMain = Instance.new("UIStroke", mainFrame)
uiStrokeMain.Thickness = 2
uiStrokeMain.Color = Color3.fromRGB(50, 50, 60)

-- Drag Functionality
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart
local startPos
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
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        updateDrag(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        updateDrag(input)
    end
end)

-- Title Bar & Close Button
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
local uiCornerTitle = Instance.new("UICorner", titleBar)
uiCornerTitle.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SAMLONG CDID"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
titleLabel.TextSize = 20

local closeButton = Instance.new("TextButton", titleBar)
closeButton.Name = "CloseBtn"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(200, 200, 205)
closeButton.TextSize = 18
closeButton.MouseEnter:Connect(function() closeButton.TextColor3 = Color3.fromRGB(255, 100, 100) end)
closeButton.MouseLeave:Connect(function() closeButton.TextColor3 = Color3.fromRGB(200, 200, 205) end)
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Content Frame with List Layout
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name = "Content"
contentFrame.BackgroundTransparency = 1
contentFrame.Position = UDim2.new(0, 0, 0, 50)
contentFrame.Size = UDim2.new(1, 0, 1, -80)

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.Padding = UDim.new(0, 0, 0, 12)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Utility to create buttons
local function createButton(text, callback)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Name = text:gsub("%s+", "")
    btn.AutoButtonColor = true
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 135, 240)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Buttons and their actions
createButton("Joki Uang", function()
    screenGui.Enabled = false
    getgenv().storeId = "VEZA0853#296293768636661771#$bRTipXIT"
    getgenv().teleportTime = "51.0"
    getgenv().startAutofarm = true
    getgenv().superLowCpuUsage = true
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/ef02dc52a6abf608dec6a0dea40654a0.lua"))()
end)

createButton("Joki Minigame", function()
    screenGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua"))()
end)

createButton("Joki Mancing", function()
    screenGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmancing.lua"))()
end)

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -30)
statusLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
statusLabel.BorderSizePixel = 0
local statusCorner = Instance.new("UICorner", statusLabel)
statusCorner.CornerRadius = UDim.new(0, 12)
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 205)
statusLabel.TextSize = 14
