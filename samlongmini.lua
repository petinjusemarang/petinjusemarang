-- GUI FUTURISTIK SAMLONG - RESET WAKTU SAAT POINT BERUBAH + OK BUTTON RESET TIMER
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
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1

-- BUY AVANZA
local buyBtn = Instance.new("TextButton", mainFrame)
buyBtn.Size = UDim2.new(0, 180, 0, 40)
buyBtn.Position = UDim2.new(0.75, 0, 0, 30)
buyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
buyBtn.Text = "BUY AVANZA"
buyBtn.TextColor3 = Color3.new(1, 1, 1)
buyBtn.Font = Enum.Font.GothamBold
buyBtn.TextSize = 18
buyBtn.BorderSizePixel = 0
buyBtn.AutoButtonColor = true

-- Notifikasi Uang Kurang
local notif = Instance.new("TextLabel", mainFrame)
notif.Size = UDim2.new(1, 0, 0, 30)
notif.Position = UDim2.new(0, 0, 0, 10)
notif.BackgroundTransparency = 1
notif.Text = ""
notif.TextColor3 = Color3.fromRGB(255, 70, 70)
notif.TextSize = 18
notif.Font = Enum.Font.GothamBold
notif.TextStrokeTransparency = 0.5
notif.TextStrokeColor3 = Color3.new(0, 0, 0)
notif.TextWrapped = true
notif.TextXAlignment = Enum.TextXAlignment.Center

-- Point Box
local pointBG = Instance.new("Frame", mainFrame)
pointBG.Size = UDim2.new(0, 420, 0, 160)
pointBG.Position = UDim2.new(0.5, -210, 0.4, -80)
pointBG.BackgroundColor3 = Color3.new(0, 0, 0)
pointBG.BackgroundTransparency = 0.2
pointBG.BorderSizePixel = 0

local pointLabel = Instance.new("TextLabel", pointBG)
pointLabel.Size = UDim2.new(1, 0, 1, 0)
pointLabel.BackgroundTransparency = 1
pointLabel.TextColor3 = Color3.new(1, 1, 1)
pointLabel.Font = Enum.Font.GothamBlack
pointLabel.TextScaled = true
pointLabel.Text = "..."
pointLabel.TextStrokeTransparency = 0.3
pointLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

-- Last Minigame Time
local lastPlayedLabel = Instance.new("TextLabel", pointBG)
lastPlayedLabel.Size = UDim2.new(1, 0, 0, 30)
lastPlayedLabel.Position = UDim2.new(0, 0, 1, -35)
lastPlayedLabel.BackgroundTransparency = 1
lastPlayedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
lastPlayedLabel.Font = Enum.Font.Gotham
lastPlayedLabel.TextSize = 16
lastPlayedLabel.Text = "Last: N/A"
lastPlayedLabel.TextStrokeTransparency = 0.5
lastPlayedLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

-- Banner bawah (JUMP / NOJUMP / Label)
local banner = Instance.new("Frame", mainFrame)
banner.Size = UDim2.new(1, 0, 0, 70)
banner.Position = UDim2.new(0, 0, 1, -70)
banner.BackgroundColor3 = Color3.new(0, 0, 0)
banner.BorderSizePixel = 0

local jump = Instance.new("TextButton", banner)
jump.Size = UDim2.new(0.3, 0, 1, -10)
jump.Position = UDim2.new(0.05, 0, 0, 5)
jump.Text = "JUMP"
jump.Font = Enum.Font.GothamBold
jump.TextSize = 20
jump.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
jump.TextColor3 = Color3.new(1, 1, 1)
jump.BorderSizePixel = 0
jump.TextStrokeTransparency = 0.3
jump.TextStrokeColor3 = Color3.new(0, 0, 0)

local nojump = Instance.new("TextButton", banner)
nojump.Size = UDim2.new(0.3, 0, 1, -10)
nojump.Position = UDim2.new(0.65, 0, 0, 5)
nojump.Text = "NOJUMP"
nojump.Font = Enum.Font.GothamBold
nojump.TextSize = 20
nojump.BackgroundColor3 = Color3.fromRGB(255, 90, 70)
nojump.TextColor3 = Color3.new(1, 1, 1)
nojump.BorderSizePixel = 0
nojump.TextStrokeTransparency = 0.3
nojump.TextStrokeColor3 = Color3.new(0, 0, 0)

local labelMid = Instance.new("TextLabel", banner)
labelMid.Size = UDim2.new(0.3, 0, 1, 0)
labelMid.Position = UDim2.new(0.35, 0, 0, 0)
labelMid.BackgroundTransparency = 1
labelMid.Text = "SAMLONG ANTI 02"
labelMid.Font = Enum.Font.GothamBold
labelMid.TextSize = 18
labelMid.TextColor3 = Color3.new(1, 1, 1)
labelMid.TextStrokeTransparency = 0.3
labelMid.TextStrokeColor3 = Color3.new(0, 0, 0)

-- POPUP ERROR
local popup = Instance.new("TextLabel", mainFrame)
popup.Size = UDim2.new(0.8, 0, 0.4, 0)
popup.Position = UDim2.new(0.1, 0, 0.3, 0)
popup.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
popup.Text = "🚨STUCK YAALLAHH🚨"
popup.TextColor3 = Color3.new(1, 1, 1)
popup.TextScaled = true
popup.Font = Enum.Font.GothamBlack
popup.Visible = false
popup.TextStrokeTransparency = 0.2
popup.TextStrokeColor3 = Color3.new(0, 0, 0)
popup.ZIndex = 999
popup.BorderSizePixel = 0

-- OK BUTTON di dalam popup
local okBtn = Instance.new("TextButton", popup)
okBtn.Size = UDim2.new(0, 120, 0, 50)
okBtn.Position = UDim2.new(0.5, -60, 0.8, 0)
okBtn.Text = "OK"
okBtn.Font = Enum.Font.GothamBold
okBtn.TextSize = 22
okBtn.BackgroundColor3 = Color3.new(1, 1, 1)
okBtn.TextColor3 = Color3.new(0, 0, 0)
okBtn.BorderSizePixel = 0
okBtn.ZIndex = 1000
okBtn.Visible = false

-- Variabel waktu
local lastPlayTime = os.time()
local lastPoint = nil
local pointUnchangedTime = 0

-- Fungsi updateLastPlayed
local function updateLastPlayed()
	local diff = os.difftime(os.time(), lastPlayTime)
	local minutes = math.floor(diff / 60)
	local seconds = diff % 60
	lastPlayedLabel.Text = string.format("Last: %dm %ds", minutes, seconds)
end

-- Fungsi updatePoint
local function updatePoint()
	local tries = 0
	while tries < 10 do
		local guiInst = player:FindFirstChild("PlayerGui")
		local label = guiInst and guiInst:FindFirstChild("BoxShop")
			and guiInst.BoxShop:FindFirstChild("Container")
			and guiInst.BoxShop.Container:FindFirstChild("Box")
			and guiInst.BoxShop.Container.Box:FindFirstChild("MinigamePoint")

		if label and label:IsA("TextLabel") then
			local function refresh()
				local val = label.Text:match("%d+") or "0"
				if val ~= pointLabel.Text then
					lastPlayTime = os.time()       -- RESET TIMER SAAT POIN BERUBAH
					pointUnchangedTime = 0        -- RESET COUNTER
				end
				pointLabel.Text = val
			end
			refresh()
			label:GetPropertyChangedSignal("Text"):Connect(refresh)
			return
		end
		tries += 1
		task.wait(1)
	end
	pointLabel.Text = "0"
end

-- Beli Avanza (sama dengan skrip kamu)
buyBtn.MouseButton1Click:Connect(function()
	local cashText = player.PlayerGui:FindFirstChild("Main")
		and player.PlayerGui.Main:FindFirstChild("Container")
		and player.PlayerGui.Main.Container:FindFirstChild("Hub")
		and player.PlayerGui.Main.Container.Hub:FindFirstChild("CashFrame")
		and player.PlayerGui.Main.Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")

	if not cashText then return end

	local uangStr = cashText.Text:gsub("RP", ""):gsub("%.", ""):gsub(",", ""):gsub(" ", "")
	local uang = tonumber(uangStr)

	if uang and uang >= 232850000 then
		local args = {"Buy", "2021Avanza15CVT", "White", "Toyota"}
		rp:WaitForChild("NetworkContainer")
		  :WaitForChild("RemoteFunctions")
		  :WaitForChild("Dealership")
		  :InvokeServer(unpack(args))
	else
		notif.Text = "😔 YAALLAH UANGE KURANG BOOS BOSS💸"
		task.delay(3, function() notif.Text = "" end)
	end
end)

-- JUMP / NOJUMP Buttons
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

-- OK Button: hide popup + reset timers
okBtn.MouseButton1Click:Connect(function()
	popup.Visible = false
	okBtn.Visible = false
	pointUnchangedTime = 0
	lastPlayTime = os.time()                    -- reset last-played timer
	lastPlayedLabel.Text = "Last: 0m 0s"        -- update display immediately
end)

-- Loop updatePoint & updateLastPlayed
task.spawn(updatePoint)
task.spawn(function()
	while true do
		updateLastPlayed()
		task.wait(1)
	end
end)

-- Deteksi poin stuck (>= 600 detik = 10 menit)
task.spawn(function()
	while true do
		if tonumber(pointLabel.Text) then
			if lastPoint == pointLabel.Text then
				pointUnchangedTime += 1
			else
				pointUnchangedTime = 0
				lastPoint = pointLabel.Text
			end

			if pointUnchangedTime >= 600 then
				popup.Visible = true
				okBtn.Visible = true
			end
		end
		task.wait(1)
	end
end)
