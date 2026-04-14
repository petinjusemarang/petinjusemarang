-- GUI Samlong CDID v3 — Modern + Auto Sheets + Serverlock
-- Fitur baru: username display, format uang Indonesia, Google Sheets tiap 15 menit, auto serverlock

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local player            = Players.LocalPlayer

-- ═══════════════════════════════════
--  CONFIG
-- ═══════════════════════════════════
local CONFIG = {
    BgPrimary    = Color3.fromRGB(18, 18, 24),
    BgHeader     = Color3.fromRGB(12, 12, 18),
    BgButton     = Color3.fromRGB(45, 135, 240),
    BgBtnHover   = Color3.fromRGB(65, 155, 255),
    BgBtnDanur   = Color3.fromRGB(220, 70, 60),
    BgBtnDanurH  = Color3.fromRGB(240, 90, 80),
    BgBtnGreen   = Color3.fromRGB(40, 170, 90),
    BgBtnGreenH  = Color3.fromRGB(55, 195, 110),
    BgBtnPurple  = Color3.fromRGB(140, 80, 220),
    BgBtnPurpleH = Color3.fromRGB(160, 100, 240),
    TextPrimary  = Color3.fromRGB(240, 240, 245),
    TextSecondary= Color3.fromRGB(180, 180, 190),
    TextMuted    = Color3.fromRGB(100, 100, 115),
    Border       = Color3.fromRGB(45, 45, 58),
    Separator    = Color3.fromRGB(35, 35, 48),
    StatusBg     = Color3.fromRGB(12, 12, 18),
    Danger       = Color3.fromRGB(240, 70, 70),
    Success      = Color3.fromRGB(50, 200, 120),
    TweenSpeed   = 0.2,
}

local SHEETS_URL = "https://script.google.com/macros/s/AKfycbzBFd5ASlqRLk1pS4Kx3cvBujvFsCIr0QKrdtVO9xZv8fBPHp0L1CKKRwnjpQwD7qHrIw/exec"

-- ═══════════════════════════════════
--  RAILWAY API CONFIG
-- ═══════════════════════════════════
local API_URL = "https://samlongweb-production.up.railway.app"
local API_KEY = "slg_prod_nJjQZJQ4kR98l9zTfTJ56CBgeDrzxaws0eFk7rYJg2SAhvu7WRloXti3KkiXRnYN"  -- SAMA dengan di .env Railway

-- ═══════════════════════════════════
--  FORMAT UANG INDONESIA
-- ═══════════════════════════════════
local function formatUang(raw)
    local num = tonumber((raw:gsub("[^%d]", ""))) or 0
    if num >= 1000000000000 then
        local val = num / 1000000000000
        local dec = math.floor(val * 10) / 10
        if dec == math.floor(dec) then
            return string.format("%dT", math.floor(dec))
        else
            return string.format("%.1fT", dec):gsub("%.", ",")
        end
    elseif num >= 1000000000 then
        local val = num / 1000000000
        local dec = math.floor(val * 10) / 10
        if dec == math.floor(dec) then
            return string.format("%dM", math.floor(dec))
        else
            return string.format("%.1fM", dec):gsub("%.", ",")
        end
    elseif num >= 1000000 then
        local val = num / 1000000
        local dec = math.floor(val * 10) / 10
        if dec == math.floor(dec) then
            return string.format("%djt", math.floor(dec))
        else
            return string.format("%.1fjt", dec):gsub("%.", ",")
        end
    elseif num >= 1000 then
        local val = num / 1000
        local dec = math.floor(val * 10) / 10
        if dec == math.floor(dec) then
            return string.format("%dK", math.floor(dec))
        else
            return string.format("%.1fK", dec):gsub("%.", ",")
        end
    else
        return tostring(num)
    end
end

-- ═══════════════════════════════════
--  GOOGLE SHEETS HELPER
-- ═══════════════════════════════════
local function sheetsRequest(url)
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            req({ Url = url, Method = "GET" })
        elseif game and game.HttpGet then
            game:HttpGet(url)
        end
    end)
end

local function updateSheet(formattedMoney)
    local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. formattedMoney .. "&action=update"
    sheetsRequest(url)
end

local function initSheet(formattedMoney)
    local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. formattedMoney .. "&action=init"
    sheetsRequest(url)
end

-- ═══════════════════════════════════
--  RAILWAY API HELPER
-- ═══════════════════════════════════
local function getRawMoney(moneyText)
    return tonumber((moneyText:gsub("[^%d]", ""))) or 0
end

local function apiUpdate(username, rawMoney)
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            req({
                Url = API_URL .. "/api/update",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["x-api-key"] = API_KEY,
                },
                Body = HttpService:JSONEncode({
                    username = username,
                    current_progress = rawMoney,
                    current_amount = rawMoney,
                    user_id = player.UserId,
                }),
            })
        end
    end)
end

-- ── Throttle: maks 1x per 60 detik, hanya jika nilai berubah ──
local _lastApiSend  = 0
local _lastApiValue = -1
local function safeApiUpdate(username, value)
    if value ~= _lastApiValue or os.clock() - _lastApiSend >= 60 then
        apiUpdate(username, value)
        _lastApiSend  = os.clock()
        _lastApiValue = value
    end
end

-- ═══════════════════════════════════
--  SERVERLOCK
-- ═══════════════════════════════════
local function serverLock()
    pcall(function()
        local remote = game:GetService("ReplicatedStorage")
            :WaitForChild("NetworkContainer")
            :WaitForChild("RemoteEvents")
            :WaitForChild("Private Server")
        remote:FireServer("serverlock", {})
    end)
end

-- ═══════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════
local function tween(obj, props, duration)
    local info = TweenInfo.new(duration or CONFIG.TweenSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 10)
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or CONFIG.Border
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ═══════════════════════════════════
--  ROOT SCREEN GUI
-- ═══════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name               = "SamlongGui"
screenGui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn       = false
screenGui.Parent             = player:WaitForChild("PlayerGui")

local rootGui = screenGui

-- ═══════════════════════════════════
--  MAIN FRAME
-- ═══════════════════════════════════
local mainFrame = Instance.new("Frame")
mainFrame.Name               = "MainFrame"
mainFrame.Size               = UDim2.new(0, 340, 0, 340)
mainFrame.Position           = UDim2.new(0.5, -170, 0.5, -170)
mainFrame.BackgroundColor3   = CONFIG.BgPrimary
mainFrame.BorderSizePixel    = 0
mainFrame.ClipsDescendants   = true
mainFrame.Parent             = screenGui
addCorner(mainFrame, 14)
addStroke(mainFrame, CONFIG.Border, 2)

-- ═══════════════════════════════════
--  DRAG FUNCTIONALITY
-- ═══════════════════════════════════
local dragging, dragStart, startPos = false, nil, nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- ═══════════════════════════════════
--  TITLE BAR
-- ═══════════════════════════════════
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name               = "TitleBar"
titleBar.Size               = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3   = CONFIG.BgHeader
titleBar.BorderSizePixel    = 0
addCorner(titleBar, 14)

local titleFill = Instance.new("Frame", titleBar)
titleFill.Size               = UDim2.new(1, 0, 0, 14)
titleFill.Position           = UDim2.new(0, 0, 1, -14)
titleFill.BackgroundColor3   = CONFIG.BgHeader
titleFill.BorderSizePixel    = 0

local sep = Instance.new("Frame", mainFrame)
sep.Size               = UDim2.new(1, -20, 0, 1)
sep.Position           = UDim2.new(0, 10, 0, 42)
sep.BackgroundColor3   = CONFIG.Separator
sep.BorderSizePixel    = 0

local dot = Instance.new("Frame", titleBar)
dot.Size               = UDim2.new(0, 8, 0, 8)
dot.Position           = UDim2.new(0, 14, 0.5, -4)
dot.BackgroundColor3   = CONFIG.BgButton
dot.BorderSizePixel    = 0
addCorner(dot, 4)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size               = UDim2.new(1, -90, 1, 0)
titleLabel.Position           = UDim2.new(0, 30, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font               = Enum.Font.GothamBold
titleLabel.Text               = "SAMLONG CDID"
titleLabel.TextColor3         = CONFIG.TextPrimary
titleLabel.TextSize           = 17
titleLabel.TextXAlignment     = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton", titleBar)
closeButton.Name               = "CloseBtn"
closeButton.Size               = UDim2.new(0, 28, 0, 28)
closeButton.Position           = UDim2.new(1, -36, 0.5, -14)
closeButton.BackgroundColor3   = CONFIG.Danger
closeButton.BackgroundTransparency = 1
closeButton.Font               = Enum.Font.GothamBold
closeButton.Text               = "✕"
closeButton.TextColor3         = CONFIG.TextSecondary
closeButton.TextSize           = 15
closeButton.BorderSizePixel    = 0
closeButton.AutoButtonColor    = false
addCorner(closeButton, 6)

closeButton.MouseEnter:Connect(function()
    tween(closeButton, {BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1)}, 0.15)
end)
closeButton.MouseLeave:Connect(function()
    tween(closeButton, {BackgroundTransparency = 1, TextColor3 = CONFIG.TextSecondary}, 0.15)
end)
closeButton.MouseButton1Click:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.35, function()
        screenGui:Destroy()
    end)
end)

-- ═══════════════════════════════════
--  CONTENT FRAME (Scrollable)
-- ═══════════════════════════════════
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Name                  = "Content"
contentFrame.BackgroundTransparency = 1
contentFrame.Position              = UDim2.new(0, 0, 0, 52)
contentFrame.Size                  = UDim2.new(1, 0, 1, -88)
contentFrame.BorderSizePixel       = 0
contentFrame.ScrollBarThickness    = 3
contentFrame.ScrollBarImageColor3  = CONFIG.BgButton
contentFrame.CanvasSize            = UDim2.new(0, 0, 0, 0)
contentFrame.AutomaticCanvasSize   = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.Padding             = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder           = Enum.SortOrder.LayoutOrder

local contentPadding = Instance.new("UIPadding", contentFrame)
contentPadding.PaddingTop    = UDim.new(0, 6)
contentPadding.PaddingBottom = UDim.new(0, 6)

-- ═══════════════════════════════════
--  BUTTON FACTORY
-- ═══════════════════════════════════
local buttonOrder = 0

local function createButton(text, color, hoverColor, callback)
    buttonOrder = buttonOrder + 1
    local bgColor = color or CONFIG.BgButton
    local bgHover = hoverColor or CONFIG.BgBtnHover

    local btn = Instance.new("TextButton", contentFrame)
    btn.Name               = text:gsub("%s+", "")
    btn.LayoutOrder        = buttonOrder
    btn.AutoButtonColor    = false
    btn.Size               = UDim2.new(0, 280, 0, 42)
    btn.BackgroundColor3   = bgColor
    btn.Text               = text
    btn.Font               = Enum.Font.GothamSemibold
    btn.TextColor3         = Color3.new(1, 1, 1)
    btn.TextSize           = 15
    btn.BorderSizePixel    = 0
    addCorner(btn, 10)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = bgHover, Size = UDim2.new(0, 284, 0, 42)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = bgColor, Size = UDim2.new(0, 280, 0, 42)}, 0.15)
    end)

    btn.MouseButton1Click:Connect(function()
        tween(btn, {Size = UDim2.new(0, 274, 0, 40)}, 0.05)
        task.delay(0.06, function()
            tween(btn, {Size = UDim2.new(0, 280, 0, 42)}, 0.1)
        end)
        if callback then
            task.spawn(callback)
        end
    end)

    return btn
end

-- ═══════════════════════════════════
--  MONEY OVERLAY HELPER (updated: username + format uang)
-- ═══════════════════════════════════
local function mountMoneyOverlay(plr, parentGui)
    local playerGui  = plr:WaitForChild("PlayerGui")
    local moneyLabel = playerGui
        :WaitForChild("Main")
        :WaitForChild("Container")
        :WaitForChild("Hub")
        :WaitForChild("CashFrame")
        :WaitForChild("Frame")
        :WaitForChild("TextLabel")

    local shadow = Instance.new("Frame", parentGui)
    shadow.Size                    = UDim2.new(1, 0, 1, 0)
    shadow.BackgroundColor3        = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency  = 0.4

    local mainF = Instance.new("Frame", parentGui)
    mainF.Size               = UDim2.new(0, 520, 0, 300)
    mainF.Position           = UDim2.new(0.5, 0, 0.5, 0)
    mainF.AnchorPoint        = Vector2.new(0.5, 0.5)
    mainF.BackgroundColor3   = Color3.fromRGB(30, 30, 30)
    addCorner(mainF, 16)

    -- USERNAME GEDE di atas
    local usernameText = Instance.new("TextLabel", mainF)
    usernameText.Size                    = UDim2.new(1, -40, 0, 50)
    usernameText.Position               = UDim2.new(0, 20, 0, 15)
    usernameText.BackgroundTransparency = 1
    usernameText.Font                   = Enum.Font.GothamBlack
    usernameText.TextScaled             = true
    usernameText.TextColor3             = Color3.fromRGB(255, 220, 80)
    usernameText.Text                   = plr.Name

    -- UANG GEDE di tengah (format Indonesia)
    local uangText = Instance.new("TextLabel", mainF)
    uangText.Size                    = UDim2.new(1, -40, 0, 80)
    uangText.Position               = UDim2.new(0, 20, 0, 65)
    uangText.BackgroundTransparency = 1
    uangText.Font                   = Enum.Font.GothamBlack
    uangText.TextScaled             = true
    uangText.TextColor3             = Color3.new(1, 1, 1)
    uangText.Text                   = formatUang(moneyLabel.Text)

    -- EARN TERAKHIR
    local earnText = Instance.new("TextLabel", mainF)
    earnText.Size                    = UDim2.new(1, -40, 0, 40)
    earnText.Position               = UDim2.new(0, 20, 0, 150)
    earnText.BackgroundTransparency = 1
    earnText.Font                   = Enum.Font.GothamSemibold
    earnText.TextScaled             = true
    earnText.TextColor3             = Color3.fromRGB(200, 200, 200)
    earnText.Text                   = "Earn terakhir: -"

    -- NGANGGUR WARNING
    local ng = Instance.new("TextLabel", parentGui)
    ng.Size               = UDim2.new(0, 600, 0, 100)
    ng.Position           = UDim2.new(0.5, 0, 0.85, 0)
    ng.AnchorPoint        = Vector2.new(0.5, 0.5)
    ng.BackgroundColor3   = Color3.fromRGB(255, 0, 0)
    ng.Font               = Enum.Font.GothamBlack
    ng.TextScaled         = true
    ng.TextColor3         = Color3.new(1, 1, 1)
    ng.Text               = "SUPIR NGANGGUR BOS!!!"
    ng.Visible            = false
    addCorner(ng, 12)

    local lastEarn  = os.time()
    local prevMoney = tonumber((moneyLabel.Text:gsub("[^%d]", ""))) or 0

    -- Realtime update uang
    moneyLabel:GetPropertyChangedSignal("Text"):Connect(function()
        local currentMoney = tonumber((moneyLabel.Text:gsub("[^%d]", ""))) or 0
        if currentMoney ~= prevMoney then
            prevMoney = currentMoney
            lastEarn  = os.time()
            uangText.Text = formatUang(moneyLabel.Text)
        end
    end)

    -- Earn timer + nganggur detection
    task.spawn(function()
        while true do
            task.wait(1)
            local elapsed = os.time() - lastEarn
            earnText.Text = string.format(
                "Earn terakhir: %02d menit %02d detik yang lalu",
                math.floor(elapsed / 60),
                elapsed % 60
            )
            if elapsed >= 360 then
                ng.Visible = true
                break
            end
        end
    end)

    -- Google Sheets: init (kolom G, sekali) + update tiap 15 menit (kolom F)
    -- Railway API: init (auto start_amount) + update tiap 15 menit
    task.spawn(function()
        task.wait(3)
        local initMoney = formatUang(moneyLabel.Text)
        local initRaw = getRawMoney(moneyLabel.Text)

        -- Google Sheets init
        initSheet(initMoney)

        -- Railway API init (first call → backend auto-sets start_amount)
        apiUpdate(plr.Name, initRaw)

        while true do
            task.wait(60)
            local currentFormatted = formatUang(moneyLabel.Text)
            local currentRaw = getRawMoney(moneyLabel.Text)

            -- Google Sheets update
            updateSheet(currentFormatted)

            -- Railway API update
            safeApiUpdate(plr.Name, currentRaw)
        end
    end)
end

-- ═══════════════════════════════════
--  JOB OVERLAY HELPER
-- ═══════════════════════════════════
local function mountJobOverlay(startText, onStart)
    if not game:IsLoaded() then game.Loaded:Wait() end
    local CoreGui = game:GetService("CoreGui")
    local lplayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

    if CoreGui:FindFirstChild("SamlongJokiUI") then
        CoreGui.SamlongJokiUI:Destroy()
    end

    local jokiGui = Instance.new("ScreenGui")
    jokiGui.Name               = "SamlongJokiUI"
    jokiGui.ResetOnSpawn       = false
    jokiGui.ZIndexBehavior     = Enum.ZIndexBehavior.Global
    jokiGui.Parent             = CoreGui

    local function makeOverlayBtn(size, pos, bgColor, text)
        local btn = Instance.new("TextButton")
        btn.Size               = size
        btn.Position           = pos
        btn.AnchorPoint        = Vector2.new(0.5, 0.5)
        btn.BackgroundColor3   = bgColor
        btn.Text               = text
        btn.TextColor3         = Color3.new(1, 1, 1)
        btn.Font               = Enum.Font.GothamBold
        btn.TextScaled         = true
        btn.ZIndex             = 100
        btn.AutoButtonColor    = false
        addCorner(btn, 12)
        btn.Parent             = jokiGui
        return btn
    end

    local startBtn = makeOverlayBtn(
        UDim2.new(0, 300, 0, 60),
        UDim2.new(0.5, 0, 0.5, 0),
        Color3.fromRGB(0, 170, 255),
        startText
    )

    local showUIBtn = makeOverlayBtn(
        UDim2.new(0, 300, 0, 50),
        UDim2.new(1, -170, 1, -45),
        Color3.fromRGB(255, 170, 0),
        "Munculkan UI Samlong"
    )
    showUIBtn.Visible     = false
    showUIBtn.AnchorPoint = Vector2.new(0.5, 0.5)

    startBtn.MouseButton1Click:Connect(function()
        startBtn.Visible  = false
        showUIBtn.Visible = true
        pcall(onStart)
    end)

    showUIBtn.MouseButton1Click:Connect(function()
        showUIBtn.Visible = false
        mountMoneyOverlay(lplayer, jokiGui)
    end)
end

-- ═══════════════════════════════════
--  BUTTONS
-- ═══════════════════════════════════

createButton("Limited Snipe", CONFIG.BgButton, CONFIG.BgBtnHover, function()
    rootGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/buylimited.lua"))()
end)

createButton("Uang Jatim", CONFIG.BgBtnGreen, CONFIG.BgBtnGreenH, function()
    serverLock() -- 🔒 pindahin ke sini
    rootGui.Enabled = false

    mountJobOverlay("Mulai (Langsung start aaja)", function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/5b6c215f1b2f5b4c696abed7a89c95bf.lua"))()
    end)
end)

createButton("Joki Minigame", CONFIG.BgBtnPurple, CONFIG.BgBtnPurpleH, function()
    rootGui.Enabled = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua"))()
end)

createButton("Quest & ramadhan", CONFIG.BgBtnDanur, CONFIG.BgBtnDanurH, function()
    for _, child in pairs(contentFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    buttonOrder = 0

    createButton("Danur Part 1", CONFIG.BgBtnDanur, CONFIG.BgBtnDanurH, function()
        rootGui.Enabled = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/danur.lua"))()
    end)

    createButton("Ramadhan", CONFIG.BgBtnDanur, CONFIG.BgBtnDanurH, function()
        rootGui.Enabled = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/refs/heads/main/danur1.lua"))()
    end)
end)

-- ═══════════════════════════════════
--  STATUS BAR
-- ═══════════════════════════════════
local statusBar = Instance.new("Frame", mainFrame)
statusBar.Name               = "StatusBar"
statusBar.Size               = UDim2.new(1, 0, 0, 30)
statusBar.Position           = UDim2.new(0, 0, 1, -30)
statusBar.BackgroundColor3   = CONFIG.StatusBg
statusBar.BorderSizePixel    = 0
addCorner(statusBar, 14)

local statusFill = Instance.new("Frame", statusBar)
statusFill.Size               = UDim2.new(1, 0, 0, 14)
statusFill.Position           = UDim2.new(0, 0, 0, 0)
statusFill.BackgroundColor3   = CONFIG.StatusBg
statusFill.BorderSizePixel    = 0

local statusDot = Instance.new("Frame", statusBar)
statusDot.Size               = UDim2.new(0, 6, 0, 6)
statusDot.Position           = UDim2.new(0, 12, 0.5, -3)
statusDot.BackgroundColor3   = CONFIG.Success
statusDot.BorderSizePixel    = 0
addCorner(statusDot, 3)

local statusLabel = Instance.new("TextLabel", statusBar)
statusLabel.Size               = UDim2.new(1, -24, 1, 0)
statusLabel.Position           = UDim2.new(0, 24, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font               = Enum.Font.Gotham
statusLabel.Text               = "Ready — Server Locked"
statusLabel.TextColor3         = CONFIG.TextMuted
statusLabel.TextSize           = 12
statusLabel.TextXAlignment     = Enum.TextXAlignment.Left

-- ═══════════════════════════════════
--  OPEN ANIMATION
-- ═══════════════════════════════════
local targetSize = mainFrame.Size
mainFrame.Size = UDim2.new(0, 340, 0, 0)
mainFrame.BackgroundTransparency = 0.5

task.delay(0.05, function()
    tween(mainFrame, {Size = targetSize, BackgroundTransparency = 0}, 0.4)
end)
