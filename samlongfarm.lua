-- GUI Samlong CDID with Rounded Corners, Clean Layout & Draggable
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local player            = Players.LocalPlayer

-- Root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name               = "SamlongGui"
screenGui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
screenGui.Parent             = player:WaitForChild("PlayerGui")

local rootGui = screenGui -- referensi ke GUI utama untuk hide/show

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name            = "MainFrame"
mainFrame.Size            = UDim2.new(0, 320, 0, 300)
mainFrame.Position        = UDim2.new(0.5, -160, 0.5, -150)
mainFrame.BackgroundColor3= Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent          = screenGui

-- Rounded Corners & Border Stroke
local uiCornerMain = Instance.new("UICorner", mainFrame)
uiCornerMain.CornerRadius = UDim.new(0, 12)
local uiStrokeMain = Instance.new("UIStroke", mainFrame)
uiStrokeMain.Thickness   = 2
uiStrokeMain.Color       = Color3.fromRGB(50, 50, 60)

-- Drag Functionality
local dragging, dragStart, startPos = false, nil, nil
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
        dragging, dragStart, startPos = true, input.Position, mainFrame.Position
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

-- Title Bar & Close Button
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name            = "TitleBar"
titleBar.Size            = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3= Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
local uiCornerTitle = Instance.new("UICorner", titleBar)
uiCornerTitle.CornerRadius = UDim.new(0, 12)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size               = UDim2.new(1, -40, 1, 0)
titleLabel.Position           = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font               = Enum.Font.GothamBold
titleLabel.Text               = "SAMLONG CDID"
titleLabel.TextColor3         = Color3.fromRGB(240, 240, 245)
titleLabel.TextSize           = 20

local closeButton = Instance.new("TextButton", titleBar)
closeButton.Name               = "CloseBtn"
closeButton.Size               = UDim2.new(0, 30, 0, 30)
closeButton.Position           = UDim2.new(1, -38, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Font               = Enum.Font.GothamBold
closeButton.Text               = "✕"
closeButton.TextColor3         = Color3.fromRGB(200, 200, 205)
closeButton.TextSize           = 18
closeButton.MouseEnter:Connect(function()
    closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 205)
end)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Content Frame with List Layout
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Name             = "Content"
contentFrame.BackgroundTransparency = 1
contentFrame.Position         = UDim2.new(0, 0, 0, 50)
contentFrame.Size             = UDim2.new(1, 0, 1, -80)

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.Padding            = UDim.new(0, 12)
listLayout.HorizontalAlignment= Enum.HorizontalAlignment.Center
listLayout.SortOrder          = Enum.SortOrder.LayoutOrder

-- Utility to create buttons
local function createButton(text, callback)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Name            = text:gsub("%s+", "")
    btn.AutoButtonColor = true
    btn.Size            = UDim2.new(0, 260, 0, 40)
    btn.BackgroundColor3= Color3.fromRGB(45, 135, 240)
    btn.Text            = text
    btn.Font            = Enum.Font.Gotham
    btn.TextColor3      = Color3.fromRGB(255, 255, 255)
    btn.TextSize        = 16
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Helper: overlay UI for Money display & idle timer (dipakai Joki Uang & Uang Jatim)
local function mountMoneyOverlay(player, parentGui)
    local playerGui  = player:WaitForChild("PlayerGui")
    local moneyLabel = playerGui
        :WaitForChild("Main")
        :WaitForChild("Container")
        :WaitForChild("Hub")
        :WaitForChild("CashFrame")
        :WaitForChild("Frame")
        :WaitForChild("TextLabel")

    local shadow = Instance.new("Frame", parentGui)
    shadow.Size               = UDim2.new(1, 0, 1, 0)
    shadow.BackgroundColor3   = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.4

    local mainF = Instance.new("Frame", parentGui)
    mainF.Size            = UDim2.new(0, 520, 0, 240)
    mainF.Position        = UDim2.new(0.5, 0, 0.5, 0)
    mainF.AnchorPoint     = Vector2.new(0.5, 0.5)
    mainF.BackgroundColor3= Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", mainF).CornerRadius = UDim.new(0, 16)

    local uangText = Instance.new("TextLabel", mainF)
    uangText.Size           = UDim2.new(1, -40, 0.6, 0)
    uangText.Position       = UDim2.new(0, 20, 0, 30)
    uangText.BackgroundTransparency = 1
    uangText.Font           = Enum.Font.GothamBlack
    uangText.TextScaled     = true
    uangText.TextColor3     = Color3.new(1, 1, 1)
    uangText.Text           = "Uangmu saat ini: "..moneyLabel.Text

    local earnText = Instance.new("TextLabel", mainF)
    earnText.Size           = UDim2.new(1, -40, 0.3, 0)
    earnText.Position       = UDim2.new(0, 20, 0.65, 0)
    earnText.BackgroundTransparency = 1
    earnText.Font           = Enum.Font.GothamSemibold
    earnText.TextScaled     = true
    earnText.TextColor3     = Color3.fromRGB(200, 200, 200)
    earnText.Text           = "Earn terakhir: -"

    local ng = Instance.new("TextLabel", parentGui)
    ng.Size            = UDim2.new(0, 600, 0, 100)
    ng.Position        = UDim2.new(0.5, 0, 0.85, 0)
    ng.AnchorPoint     = Vector2.new(0.5, 0.5)
    ng.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ng.Font            = Enum.Font.GothamBlack
    ng.TextScaled      = true
    ng.TextColor3      = Color3.new(1, 1, 1)
    ng.Text            = "SUPIR NGANGGUR BOS!!!"
    ng.Visible         = false
    Instance.new("UICorner", ng).CornerRadius = UDim.new(0, 12)

    local lastEarn = os.time()
    local prevMoney = tonumber((moneyLabel.Text:gsub("[^%d]", ""))) or 0

    moneyLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local currentMoney = tonumber((moneyLabel.Text:gsub("[^%d]", ""))) or 0
        if currentMoney ~= prevMoney then
            prevMoney = currentMoney
            lastEarn = os.time()
            uangText.Text = "Uangmu saat ini: "..moneyLabel.Text
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            local elapsed = os.time() - lastEarn
            earnText.Text = string.format(
                "Earn terakhir: %02d menit %02d detik yang lalu",
                math.floor(elapsed / 60),
                elapsed % 60
            )
            if elapsed >= 360 then -- 6 menit idle
                ng.Visible = true
                break
            end
        end
    end)
end

-- Helper: buat overlay “start & show UI”
local function mountJobOverlay(startText, onStart)
    if not game:IsLoaded() then game.Loaded:Wait() end
    local Players  = game:GetService("Players")
    local CoreGui  = game:GetService("CoreGui")
    local lplayer  = Players.LocalPlayer or Players.PlayerAdded:Wait()

    if CoreGui:FindFirstChild("SamlongJokiUI") then
        CoreGui.SamlongJokiUI:Destroy()
    end

    local jokiGui = Instance.new("ScreenGui")
    jokiGui.Name               = "SamlongJokiUI"
    jokiGui.ResetOnSpawn       = false
    jokiGui.ZIndexBehavior     = Enum.ZIndexBehavior.Global
    jokiGui.Parent             = CoreGui

    local function makeButton(size, pos, color, text)
        local btn = Instance.new("TextButton")
        btn.Size            = size
        btn.Position        = pos
        btn.AnchorPoint     = Vector2.new(0.5, 0.5)
        btn.BackgroundColor3= color
        btn.Text            = text
        btn.TextColor3      = Color3.new(1, 1, 1)
        btn.Font            = Enum.Font.GothamBold
        btn.TextScaled      = true
        btn.ZIndex          = 100
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        btn.Parent          = jokiGui
        return btn
    end

    local startBtn = makeButton(
        UDim2.new(0, 300, 0, 60),
        UDim2.new(0.5, 0, 0.5, 0),
        Color3.fromRGB(0, 170, 255),
        startText
    )

    local showUIBtn = makeButton(
        UDim2.new(0, 300, 0, 50),
        UDim2.new(0.5, 0, 0.65, 0),
        Color3.fromRGB(255, 170, 0),
        "Munculkan UI Samlong"
    )
    showUIBtn.Visible = false
    showUIBtn.AnchorPoint = Vector2.new(1, 1)
    showUIBtn.Position    = UDim2.new(1, -20, 1, -20)

    startBtn.MouseButton1Click:Connect(function()
        startBtn.Visible  = false
        showUIBtn.Visible = true
        -- jalankan fungsi start spesifik
        pcall(onStart)
    end)

    showUIBtn.MouseButton1Click:Connect(function()
        showUIBtn.Visible = false
        mountMoneyOverlay(lplayer, jokiGui)
    end)
end

-- ==== Joki Uang ====
createButton("Script cadangan", function()
    rootGui.Enabled = false
    mountJobOverlay("Mulai", function()
    sscript_key="ARL587cb17a235da7ed2503f4f80";
    loadstring(game:HttpGet("https://pandadevelopment.net/virtual/file/e05bef9ffd37684c"))()
    end)
end)

-- ==== Uang Jatim (replace Joki Mancing) ====
createButton("Uang Jatim", function()
    rootGui.Enabled = false
    mountJobOverlay("Mulai (jangan lupa reset HWID yaaa)", function()
        -- Execute script yang diminta
        script_key="phplKytbwSpUNwhVruyoOFmOuFHunJcT";
        loadstring(game:HttpGet("https://raw.githubusercontent.com/bimoraa/Euphoria/refs/heads/main/loader.luau"))()
    end)
end)

-- ==== Joki Minigame ====
createButton("Joki Minigame", function()
    rootGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua"))()
end)

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Name            = "Status"
statusLabel.Size            = UDim2.new(1, 0, 0, 30)
statusLabel.Position        = UDim2.new(0, 0, 1, -30)
statusLabel.BackgroundColor3= Color3.fromRGB(18, 18, 22)
statusLabel.BorderSizePixel = 0
local statusCorner = Instance.new("UICorner", statusLabel)
statusCorner.CornerRadius   = UDim.new(0, 12)
statusLabel.Font            = Enum.Font.Gotham
statusLabel.Text            = "Ready"
statusLabel.TextColor3      = Color3.fromRGB(200, 200, 205)
statusLabel.TextSize        = 14
