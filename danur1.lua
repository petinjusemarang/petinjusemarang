--[[
	AUTO RACE v8.3 - CDID
	✅ BodyVelocity + BodyGyro smooth movement
	✅ V-shape bridge (rendah di tengah, nanjak di ujung)
	✅ Delete map + Map.Vehicles
	✅ Portrait GUI + runtime timer
	✅ Dual: Google Sheets + Railway API
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
	char = newChar
	root = newChar:WaitForChild("HumanoidRootPart")
end)

local remotes = RS:WaitForChild("RaceRemotes")
local NPC_PATH = Workspace.Etc.Race.NPC.DA0ZA
local PROMPT_PATH = NPC_PATH.HumanoidRootPart.Prompt

local RUNNING = false
local MODE = "LOSE"
local RACE_COUNT = 0
local STATUS_TEXT = "Idle"
local MAP_DELETED = false
local SESSION_START = os.clock()
local POINTS_AT_START = 0

local SPEED = { WIN = 250, LOSE = 200 }
local ACCEL = 5

-- 🔥 RAILWAY API CONFIG
local API_URL = "https://samlongweb-production.up.railway.app"
local API_KEY = "slg_prod_nJjQZJQ4kR98l9zTfTJ56CBgeDrzxaws0eFk7rYJg2SAhvu7WRloXti3KkiXRnYN"  -- SAMA dengan di .env Railway

local CHECKPOINTS = {
	Vector3.new(126.484, 3.234, -413.750),
	Vector3.new(125.373, 3.228, -1272.303),
	Vector3.new(-173.397, 3.228, -2036.829),
	Vector3.new(-1007.555, 3.228, -2168.953),
	Vector3.new(-1855.214, -6.747, -2227.516),
	Vector3.new(-2649.424, -21.988, -2553.774),
	Vector3.new(-3326.388, -32.172, -3050.381),
	Vector3.new(-2964.084, -34.634, -3808.800),
	Vector3.new(-2547.419, -32.170, -4560.326),
	Vector3.new(-2131.537, -38.320, -5309.163),
	Vector3.new(-1701.094, -34.047, -6051.912),
	Vector3.new(-1256.946, -69.740, -6784.079),
	Vector3.new(-939.994, -54.307, -7576.575),
	Vector3.new(-1476.921, -54.550, -8167.188),
	Vector3.new(-2226.989, -54.478, -8583.185),
	Vector3.new(-2952.778, -46.232, -9039.672),
	Vector3.new(-3521.273, -41.104, -9671.608),
	Vector3.new(-3932.669, -25.455, -10419.997),
	Vector3.new(-3815.698, -25.321, -11207.516),
	Vector3.new(-3270.269, -86.230, -11871.715),
	Vector3.new(-2767.950, -66.776, -12560.823),
	Vector3.new(-2530.768, -39.475, -13348.704),
	Vector3.new(-2808.955, -38.912, -14160.520),
	Vector3.new(-3094.195, -35.982, -14973.083),
	Vector3.new(-3364.130, -48.026, -15782.974),
	Vector3.new(-3506.115, -34.960, -16628.467),
	Vector3.new(-3555.211, -76.962, -17489.098),
	Vector3.new(-3576.361, -88.727, -18339.076),
	Vector3.new(-3561.386, -63.232, -19195.998),
	Vector3.new(-3541.395, -75.296, -20053.066),
	Vector3.new(-3435.542, -93.999, -20904.252),
	Vector3.new(-3291.255, -50.174, -21745.605),
	Vector3.new(-3142.049, -76.561, -22592.246),
	Vector3.new(-3129.446, -79.572, -23450.859),
	Vector3.new(-3130.823, -79.572, -24307.510),
	Vector3.new(-3130.794, -74.634, -25167.229),
	Vector3.new(-3131.090, -56.682, -26026.822),
	Vector3.new(-3127.974, -79.572, -26880.486),
	Vector3.new(-3128.549, -79.572, -27740.045),
}

-- ==========================================================
-- 🧱 PLATFORM + ROAD + MAP DELETE
-- ==========================================================
local function createPlatform(pos, size)
	local part = Instance.new("Part")
	part.Size = size or Vector3.new(100, 3, 100)
	part.Anchored = true
	part.Material = Enum.Material.Asphalt
	part.Color = Color3.fromRGB(50, 50, 50)
	part.Position = pos - Vector3.new(0, 3, 0)
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = Workspace
end

local function createRoad(from, to)
	local fromPos = Vector3.new(from.X, from.Y - 3 - 3, from.Z)
	local toPos = Vector3.new(to.X, to.Y - 3 + 3, to.Z)
	local mid = (fromPos + toPos) / 2
	local dist = (toPos - fromPos).Magnitude

	local part = Instance.new("Part")
	part.Size = Vector3.new(100, 3, dist + 200)
	part.Anchored = true
	part.Material = Enum.Material.Asphalt
	part.Color = Color3.fromRGB(45, 45, 45)
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = CFrame.lookAt(mid, toPos)
	part.Parent = Workspace
end

local function deleteMap()
	if MAP_DELETED then return end
	MAP_DELETED = true

	pcall(function()
		for _, v in pairs(Workspace.Map:GetChildren()) do
			v:Destroy()
		end
	end)

	local toDelete = {
		"Landmarks", "Lampu Merah", "Gapura", "Lights",
		"Tree", "StreetLamp_Pantura", "OwnableHouse", "NightLight",
		"NPCVehicle", "Trees", "Bushes", "Plants", "Decorations",
		"Props", "StreetProps", "TrafficLight"
	}
	for _, name in ipairs(toDelete) do
		local obj = Workspace:FindFirstChild(name)
		if obj then obj:Destroy() end
	end

	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e10
	Lighting.Brightness = 1
	Lighting.ClockTime = 14
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

local function buildPlatforms()
	for i = 1, #CHECKPOINTS - 1 do
		local from = CHECKPOINTS[i]
		local to = CHECKPOINTS[i + 1]
		local diffY = math.abs(to.Y - from.Y)

		if diffY > 10 then
			local p1 = from + (to - from) * 0.25
			local p2 = from + (to - from) * 0.5
			local p3 = from + (to - from) * 0.75
			createRoad(from, p1)
			createRoad(p1, p2)
			createRoad(p2, p3)
			createRoad(p3, to)
		else
			createRoad(from, to)
		end
	end
	local npcRoot = NPC_PATH:FindFirstChild("HumanoidRootPart")
	if npcRoot then
		createRoad(npcRoot.Position, CHECKPOINTS[1])
		createPlatform(npcRoot.Position - Vector3.new(0, 3, 0), Vector3.new(100, 3, 100))
	end
	createPlatform(CHECKPOINTS[#CHECKPOINTS])
end

-- ==========================================================
-- 🚗 GET VEHICLE
-- ==========================================================
local function getVehicle()
	local c = player.Character or player.CharacterAdded:Wait()
	local hum = c:FindFirstChild("Humanoid")
	if hum and hum.SeatPart then
		local v = hum.SeatPart:FindFirstAncestorOfClass("Model")
		if v and v.PrimaryPart then return v end
	end
	return nil
end

-- ==========================================================
-- 📺 RACEHUD + CPLabel
-- ==========================================================
local function isRaceHUDVisible()
	local ok, val = pcall(function()
		return player.PlayerGui.Race.Container.RaceHUD.Visible
	end)
	return ok and val
end

local function getCurrentCP()
	local ok, text = pcall(function()
		return player.PlayerGui.Race.Container.RaceHUD.CheckpointPanel.CPLabel.Text
	end)
	if ok and text then
		local num = text:match("(%d+)")
		return tonumber(num) or 0
	end
	return 0
end

-- ==========================================================
-- 🏁 AUTO RACE (1 BodyVelocity, gak berhenti antar CP)
-- ==========================================================
local function runRace()
	STATUS_TEXT = "Racing..."
	local vehicle = getVehicle()
	if not vehicle then STATUS_TEXT = "No vehicle!"; return end
	local vRoot = vehicle.PrimaryPart
	if not vRoot then return end

	local total = #CHECKPOINTS
	local maxSpeed = MODE == "WIN" and SPEED.WIN or SPEED.LOSE

	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bodyVel.Parent = vRoot

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bodyGyro.P = 10000
	bodyGyro.Parent = vRoot

	local speed = 0
	local currentCP = 1
	local lastPos = vRoot.Position
	local stuckTime = 0
	local raceStartTime = tick()

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not RUNNING or not getVehicle() or currentCP > total then
			pcall(function() bodyVel:Destroy() end)
			pcall(function() bodyGyro:Destroy() end)
			if connection then connection:Disconnect() end
			return
		end

		local target = CHECKPOINTS[currentCP]
		local direction = target - vRoot.Position
		local distance = direction.Magnitude

		speed = math.min(speed + ACCEL, maxSpeed)

		bodyVel.Velocity = direction.Unit * speed
		bodyGyro.CFrame = CFrame.lookAt(vRoot.Position, target)

		if tick() - raceStartTime > 5 then
			if (vRoot.Position - lastPos).Magnitude < 1 then
				stuckTime += 1
			else
				stuckTime = 0
			end
			lastPos = vRoot.Position

			if stuckTime > 30 then
				stuckTime = 0
				bodyVel.Velocity = Vector3.zero
				local fwd = direction.Unit * 50
				vRoot.CFrame = CFrame.new(vRoot.Position.X + fwd.X, vRoot.Position.Y + 20, vRoot.Position.Z + fwd.Z)
				vRoot.Anchored = true
				task.defer(function()
					for d = 1, 20 do
						if not vRoot or not vRoot.Parent then break end
						vRoot.CFrame = vRoot.CFrame - Vector3.new(0, 1, 0)
						task.wait(0.03)
					end
					if vRoot and vRoot.Parent then
						vRoot.Anchored = false
					end
				end)
			end
		end

		if distance < 15 then
			currentCP += 1
			if currentCP <= total then
				STATUS_TEXT = string.format("CP %d/%d", currentCP, total)
			end
		end
	end)

	local timeout = 0
	repeat
		task.wait(0.2)
		timeout += 0.2
	until currentCP > total or timeout >= 300 or not RUNNING or not getVehicle()

	if connection and connection.Connected then
		connection:Disconnect()
	end
	pcall(function() bodyVel:Destroy() end)
	pcall(function() bodyGyro:Destroy() end)

	if currentCP > total then
		STATUS_TEXT = "Finished!"
		local st = 0
		while st < 3 and RUNNING do
			if not isRaceHUDVisible() then break end
			task.wait(0.5); st += 0.5
		end
	end
end

-- ==========================================================
-- 🏠 LOBBY
-- ==========================================================
local function approachNPC()
	local npcRoot = NPC_PATH:FindFirstChild("HumanoidRootPart")
	if not npcRoot then return false end
	local npcPos = npcRoot.Position
	local landPos = npcPos + npcRoot.CFrame.LookVector * 5
	local delay = MODE == "WIN" and 1 or 1.5
	STATUS_TEXT = string.format("NPC (%.0fs)...", delay)
	task.wait(delay)
	root.CFrame = CFrame.new(landPos.X, npcPos.Y + 3, landPos.Z)
	task.wait(1)
	return true
end

local function fireNPCPrompt()
	local prompt = PROMPT_PATH
	if prompt and prompt:IsA("ProximityPrompt") then
		STATUS_TEXT = "Opening menu..."
		fireproximityprompt(prompt)
		return true
	end
	return false
end

local function waitMenuOpen()
	local raceGui = player.PlayerGui:WaitForChild("Race", 10)
	if not raceGui then return nil end
	local container = raceGui:WaitForChild("Container", 5)
	if not container then return nil end
	local raceMenu = container:WaitForChild("RaceMenu", 5)
	if not raceMenu then return nil end
	local t = 0
	repeat task.wait(0.1); t += 0.1 until raceMenu.Visible or t > 5
	return raceMenu.Visible and raceMenu or nil
end

local function joinLobby(menu)
	local lobbyList = menu:WaitForChild("JoinSection"):WaitForChild("LobbyList")
	for _, lobby in pairs(lobbyList:GetChildren()) do
		if lobby:IsA("Frame") and lobby.Name ~= "LobbyRowTemplate" then
			local hostLabel = lobby:FindFirstChild("HostName", true)
			if hostLabel and hostLabel.Text ~= player.Name then
				local id = tonumber(lobby.Name:match("%d+"))
				if id then remotes.JoinLobby:FireServer(id); return true end
			end
		end
	end
	return false
end

local function createLobby() remotes.CreateLobby:FireServer(player.Name .. "'s Lobby") end

local function selectRandomCar()
	local ok, carList = pcall(function()
		return player.PlayerGui.Main.Container.Spawner.ScrollingFrame
	end)
	if not ok or not carList then return end
	local cars = {}
	for _, v in pairs(carList:GetChildren()) do
		if v:IsA("Frame") then table.insert(cars, v.Name) end
	end
	if #cars == 0 then return end
	local chosen = cars[math.random(1, #cars)]
	remotes.SelectCar:FireServer(chosen, chosen)
end

local function readyUp() remotes.ToggleReady:FireServer() end

-- ==========================================================
-- 🛡️ ANTI AFK + SCOREBOARD DESTROY + NPC DELETE
-- ==========================================================
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
	pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0, 0)) end)
end)

task.spawn(function()
	local rc = player:WaitForChild("PlayerGui"):WaitForChild("Race"):WaitForChild("Container")
	rc.ChildAdded:Connect(function(child)
		if child.Name == "Scoreboard" then task.wait(0.5); pcall(function() child:Destroy() end) end
	end)
end)

task.spawn(function()
	while true do
		task.wait(10)
		local nf = Workspace:FindFirstChild("NPCVehicle")
		if nf then nf:ClearAllChildren() end
	end
end)

-- ==========================================================
-- 🔁 MAIN LOOP
-- ==========================================================
task.spawn(function()
	while true do
		task.wait(1)
		if not RUNNING then continue end

		if not MAP_DELETED then
			STATUS_TEXT = "Deleting map..."
			deleteMap()
			task.wait(1)
			STATUS_TEXT = "Building platforms + bridges..."
			buildPlatforms()
			task.wait(1)
		end

		local arrived = approachNPC()
		if not arrived or not RUNNING then continue end
		local prompted = fireNPCPrompt()
		if not prompted then task.wait(2); continue end
		local menu = waitMenuOpen()
		if not menu then task.wait(2); continue end

		pcall(function() remotes.LeaveLobby:FireServer() end)
		task.wait(1)
		fireNPCPrompt()
		task.wait(1)
		local menu2 = waitMenuOpen()
		if not menu2 then menu2 = menu end

		pcall(function() remotes.GetLobbies:InvokeServer() end)
		task.wait(1)

		local joined = false
		if MODE == "WIN" then
			createLobby()
			STATUS_TEXT = "Created lobby (HOST)"
		else
			for attempt = 1, 10 do
				joined = joinLobby(menu)
				if joined then STATUS_TEXT = "Joined lobby"; break end
				STATUS_TEXT = string.format("No lobby %d/10...", attempt)
				pcall(function() remotes.GetLobbies:InvokeServer() end)
				task.wait(3)
			end
			if not joined then STATUS_TEXT = "No lobby..."; task.wait(3); continue end
		end

		task.wait(2)
		selectRandomCar()
		task.wait(0.5)
		readyUp()
		STATUS_TEXT = "Ready!"

		if MODE == "WIN" then
			task.spawn(function()
				while RUNNING and not isRaceHUDVisible() do task.wait(5); remotes.StartRace:FireServer() end
			end)
		end

		STATUS_TEXT = "Waiting race..."
		while RUNNING and not isRaceHUDVisible() do task.wait(0.5) end
		if not RUNNING then continue end

		STATUS_TEXT = "Countdown..."
		task.wait(3)

		runRace()

		pcall(function() player.PlayerGui.Race.Container.Scoreboard:Destroy() end)

		RACE_COUNT += 1
		STATUS_TEXT = string.format("Done! x%d → NPC", RACE_COUNT)

		local npcRoot = NPC_PATH:FindFirstChild("HumanoidRootPart")
		if npcRoot and RUNNING then
			local npcPos = npcRoot.Position
			local landPos = npcPos + npcRoot.CFrame.LookVector * 5
			root.CFrame = CFrame.new(landPos.X, npcPos.Y + 35, landPos.Z)
			root.Anchored = true
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			task.wait(3)
			root.Anchored = false
			for i = 1, 30 do
				if not RUNNING then break end
				root.CFrame = root.CFrame - Vector3.new(0, 1, 0)
				task.wait(0.03)
			end
			task.wait(0.5)
		end

		local wt = 0
		while RUNNING and isRaceHUDVisible() and wt < 3 do
			task.wait(0.5); wt += 0.5
			pcall(function() player.PlayerGui.Race.Container.RaceHUD.Visible = false end)
		end
	end
end)

-- ==========================================================
-- 🎮 GUI — BIG CENTER MONITOR
-- ==========================================================
local oldGui = player.PlayerGui:FindFirstChild("AutoRaceGUI")
if oldGui then oldGui:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "AutoRaceGUI"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player.PlayerGui

local POINTS_LABEL = player:WaitForChild("PlayerGui"):WaitForChild("Race"):WaitForChild("Container"):WaitForChild("Shop"):WaitForChild("TitleBar"):WaitForChild("PointsPill"):WaitForChild("Value")

local function getPointsNum()
	if POINTS_LABEL then
		local raw = POINTS_LABEL.Text or ""
		local digits = raw:gsub("%D", "")
		if digits == "" then return 0 end
		return tonumber(digits) or 0
	end
	return 0
end
local function getPointsText()
	if POINTS_LABEL then return POINTS_LABEL.Text end
	return "0 PTS"
end
local function corner(p, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p
end

local centerFrame = Instance.new("Frame")
centerFrame.Size = UDim2.new(1, 0, 0, 220)
centerFrame.Position = UDim2.new(0, 0, 0.5, -110)
centerFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
centerFrame.BackgroundTransparency = 0.1
centerFrame.BorderSizePixel = 0
centerFrame.Parent = gui

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(1, 0, 0, 35)
usernameLabel.Position = UDim2.new(0, 0, 0, 5)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = player.Name
usernameLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
usernameLabel.TextSize = 30
usernameLabel.Font = Enum.Font.GothamBold
usernameLabel.TextXAlignment = Enum.TextXAlignment.Center
usernameLabel.TextScaled = true
usernameLabel.Parent = centerFrame

local pointsLabel = Instance.new("TextLabel")
pointsLabel.Size = UDim2.new(1, -10, 0, 65)
pointsLabel.Position = UDim2.new(0, 5, 0, 38)
pointsLabel.BackgroundTransparency = 1
pointsLabel.Text = "0 PTS"
pointsLabel.TextColor3 = Color3.fromRGB(255, 215, 60)
pointsLabel.TextSize = 55
pointsLabel.Font = Enum.Font.GothamBold
pointsLabel.TextXAlignment = Enum.TextXAlignment.Center
pointsLabel.TextScaled = true
pointsLabel.Parent = centerFrame

local earnedLabel = Instance.new("TextLabel")
earnedLabel.Size = UDim2.new(1, 0, 0, 40)
earnedLabel.Position = UDim2.new(0, 0, 0, 103)
earnedLabel.BackgroundTransparency = 1
earnedLabel.Text = "+0 earned"
earnedLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
earnedLabel.TextSize = 30
earnedLabel.Font = Enum.Font.GothamBold
earnedLabel.TextXAlignment = Enum.TextXAlignment.Center
earnedLabel.TextScaled = true
earnedLabel.Parent = centerFrame

local ptsHrLabel = Instance.new("TextLabel")
ptsHrLabel.Size = UDim2.new(1, 0, 0, 30)
ptsHrLabel.Position = UDim2.new(0, 0, 0, 143)
ptsHrLabel.BackgroundTransparency = 1
ptsHrLabel.Text = "0 pts/hr"
ptsHrLabel.TextColor3 = Color3.fromRGB(120, 200, 140)
ptsHrLabel.TextSize = 24
ptsHrLabel.Font = Enum.Font.GothamBold
ptsHrLabel.TextXAlignment = Enum.TextXAlignment.Center
ptsHrLabel.TextScaled = true
ptsHrLabel.Parent = centerFrame

local runtimeLabel = Instance.new("TextLabel")
runtimeLabel.Size = UDim2.new(0, 100, 0, 20)
runtimeLabel.Position = UDim2.new(0, 5, 0, 5)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.Text = "00:00:00"
runtimeLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
runtimeLabel.TextSize = 14
runtimeLabel.Font = Enum.Font.GothamBold
runtimeLabel.TextXAlignment = Enum.TextXAlignment.Left
runtimeLabel.Parent = gui

local topInfoLabel = Instance.new("TextLabel")
topInfoLabel.Size = UDim2.new(0.5, 0, 0, 16)
topInfoLabel.Position = UDim2.new(0, 5, 0, 178)
topInfoLabel.BackgroundTransparency = 1
topInfoLabel.Text = "x0"
topInfoLabel.TextColor3 = Color3.fromRGB(140, 140, 180)
topInfoLabel.TextSize = 12
topInfoLabel.Font = Enum.Font.Gotham
topInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
topInfoLabel.Parent = centerFrame

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0.5, -5, 0, 16)
statusLbl.Position = UDim2.new(0.5, 0, 0, 178)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Idle"
statusLbl.TextColor3 = Color3.fromRGB(100, 100, 140)
statusLbl.TextSize = 12
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextXAlignment = Enum.TextXAlignment.Right
statusLbl.Parent = centerFrame

local botBar = Instance.new("Frame")
botBar.Size = UDim2.new(1, 0, 0, 75)
botBar.Position = UDim2.new(0, 0, 1, -75)
botBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
botBar.BackgroundTransparency = 0.3
botBar.BorderSizePixel = 0
botBar.Parent = gui
local botGrad = Instance.new("UIGradient"); botGrad.Rotation = 270
botGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.8, 0), NumberSequenceKeypoint.new(1, 1)})
botGrad.Parent = botBar

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, -20, 0, 26); startBtn.Position = UDim2.new(0, 10, 0, 5)
startBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 70); startBtn.Text = "START"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255); startBtn.TextSize = 12
startBtn.Font = Enum.Font.GothamBold; startBtn.AutoButtonColor = true; startBtn.Parent = botBar; corner(startBtn, 8)

local winBtn = Instance.new("TextButton")
winBtn.Size = UDim2.new(0.5, -15, 0, 22); winBtn.Position = UDim2.new(0, 10, 0, 36)
winBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 65); winBtn.Text = "WIN"
winBtn.TextColor3 = Color3.fromRGB(255, 255, 255); winBtn.TextSize = 10
winBtn.Font = Enum.Font.GothamBold; winBtn.AutoButtonColor = true; winBtn.Parent = botBar; corner(winBtn, 6)

local loseBtn = Instance.new("TextButton")
loseBtn.Size = UDim2.new(0.5, -15, 0, 22); loseBtn.Position = UDim2.new(0.5, 5, 0, 36)
loseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 65); loseBtn.Text = "LOSE"
loseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); loseBtn.TextSize = 10
loseBtn.Font = Enum.Font.GothamBold; loseBtn.AutoButtonColor = true; loseBtn.Parent = botBar; corner(loseBtn, 6)

local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -20, 0, 10); infoLbl.Position = UDim2.new(0, 10, 0, 62)
infoLbl.BackgroundTransparency = 1; infoLbl.TextColor3 = Color3.fromRGB(55, 55, 80)
infoLbl.TextSize = 7; infoLbl.Font = Enum.Font.Gotham
infoLbl.TextXAlignment = Enum.TextXAlignment.Center; infoLbl.Text = ""; infoLbl.Parent = botBar

task.delay(3, function()
	POINTS_AT_START = getPointsNum()
	SESSION_START = os.clock()
end)

local function refreshGUI()
	pointsLabel.Text = getPointsText()
	local elapsed = os.clock() - SESSION_START
	local earned = getPointsNum() - POINTS_AT_START
	if earned < 0 then earned = 0 end
	local hours = elapsed / 3600
	local ptsHr = 0
	if hours > 0.02 then ptsHr = math.floor(earned / hours) end
	ptsHrLabel.Text = string.format("%d pts/hr", ptsHr)
	earnedLabel.Text = string.format("+%d earned", earned)
	local h = math.floor(elapsed / 3600)
	local m = math.floor((elapsed % 3600) / 60)
	local s = math.floor(elapsed % 60)
	runtimeLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
	topInfoLabel.Text = string.format("x%d races", RACE_COUNT)
	if RUNNING then
		statusLbl.Text = STATUS_TEXT
		statusLbl.TextColor3 = Color3.fromRGB(90, 200, 120)
		startBtn.Text = "STOP"; startBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	else
		statusLbl.Text = "Stopped"
		statusLbl.TextColor3 = Color3.fromRGB(100, 100, 140)
		startBtn.Text = "START"; startBtn.BackgroundColor3 = Color3.fromRGB(35, 140, 70)
	end
	if MODE == "WIN" then
		winBtn.BackgroundColor3 = Color3.fromRGB(170, 125, 15); winBtn.Text = "WIN <"
		loseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55); loseBtn.Text = "LOSE"
	else
		winBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55); winBtn.Text = "WIN"
		loseBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 140); loseBtn.Text = "LOSE <"
	end
	infoLbl.Text = string.format("v8.3 | %s | BV %d/%d", MODE == "WIN" and "HOST" or "JOIN", SPEED.WIN, SPEED.LOSE)
end
refreshGUI()

startBtn.MouseButton1Click:Connect(function()
	RUNNING = not RUNNING
	if RUNNING then SESSION_START = os.clock(); POINTS_AT_START = getPointsNum() end
	STATUS_TEXT = RUNNING and "Starting..." or "Stopped"
	refreshGUI()
end)
winBtn.MouseButton1Click:Connect(function() MODE = "WIN"; refreshGUI() end)
loseBtn.MouseButton1Click:Connect(function() MODE = "LOSE"; refreshGUI() end)
task.spawn(function() while true do task.wait(1); refreshGUI() end end)

-- ==========================================================
-- 📡 DISCORD WEBHOOK (5 URL, random pick, tiap 30 menit)
-- ==========================================================
local WEBHOOK_URLS = {
	"https://discord.com/api/webhooks/1486677758838050886/-4KZKc9XPfhenUsbx5JAmxPHLxpXguU1whbMJYkRyzyfayFWUqnmxV7DRh8dvgFJOxCd",
	"https://discord.com/api/webhooks/1486689239914774600/NNXdfR1GF9CaxVAM4vbrbsAV3pXizxQSHs_PqM0CArPezApql7zEKZQR0rEMUfAl3gh8",
	"https://discord.com/api/webhooks/1486689242179436624/tqSUuI6ww3ok98-qv1NnM5S7UWmD6W_Rq44s034KIZx9Zazh44F-1Nn8GK1Vw5A0dLfN",
	"https://discord.com/api/webhooks/1486689243630796874/8O63v71D3mX8mAzfXaXtal5HxN20CIPHfPzxx_I3KztmefI5xzWR4ro0yasJZbF-1rG7",
	"https://discord.com/api/webhooks/1486689252732436590/xjCM3rmF-Y6H9CRKRO8nUnnGnrUPGIozO-jlWNbmD4iNs5Hm1AVKIO5KJau_rfyDSO94",
}

local function sendWebhook()
	local elapsed = os.clock() - SESSION_START
	local h = math.floor(elapsed / 3600)
	local m = math.floor((elapsed % 3600) / 60)
	local s = math.floor(elapsed % 60)
	local runtime = string.format("%02d:%02d:%02d", h, m, s)

	local currentPts = getPointsNum()
	local earned = currentPts - POINTS_AT_START
	if earned < 0 then earned = 0 end
	local hours = elapsed / 3600
	local ptsHr = 0
	if hours > 0.02 then ptsHr = math.floor(earned / hours) end

	local modeText = MODE == "WIN" and "WIN" or "LOSE"

	local data = {
		embeds = {{
			title = "\xF0\x9F\x8F\x81 " .. player.Name,
			color = 16769280,
			fields = {
				{ name = "Total Points", value = getPointsText(), inline = true },
				{ name = "Earned Session", value = "+" .. tostring(earned), inline = true },
				{ name = "PTS/Hour", value = tostring(ptsHr), inline = true },
				{ name = "Races", value = tostring(RACE_COUNT), inline = true },
				{ name = "Mode", value = modeText, inline = true },
				{ name = "Runtime", value = runtime, inline = true },
			},
			footer = { text = "Auto Race v8.3 | " .. os.date("%Y-%m-%d %H:%M:%S") },
		}}
	}

	local json = HttpService:JSONEncode(data)
	local url = WEBHOOK_URLS[math.random(1, #WEBHOOK_URLS)]

	pcall(function()
		local req = (syn and syn.request) or (http and http.request) or request
		if req then
			req({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = json
			})
		end
	end)
end

-- Discord: saat start + tiap 30 menit
task.spawn(function()
	while not RUNNING do task.wait(5) end
	task.wait(10)
	sendWebhook()

	while true do
		task.wait(1800)
		if RUNNING then sendWebhook() end
	end
end)

-- ==========================================================
-- 📊 GOOGLE SHEETS (update kolom F + init kolom G)
-- ==========================================================
local SHEETS_URL = "https://script.google.com/macros/s/AKfycbzBFd5ASlqRLk1pS4Kx3cvBujvFsCIr0QKrdtVO9xZv8fBPHp0L1CKKRwnjpQwD7qHrIw/exec"

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

function updateGoogleSheet()
	local pts = getPointsNum()
	local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. tostring(pts) .. "&action=update"
	sheetsRequest(url)
end

function initGoogleSheet()
	local pts = getPointsNum()
	local url = SHEETS_URL .. "?username=" .. player.Name .. "&points=" .. tostring(pts) .. "&action=init"
	sheetsRequest(url)
end

-- ==========================================================
-- 📡 RAILWAY API HELPER
-- ==========================================================
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
			print("[API] Race update:", username, "points:", rawPoints)
		end
	end)
end

-- ==========================================================
-- 📊 INIT + UPDATE LOOPS (Google Sheets + Railway API)
-- ==========================================================

-- Init: kirim jumlah awal saat script pertama kali di-execute
task.spawn(function()
	task.wait(5) -- tunggu points ke-load

	-- Google Sheets init
	initGoogleSheet()

	-- Railway API init (first call → backend auto-sets start_amount)
	local pts = getPointsNum()
	apiUpdate(player.Name, pts)
end)

-- Google Sheets: tiap 10 menit
task.spawn(function()
	while not RUNNING do task.wait(5) end
	task.wait(10)
	updateGoogleSheet()

	while true do
		task.wait(600)
		if RUNNING then updateGoogleSheet() end
	end
end)

-- Railway API: tiap 10 menit (sama interval dengan Sheets)
task.spawn(function()
	while not RUNNING do task.wait(5) end
	task.wait(15) -- offset 5 detik dari Sheets biar ga barengan

	while true do
		if RUNNING then
			local pts = getPointsNum()
			apiUpdate(player.Name, pts)
		end
		task.wait(600) -- 10 menit
	end
end)
