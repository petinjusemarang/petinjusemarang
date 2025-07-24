-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local guiService = player:WaitForChild("PlayerGui")

-- Remote and path
local sellRemote = ReplicatedStorage:WaitForChild("NetworkContainer"):WaitForChild("RemoteEvents"):WaitForChild("EventSellShop")
local sellFolder = guiService:WaitForChild("Event"):WaitForChild("Shop"):WaitForChild("Main"):WaitForChild("Sell")
local headerText = guiService:WaitForChild("Event"):WaitForChild("Shop"):WaitForChild("Frame"):WaitForChild("HeaderText")

-- Daftar item pancingan
local validItems = { "Bumper", "Door", "ShadAxe", "ShadHat", "Tire" }

-- Hapus GUI lama
if guiService:FindFirstChild("FishingPointDisplay") then
    guiService.FishingPointDisplay:Destroy()
end

-- Buat GUI utama
local screenGui = Instance.new("ScreenGui", guiService)
screenGui.Name = "FishingPointDisplay"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Tombol START
local startBtn = Instance.new("TextButton", screenGui)
startBtn.Size = UDim2.new(0,250,0,70)
startBtn.Position = UDim2.new(0.5,-125,0.45,0)
startBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBlack
startBtn.TextSize = 28
startBtn.Text = "🎣 CLICK TO START"
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,12)
startBtn.ZIndex = 5

-- Frame untuk point dan waktu terakhir
local bgFrame = Instance.new("Frame", screenGui)
bgFrame.Size = UDim2.new(0,500,0,160)
bgFrame.Position = UDim2.new(0.5,-250,0.5,-80)
bgFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
bgFrame.BackgroundTransparency = 0.2
bgFrame.BorderSizePixel = 0
Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0,20)
bgFrame.ZIndex = 1

-- Label Fishing Points
local pointText = Instance.new("TextLabel", bgFrame)
pointText.Size = UDim2.new(1,0,0,80)
pointText.Position = UDim2.new(0,0,0,0)
pointText.BackgroundTransparency = 1
pointText.TextColor3 = Color3.new(1,1,1)
pointText.Font = Enum.Font.GothamBlack
pointText.TextScaled = true
pointText.Text = "🎣 Fishing Points: ?"
pointText.ZIndex = 5

-- Label Last Catch Time
local lastCatchText = Instance.new("TextLabel", bgFrame)
lastCatchText.Size = UDim2.new(1,0,0,40)
lastCatchText.Position = UDim2.new(0,0,0,80)
lastCatchText.BackgroundTransparency = 1
lastCatchText.TextColor3 = Color3.new(1,1,1)
lastCatchText.Font = Enum.Font.GothamBlack
lastCatchText.TextScaled = true
lastCatchText.Text = "Last Catch: --"
lastCatchText.ZIndex = 5

-- Popup idle
local popup = Instance.new("TextLabel", screenGui)
popup.Size = UDim2.new(0,600,0,150)
popup.Position = UDim2.new(0.5,-300,0.3,0)
popup.BackgroundColor3 = Color3.fromRGB(255,0,0)
popup.TextColor3 = Color3.new(1,1,1)
popup.Font = Enum.Font.GothamBlack
popup.TextSize = 30
popup.TextWrapped = true
popup.Visible = false
popup.ZIndex = 20
Instance.new("UICorner", popup).CornerRadius = UDim.new(0,20)

-- Variabel status
local lastPoint = ""
local lastCatchTime = 0

-- Fungsi update poin
local function updatePoints()
    if headerText and headerText.Text then
        local raw = headerText.Text
        local point = raw:gsub("%D", "")
        if point ~= "" then
            if point ~= lastPoint then
                lastPoint = point
                lastCatchTime = tick()
            end
            pointText.Text = "🎣 Fishing Points: " .. point
        end
    end
end

-- Mulai loop auto-sell & update
local function startLoop()
    task.spawn(function()
        while true do
            -- Auto-sell
            for _, item in pairs(sellFolder:GetChildren()) do
                for _, valid in ipairs(validItems) do
                    if item.Name:lower() == valid:lower() then
                        pcall(function()
                            sellRemote:FireServer(item.Name)
                        end)
                        task.wait(0.2)
                        break
                    end
                end
            end

            -- Update poin & waktu terakhir
            updatePoints()
            local elapsed = tick() - lastCatchTime
            local menit = math.floor(elapsed / 60)
            local detik = math.floor(elapsed % 60)
            lastCatchText.Text = string.format("Last Catch: %d m %d s ago", menit, detik)

            -- Tampilkan popup jika >=10 menit
            if elapsed >= 600 and not popup.Visible then
                popup.Text = string.format("🎣 PEMANCING NGANGGUR!\nTerakhir dapet ikan: %d m %d s lalu", menit, detik)
                popup.Visible = true
            end
            task.wait(1)
        end
    end)
end

-- Koneksi tombol START
startBtn.MouseButton1Click:Connect(function()
    startBtn:Destroy()
    -- Load script fishing
    loadstring(game:HttpGet("https://raw.githubusercontent.com/itsMeArul/QuaHUB/refs/heads/main/cdidfishing.lua"))()
    lastCatchTime = tick()
    startLoop()
end)
