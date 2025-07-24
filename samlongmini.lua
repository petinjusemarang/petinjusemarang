-- GUI FUTURISTIK SAMLONG - RESET WAKTU SAAT POINT BERUBAH + ROBUST STUCK DETECTION
local player = game.Players.LocalPlayer
local rp = game:GetService("ReplicatedStorage")
local coreGui = game:GetService("CoreGui")

-- Hapus GUI lama
if coreGui:FindFirstChild("SamlongGUI") then
    coreGui.SamlongGUI:Destroy()
end

-- Buat GUI baru
local gui = Instance.new("ScreenGui", coreGui)
gui.Name = "SamlongGUI"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(1,0,1,0)
mainFrame.BackgroundTransparency = 1

-- BUY AVANZA BUTTON
local buyBtn = Instance.new("TextButton", mainFrame)
buyBtn.Size = UDim2.new(0,180,0,40)
buyBtn.Position = UDim2.new(0.75,0,0,30)
buyBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 18
buyBtn.TextColor3 = Color3.new(1,1,1)
buyBtn.Text = "BUY AVANZA"
buyBtn.BorderSizePixel = 0
buyBtn.AutoButtonColor = true

-- NOTIFIKASI "UANG KURANG"
local notif = Instance.new("TextLabel", mainFrame)
notif.Size = UDim2.new(1,0,0,30)
notif.Position = UDim2.new(0,0,0,10)
notif.BackgroundTransparency = 1
notif.Font = Enum.Font.GothamBold
notif.TextSize = 18
notif.TextColor3 = Color3.fromRGB(255,70,70)
notif.TextStrokeTransparency = 0.5
notif.TextStrokeColor3 = Color3.new(0,0,0)
notif.TextWrapped = true
notif.TextXAlignment = Enum.TextXAlignment.Center
notif.Text = ""

-- POINT BOX
local pointBG = Instance.new("Frame", mainFrame)
pointBG.Size = UDim2.new(0,420,0,160)
pointBG.Position = UDim2.new(0.5,-210,0.4,-80)
pointBG.BackgroundColor3 = Color3.new(0,0,0)
pointBG.BackgroundTransparency = 0.2
pointBG.BorderSizePixel = 0

local pointLabel = Instance.new("TextLabel", pointBG)
pointLabel.Size = UDim2.new(1,0,1,0)
pointLabel.BackgroundTransparency = 1
pointLabel.Font = Enum.Font.GothamBlack
pointLabel.TextScaled = true
pointLabel.TextColor3 = Color3.new(1,1,1)
pointLabel.TextStrokeTransparency = 0.3
pointLabel.TextStrokeColor3 = Color3.new(0,0,0)
pointLabel.Text = "..."

-- LAST MINIGAME TIME
local lastPlayedLabel = Instance.new("TextLabel", pointBG)
lastPlayedLabel.Size = UDim2.new(1,0,0,30)
lastPlayedLabel.Position = UDim2.new(0,0,1,-35)
lastPlayedLabel.BackgroundTransparency = 1
lastPlayedLabel.Font = Enum.Font.Gotham
lastPlayedLabel.TextSize = 16
lastPlayedLabel.TextColor3 = Color3.fromRGB(200,200,200)
lastPlayedLabel.TextStrokeTransparency = 0.5
lastPlayedLabel.TextStrokeColor3 = Color3.new(0,0,0)
lastPlayedLabel.Text = "Last: N/A"

-- BOTTOM BANNER: JUMP / NOJUMP / LABEL
local banner = Instance.new("Frame", mainFrame)
banner.Size = UDim2.new(1,0,0,70)
banner.Position = UDim2.new(0,0,1,-70)
banner.BackgroundColor3 = Color3.new(0,0,0)
banner.BorderSizePixel = 0

local jump = Instance.new("TextButton", banner)
jump.Size = UDim2.new(0.3,0,1,-10)
jump.Position = UDim2.new(0.05,0,0,5)
jump.Font = Enum.Font.GothamBold
jump.TextSize = 20
jump.BackgroundColor3 = Color3.fromRGB(40,180,90)
jump.TextColor3 = Color3.new(1,1,1)
jump.Text = "JUMP"
jump.BorderSizePixel = 0
jump.TextStrokeTransparency = 0.3
jump.TextStrokeColor3 = Color3.new(0,0,0)

local nojump = Instance.new("TextButton", banner)
nojump.Size = UDim2.new(0.3,0,1,-10)
nojump.Position = UDim2.new(0.65,0,0,5)
nojump.Font = Enum.Font.GothamBold
nojump.TextSize = 20
nojump.BackgroundColor3 = Color3.fromRGB(255,90,70)
nojump.TextColor3 = Color3.new(1,1,1)
nojump.Text = "NOJUMP"
nojump.BorderSizePixel = 0
nojump.TextStrokeTransparency = 0.3
nojump.TextStrokeColor3 = Color3.new(0,0,0)

local labelMid = Instance.new("TextLabel", banner)
labelMid.Size = UDim2.new(0.3,0,1,0)
labelMid.Position = UDim2.new(0.35,0,0,0)
labelMid.BackgroundTransparency = 1
labelMid.Font = Enum.Font.GothamBold
labelMid.TextSize = 18
labelMid.TextColor3 = Color3.new(1,1,1)
labelMid.TextStrokeTransparency = 0.3
labelMid.TextStrokeColor3 = Color3.new(0,0,0)
labelMid.Text = "SAMLONG ANTI 02"

-- POPUP FRAME & CONTENT
local popupFrame = Instance.new("Frame", mainFrame)
popupFrame.Size = UDim2.new(0.8,0,0.4,0)
popupFrame.Position = UDim2.new(0.1,0,0.3,0)
popupFrame.BackgroundColor3 = Color3.fromRGB(255,30,30)
popupFrame.BorderSizePixel = 0
popupFrame.ZIndex = 1000
popupFrame.Visible = false

local popupText = Instance.new("TextLabel", popupFrame)
popupText.Size = UDim2.new(1,0,0.7,0)
popupText.Position = UDim2.new(0,0,0,0)
popupText.BackgroundTransparency = 1
popupText.Font = Enum.Font.GothamBlack
popupText.TextScaled = true
popupText.TextColor3 = Color3.new(1,1,1)
popupText.TextStrokeTransparency = 0.2
popupText.TextStrokeColor3 = Color3.new(0,0,0)
popupText.Text = "🚨 STUCK YA ALLAHH 🚨"
popupText.ZIndex = 1001

local okBtn = Instance.new("TextButton", popupFrame)
okBtn.Size = UDim2.new(0,120,0,50)
okBtn.Position = UDim2.new(0.5,-60,0.75,0)
okBtn.Font = Enum.Font.GothamBold
okBtn.TextSize = 22
okBtn.Text = "OK"
okBtn.BackgroundColor3 = Color3.new(1,1,1)
okBtn.TextColor3 = Color3.new(0,0,0)
okBtn.BorderSizePixel = 0
okBtn.ZIndex = 1001
okBtn.Visible = false

-- TIME VARIABLES
local lastPlayTime     = os.time()
local lastValChange    = os.time()
local alerted          = false
local STUCK_THRESHOLD  = 600  -- detik

-- FUNCTIONS
local function updateLastPlayed()
    local diff = os.difftime(os.time(), lastPlayTime)
    local m = math.floor(diff/60)
    local s = diff%60
    lastPlayedLabel.Text = string.format("Last: %dm %ds", m, s)
end

local function updatePoint()
    for _=1,10 do
        local guiInst = player:FindFirstChild("PlayerGui")
        local label = guiInst
            and guiInst:FindFirstChild("BoxShop")
            and guiInst.BoxShop:FindFirstChild("Container")
            and guiInst.BoxShop.Container:FindFirstChild("Box")
            and guiInst.BoxShop.Container.Box:FindFirstChild("MinigamePoint")
        if label and label:IsA("TextLabel") then
            local function refresh()
                local val = label.Text:match("%d+") or "0"
                if val ~= pointLabel.Text then
                    lastPlayTime = os.time()
                    lastValChange = os.time()
                    alerted = false
                end
                pointLabel.Text = val
            end
            refresh()
            label:GetPropertyChangedSignal("Text"):Connect(refresh)
            return
        end
        task.wait(1)
    end
    pointLabel.Text = "0"
end

-- BUY AVANZA CONNECT
buyBtn.MouseButton1Click:Connect(function()
    local cashText = player.PlayerGui:FindFirstChild("Main")
        and player.PlayerGui.Main:FindFirstChild("Container")
        and player.PlayerGui.Main.Container:FindFirstChild("Hub")
        and player.PlayerGui.Main.Container.Hub:FindFirstChild("CashFrame")
        and player.PlayerGui.Main.Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")
    if not cashText then return end
    local uang = tonumber(cashText.Text:gsub("%D","")) or 0
    if uang >= 232850000 then
        rp.NetworkContainer.RemoteFunctions.Dealership:InvokeServer("Buy","2021Avanza15CVT","White","Toyota")
    else
        notif.Text = "😔 YA ALLAH UANG KURANG BOOS 💸"
        task.delay(3, function() notif.Text = "" end)
    end
end)

-- JUMP / NOJUMP
jump.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/jump.lua"
    ))()
end)
nojump.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet(
      "https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/nojump.lua"
    ))()
end)

-- OK BUTTON: hide popup & restart freeze timer
okBtn.MouseButton1Click:Connect(function()
    popupFrame.Visible = false
    okBtn.Visible     = false
    lastValChange     = os.time()
    lastPlayedLabel.Text = "Last: 0m 0s"
end)

-- SPAWN LOOPS
task.spawn(updatePoint)
task.spawn(function()
    while true do
        updateLastPlayed()
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        -- jika sudah lebih dari threshold dan belum pernah alert
        if not alerted and os.difftime(os.time(), lastValChange) >= STUCK_THRESHOLD then
            popupFrame.Visible = true
            okBtn.Visible     = true
            alerted           = true
        end
        task.wait(1)
    end
end)
