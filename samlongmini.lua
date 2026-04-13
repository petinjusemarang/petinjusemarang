-- GUI FUTURISTIK SAMLONG - RESET WAKTU SAAT POINT BERUBAH + ROBUST STUCK DETECTION + RESET TIMER PADA OK
-- Updated: Dual Google Sheets + Railway API
local player    = game.Players.LocalPlayer
local rp        = game:GetService("ReplicatedStorage")
local coreGui   = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- 🔥 GOOGLE SHEETS CONFIG
local SHEETS_URL = "https://script.google.com/macros/s/AKfycbzBFd5ASlqRLk1pS4Kx3cvBujvFsCIr0QKrdtVO9xZv8fBPHp0L1CKKRwnjpQwD7qHrIw/exec"

-- 🔥 RAILWAY API CONFIG
local API_URL = "https://samlongweb-production.up.railway.app"
local API_KEY = "slg_prod_nJjQZJQ4kR98l9zTfTJ56CBgeDrzxaws0eFk7rYJg2SAhvu7WRloXti3KkiXRnYN"  -- SAMA dengan di .env Railway

-- ═══════════════════════════════════
--  GOOGLE SHEETS HELPER
-- ═══════════════════════════════════
local function sheetsRequest(url)
	pcall(function()
		if syn and syn.request then
			syn.request({Url = url, Method = "GET"})
		elseif request then
			request({Url = url, Method = "GET"})
		elseif game.HttpGet then
			game:HttpGet(url)
		end
	end)
end

local function sendUpdate(points)
	local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. points .. "&action=update"
	print("SHEETS UPDATE:", url)
	sheetsRequest(url)
end

local function sendInit(points)
	local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. points .. "&action=init"
	print("SHEETS INIT:", url)
	sheetsRequest(url)
end

-- ═══════════════════════════════════
--  RAILWAY API HELPER
-- ═══════════════════════════════════

-- ═══════════════════════════════════
--  PRIVATE SERVER HELPERS (MINIGAME)
-- ═══════════════════════════════════
local psRemote = game:GetService("ReplicatedStorage")
	:WaitForChild("NetworkContainer")
	:WaitForChild("RemoteEvents")
	:WaitForChild("PrivateServer")

-- GET /api/private-server?username=xxx
local function apiGetPrivateServer(username)
	local result = nil
	pcall(function()
		local req = (syn and syn.request) or (http and http.request) or request
		if not req then return end
		local resp = req({
			Url = API_URL .. "/api/private-server?username=" .. HttpService:UrlEncode(username),
			Method = "GET",
			Headers = { ["x-api-key"] = API_KEY },
		})
		if resp and resp.StatusCode == 200 then
			local ok, data = pcall(function() return HttpService:JSONDecode(resp.Body) end)
			if ok then result = data end
		end
	end)
	return result
end

-- POST /api/private-server (backend ignores if code already set)
local function apiSetPrivateServer(username, serverCode, region)
	pcall(function()
		local req = (syn and syn.request) or (http and http.request) or request
		if not req then return end
		req({
			Url = API_URL .. "/api/private-server",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["x-api-key"] = API_KEY,
			},
			Body = HttpService:JSONEncode({
				username = username,
				server_code = serverCode,
				region = region or "Jakarta",
			}),
		})
		print("[PS] Server code dikirim ke API:", serverCode)
	end)
end

-- Ambil server label dari PlayerGui (muncul setelah Create)
local function waitForServerLabel()
	local label = nil
	pcall(function()
		label = player
			:WaitForChild("PlayerGui")
			:WaitForChild("Hub")
			:WaitForChild("Container")
			:WaitForChild("Window")
			:WaitForChild("PrivateServer")
			:WaitForChild("ServerLabel")
	end)
	if not label then return nil end
	-- tunggu sampai text terisi (max 15 detik)
	local t = 0
	while (label.Text == nil or label.Text == "") and t < 15 do
		task.wait(0.5)
		t = t + 0.5
	end
	return label.Text ~= "" and label.Text or nil
end

local function apiUpdate(username, rawPoints)
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
					current_progress = rawPoints,
					current_amount = rawPoints,
					user_id = player.UserId,
				}),
			})
			print("[API] Updated:", username, "points:", rawPoints)
		end
	end)
end

-- Hapus GUI lama
if coreGui:FindFirstChild("SamlongGUI") then
	coreGui.SamlongGUI:Destroy()
end

-- Buat GUI baru
local gui = Instance.new("ScreenGui", coreGui)
gui.Name = "SamlongGUI"
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size               = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1

-- BUY AVANZA BUTTON
local buyBtn = Instance.new("TextButton", mainFrame)
buyBtn.Size            = UDim2.new(0, 180, 0, 40)
buyBtn.Position        = UDim2.new(0.75, 0, 0, 30)
buyBtn.BackgroundColor3= Color3.fromRGB(30, 30, 30)
buyBtn.Font            = Enum.Font.GothamBold
buyBtn.TextSize        = 18
buyBtn.TextColor3      = Color3.new(1, 1, 1)
buyBtn.Text            = "BUY AVANZA"
buyBtn.BorderSizePixel = 0
buyBtn.AutoButtonColor = true

-- NOTIFIKASI "UANG KURANG"
local notif = Instance.new("TextLabel", mainFrame)
notif.Size               = UDim2.new(1, 0, 0, 30)
notif.Position           = UDim2.new(0, 0, 0, 10)
notif.BackgroundTransparency = 1
notif.Font               = Enum.Font.GothamBold
notif.TextSize           = 18
notif.TextColor3         = Color3.fromRGB(255, 70, 70)
notif.TextStrokeTransparency = 0.5
notif.TextStrokeColor3   = Color3.new(0, 0, 0)
notif.TextWrapped        = true
notif.TextXAlignment     = Enum.TextXAlignment.Center
notif.Text               = ""

-- POINT BOX
local pointBG = Instance.new("Frame", mainFrame)
pointBG.Size               = UDim2.new(0, 420, 0, 160)
pointBG.Position           = UDim2.new(0.5, -210, 0.4, -80)
pointBG.BackgroundColor3   = Color3.new(0, 0, 0)
pointBG.BackgroundTransparency = 0.2
pointBG.BorderSizePixel    = 0

local usernameLabel = Instance.new("TextLabel", pointBG)
usernameLabel.Size               = UDim2.new(1, 0, 0.3, 0)
usernameLabel.Position           = UDim2.new(0, 0, 0, 0)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Font               = Enum.Font.GothamBlack
usernameLabel.TextScaled         = true
usernameLabel.TextColor3         = Color3.fromRGB(255, 220, 80)
usernameLabel.TextStrokeTransparency = 0.3
usernameLabel.Text               = player.Name

local pointLabel = Instance.new("TextLabel", pointBG)
pointLabel.Size = UDim2.new(1, 0, 0.7, 0)
pointLabel.Position = UDim2.new(0, 0, 0.3, 0)
pointLabel.BackgroundTransparency = 1
pointLabel.Font               = Enum.Font.GothamBlack
pointLabel.TextScaled         = true
pointLabel.TextColor3         = Color3.new(1, 1, 1)
pointLabel.TextStrokeTransparency = 0.3
pointLabel.TextStrokeColor3   = Color3.new(0, 0, 0)
pointLabel.Text               = "..."

-- LAST MINIGAME TIME
local lastPlayedLabel = Instance.new("TextLabel", pointBG)
lastPlayedLabel.Size               = UDim2.new(1, 0, 0, 30)
lastPlayedLabel.Position           = UDim2.new(0, 0, 1, -35)
lastPlayedLabel.BackgroundTransparency = 1
lastPlayedLabel.Font               = Enum.Font.Gotham
lastPlayedLabel.TextSize           = 16
lastPlayedLabel.TextColor3         = Color3.fromRGB(200, 200, 200)
lastPlayedLabel.TextStrokeTransparency = 0.5
lastPlayedLabel.TextStrokeColor3   = Color3.new(0, 0, 0)
lastPlayedLabel.Text               = "Last: N/A"

-- BOTTOM BANNER: JUMP / NOJUMP / LABEL
local banner = Instance.new("Frame", mainFrame)
banner.Size               = UDim2.new(1, 0, 0, 70)
banner.Position           = UDim2.new(0, 0, 1, -70)
banner.BackgroundColor3   = Color3.new(0, 0, 0)
banner.BorderSizePixel    = 0

local jump = Instance.new("TextButton", banner)
jump.Size               = UDim2.new(0.3, 0, 1, -10)
jump.Position           = UDim2.new(0.05, 0, 0, 5)
jump.Font               = Enum.Font.GothamBold
jump.TextSize           = 20
jump.BackgroundColor3   = Color3.fromRGB(40, 180, 90)
jump.TextColor3         = Color3.new(1, 1, 1)
jump.Text               = "JUMP"
jump.BorderSizePixel    = 0
jump.TextStrokeTransparency = 0.3
jump.TextStrokeColor3   = Color3.new(0, 0, 0)

local nojump = Instance.new("TextButton", banner)
nojump.Size               = UDim2.new(0.3, 0, 1, -10)
nojump.Position           = UDim2.new(0.65, 0, 0, 5)
nojump.Font               = Enum.Font.GothamBold
nojump.TextSize           = 20
nojump.BackgroundColor3   = Color3.fromRGB(255, 90, 70)
nojump.TextColor3         = Color3.new(1, 1, 1)
nojump.Text               = "NOJUMP"
nojump.BorderSizePixel    = 0
nojump.TextStrokeTransparency = 0.3
nojump.TextStrokeColor3   = Color3.new(0, 0, 0)

local labelMid = Instance.new("TextLabel", banner)
labelMid.Size               = UDim2.new(0.3, 0, 1, 0)
labelMid.Position           = UDim2.new(0.35, 0, 0, 0)
labelMid.BackgroundTransparency = 1
labelMid.Font               = Enum.Font.GothamBold
labelMid.TextSize           = 18
labelMid.TextColor3         = Color3.new(1, 1, 1)
labelMid.TextStrokeTransparency = 0.3
labelMid.TextStrokeColor3   = Color3.new(0, 0, 0)
labelMid.Text               = "SAMLONG ANTI 02"

-- POPUP FRAME & CONTENT
local popupFrame = Instance.new("Frame", mainFrame)
popupFrame.Size               = UDim2.new(0.8, 0, 0.4, 0)
popupFrame.Position           = UDim2.new(0.1, 0, 0.3, 0)
popupFrame.BackgroundColor3   = Color3.fromRGB(255, 30, 30)
popupFrame.BorderSizePixel    = 0
popupFrame.ZIndex             = 1000
popupFrame.Visible            = false

local popupText = Instance.new("TextLabel", popupFrame)
popupText.Size               = UDim2.new(1, 0, 0.7, 0)
popupText.Position           = UDim2.new(0, 0, 0, 0)
popupText.BackgroundTransparency = 1
popupText.Font               = Enum.Font.GothamBlack
popupText.TextScaled         = true
popupText.TextColor3         = Color3.new(1, 1, 1)
popupText.TextStrokeTransparency = 0.2
popupText.TextStrokeColor3   = Color3.new(0, 0, 0)
popupText.Text               = "🚨 STUCK YA ALLAHH 🚨"
popupText.ZIndex              = 1001

local okBtn = Instance.new("TextButton", popupFrame)
okBtn.Size               = UDim2.new(0, 120, 0, 50)
okBtn.Position           = UDim2.new(0.5, -60, 0.75, 0)
okBtn.Font               = Enum.Font.GothamBold
okBtn.TextSize           = 22
okBtn.Text               = "OK"
okBtn.BackgroundColor3   = Color3.new(1, 1, 1)
okBtn.TextColor3         = Color3.new(0, 0, 0)
okBtn.BorderSizePixel    = 0
okBtn.ZIndex             = 1001
okBtn.Visible            = false

-- WAKTU & FLAG
local lastPlayTime    = os.time()
local lastValChange   = os.time()
local alerted         = false
local STUCK_THRESHOLD = 600  -- 600 detik = 10 menit

-- Fungsi updateLastPlayed
local function updateLastPlayed()
	local diff = os.difftime(os.time(), lastPlayTime)
	local m    = math.floor(diff/60)
	local s    = diff % 60
	lastPlayedLabel.Text = ("Last: %dm %ds"):format(m, s)
end

-- 📊 INIT: kirim jumlah awal ke Google Sheets + Railway API (sekali, saat script start)
task.delay(5, function()
	local guiInst = player:FindFirstChild("PlayerGui")
	local label = guiInst
		and guiInst:FindFirstChild("BoxShop")
		and guiInst.BoxShop.Container.Box:FindFirstChild("MinigamePoint")

	if label then
		local val = (label.Text or ""):gsub("%D", "")
		if val == "" then val = "0" end

		-- Google Sheets
		sendInit(val)
		sendUpdate(val)

		-- Railway API (first call → backend auto-sets start_amount)
		local rawNum = tonumber(val) or 0
		apiUpdate(player.Name, rawNum)
	end
end)

-- Fungsi updatePoint
local function updatePoint()
	for _ = 1, 30 do
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
					lastPlayTime  = os.time()
					lastValChange = os.time()
					alerted       = false
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

-- BUY AVANZA CONNECT (fixed parsing uang)
buyBtn.MouseButton1Click:Connect(function()
	local cashLabel = player.PlayerGui:FindFirstChild("Main")
		and player.PlayerGui.Main:FindFirstChild("Container")
		and player.PlayerGui.Main.Container:FindFirstChild("Hub")
		and player.PlayerGui.Main.Container.Hub:FindFirstChild("CashFrame")
		and player.PlayerGui.Main.Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")
	if not cashLabel then
		warn("Cash label not found!")
		return
	end

	local raw    = cashLabel.Text
	local digits = raw:gsub("%D","")
	local uang   = tonumber(digits) or 0
	local hargaAvanza = 232850000

	if uang >= hargaAvanza then
		rp:WaitForChild("NetworkContainer")
		  :WaitForChild("RemoteFunctions")
		  :WaitForChild("Dealership")
		  :InvokeServer("Buy","2021Avanza15CVT","White","Toyota")
	else
		notif.Text = ("😔 UANG KURANG: %s / %s"):format(uang, hargaAvanza)
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

-- OK BUTTON: hide popup, reset timers
okBtn.MouseButton1Click:Connect(function()
	popupFrame.Visible   = false
	okBtn.Visible        = false
	lastValChange        = os.time()
	lastPlayTime         = os.time()
	lastPlayedLabel.Text = "Last: 0m 0s"
	alerted              = false
end)

-- ═══════════════════════════════════
--  PRIVATE SERVER AUTO JOIN (MINIGAME)
-- ═══════════════════════════════════
task.spawn(function()
	task.wait(3) -- tunggu game load

	local REGION = "Jakarta" -- minigame selalu Jakarta

	print("[PS] Cek private server untuk:", player.Name)
	local psData = apiGetPrivateServer(player.Name)

	local jumpMode = "jump" -- default

	if psData == nil then
		-- User belum ada di dashboard, skip join tapi tetap auto-start
		print("[PS] Slot tidak ditemukan di API, skip private server")
	else
		jumpMode = psData.jump_mode or "jump"
		local serverCode = psData.server_code

		if serverCode and serverCode ~= "" then
			-- ✅ Server sudah ada → langsung join
			print("[PS] Server ditemukan:", serverCode, "| Region:", REGION)
			pcall(function()
				psRemote:FireServer("Join", serverCode, REGION)
			end)
			print("[PS] FireServer Join berhasil")
		else
			-- ❌ Belum ada server → Create dulu
			print("[PS] Belum ada server, membuat private server baru...")
			pcall(function()
				psRemote:FireServer("Create")
			end)

			-- Ambil code dari label GUI
			task.wait(1) -- beri jeda sebelum baca label
			local newCode = waitForServerLabel()

			if newCode then
				print("[PS] Code baru:", newCode)
				-- Kirim ke API
				apiSetPrivateServer(player.Name, newCode, REGION)
				task.wait(0.5)
				-- Join server baru
				pcall(function()
					psRemote:FireServer("Join", newCode, REGION)
				end)
				print("[PS] Join server baru berhasil")
			else
				print("[PS] Gagal ambil server code dari label, skip join")
			end
		end
	end

	-- Auto-start berdasarkan jump_mode dari dashboard
	task.wait(2) -- beri waktu server join selesai
	print("[PS] Jump mode:", jumpMode)
	if jumpMode == "nojump" then
		print("[PS] Auto-start NOJUMP")
		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/nojump.lua"
		))()
	else
		print("[PS] Auto-start JUMP")
		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/jump.lua"
		))()
	end
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
		local diff = os.difftime(os.time(), lastValChange)
		if not alerted and diff >= STUCK_THRESHOLD then
			popupFrame.Visible = true
			okBtn.Visible      = true
			alerted            = true
		end
		task.wait(1)
	end
end)

-- 📊 UPDATE: kirim jumlah sekarang ke Google Sheets + Railway API tiap 20 menit
task.spawn(function()
	while true do
		task.wait(1200) -- 20 menit

		local guiInst = player:FindFirstChild("PlayerGui")
		local label = guiInst
			and guiInst:FindFirstChild("BoxShop")
			and guiInst.BoxShop:FindFirstChild("Container")
			and guiInst.BoxShop.Container:FindFirstChild("Box")
			and guiInst.BoxShop.Container.Box:FindFirstChild("MinigamePoint")

		if label and label:IsA("TextLabel") then
			local raw = label.Text or ""
			local val = raw:gsub("%D", "")
			if val == "" then val = "0" end

			-- Google Sheets
			sendUpdate(val)

			-- Railway API
			local rawNum = tonumber(val) or 0
			apiUpdate(player.Name, rawNum)
		end
	end
end)
