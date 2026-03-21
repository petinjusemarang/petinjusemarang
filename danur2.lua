--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║              DANUR PART 2 — FULL AUTO                    ║
    ║                                                           ║
    ║   PHASE 1: Morse Radio Scan (cycle-aligned)              ║
    ║   PHASE 2: Door → Fill Code → Submit                     ║
    ║   PHASE 3: Hendrick Note → Cutscene (2m15s)             ║
    ║   PHASE 4: Peter Clues (1-5) with auto-solve + retry    ║
    ║   PHASE 5: Peter Door → Keypad Submit                    ║
    ║   PHASE 6: Peter Note → COMPLETE                         ║
    ╚═══════════════════════════════════════════════════════════╝
--]]

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char   = player.Character or player.CharacterAdded:Wait()
local hrp    = char:WaitForChild("HumanoidRootPart")

--// ═══════════════════════════════════════════════
--// REFERENCES
--// ═══════════════════════════════════════════════

-- Morse
local radiosFolder = workspace:WaitForChild("RadioMorseHospital")
local morseRemote  = ReplicatedStorage
    :WaitForChild("NetworkContainer")
    :WaitForChild("RemoteEvents")
    :WaitForChild("RadioMorseHospital_MorsePuzzle_Submit")

-- Hendrick Door + Note
local hendrickDoor   = workspace:WaitForChild("HospitalDoors"):WaitForChild("PintuMasukRuanganHendrick")
local hendrickPrompt = hendrickDoor.Door:WaitForChild("MorseDoorPrompt")
local hendrickNote   = workspace:WaitForChild("Scenes"):WaitForChild("Hendrick"):WaitForChild("Note")
local hendrickNotePrompt = hendrickNote:WaitForChild("Prompt")

-- Peter
local peterScene     = workspace:WaitForChild("Scenes"):WaitForChild("Peter")
local peterDoor      = peterScene:WaitForChild("Pintu_Menuju_Peter")
local peterDoorPrompt= peterDoor:WaitForChild("Door"):WaitForChild("PeterKeypadPrompt")
local peterNote      = peterScene:WaitForChild("Note")
local peterNotePrompt= peterNote:WaitForChild("Prompt")

--// MORSE MAP
local morseToNumber = {
    [".----"]="1",["..---"]="2",["...--"]="3",["....-"]="4",
    ["....."]=  "5",["-...."]="6",["--..."]="7",["---.."]="8",
    ["----."]="9",["-----"]="0",
}

--// CONFIG
local RADIO_COUNT       = 5
local SCAN_DURATION     = 25
local CYCLE_GAP_THRESH  = 2.0
local CUTSCENE_DURATION = 210  -- 3m30s (android timing)
local MAX_CLUE_RETRIES  = 2

--// ═══════════════════════════════════════════════
--// MORSE SCANNING ENGINE (cycle-aligned)
--// ═══════════════════════════════════════════════

local function scanRadio(radio)
    local geo   = radio:WaitForChild("Radio_Geo")
    local long  = geo:WaitForChild("LongBeep")
    local short = geo:WaitForChild("ShortBeep")

    local events = {}
    local lastL, lastS = long.TimePosition, short.TimePosition
    local t0 = tick()

    local conn
    conn = RunService.Heartbeat:Connect(function()
        local t = tick() - t0
        if long.TimePosition < lastL - 0.05 then table.insert(events, {t, "-"}) end
        if short.TimePosition < lastS - 0.05 then table.insert(events, {t, "."}) end
        lastL, lastS = long.TimePosition, short.TimePosition
    end)

    task.wait(SCAN_DURATION)
    conn:Disconnect()

    if #events < 3 then return "?", "no events" end

    -- Find cycle boundaries
    local bounds = {1}
    for i = 2, #events do
        if events[i][1] - events[i-1][1] >= CYCLE_GAP_THRESH then
            table.insert(bounds, i)
        end
    end

    -- Extract complete cycles (skip first partial)
    local cycles = {}
    local startIdx = #bounds >= 2 and 2 or 1
    for b = startIdx, #bounds do
        local cEnd = b < #bounds and bounds[b+1]-1 or #events
        local seq = ""
        for i = bounds[b], cEnd do seq = seq .. events[i][2] end
        if #seq >= 5 then table.insert(cycles, seq) end
    end

    if #cycles == 0 then
        local full = ""
        for _, ev in ipairs(events) do full = full .. ev[2] end
        local freq = {}
        for i = 1, #full-4 do
            local s = full:sub(i,i+4)
            if morseToNumber[s] then freq[s] = (freq[s] or 0)+1 end
        end
        local best, mx = nil, 0
        for p, c in pairs(freq) do if c > mx then mx=c; best=p end end
        return best and morseToNumber[best] or "?", "fallback"
    end

    local votes = {}
    for _, cyc in ipairs(cycles) do
        if #cyc == 5 and morseToNumber[cyc] then
            local d = morseToNumber[cyc]
            votes[d] = (votes[d] or 0) + 3
        end
        for i = 1, #cyc-4 do
            local s = cyc:sub(i,i+4)
            if morseToNumber[s] then
                local d = morseToNumber[s]
                votes[d] = (votes[d] or 0) + 1
            end
        end
    end

    local bestD, bestS = "?", 0
    for d, s in pairs(votes) do if s > bestS then bestS=s; bestD=d end end
    return bestD, #cycles.." cycles"
end

local function scanAllRadios(callback)
    local results = {}
    local done = 0
    for i = 1, RADIO_COUNT do
        task.spawn(function()
            local radio = radiosFolder:FindFirstChild("Radio"..i)
            local digit, info = radio and scanRadio(radio) or "?", "not found"
            results[i] = {digit=digit, info=info}
            done = done + 1
            if callback then callback(i, results[i]) end
        end)
    end
    while done < RADIO_COUNT do task.wait(0.05) end
    local code = ""
    for i = 1, RADIO_COUNT do code = code .. results[i].digit end
    return code, results
end

--// ═══════════════════════════════════════════════
--// GAME UI INTERFACES
--// ═══════════════════════════════════════════════

local function getMorseSlots()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local ui = pg:FindFirstChild("MorseCodeUI")
    if not ui then return nil end
    local panel = ui:FindFirstChild("Panel")
    if not panel then return nil end
    local container = panel:FindFirstChild("SlotContainer")
    if not container then return nil end
    local slots = {}
    for i = 1, 5 do
        local slot = container:FindFirstChild("Slot"..i)
        if slot then slots[i] = slot:FindFirstChild("DigitInput") end
    end
    return slots
end

local function writeToMorseSlots(code)
    local slots = getMorseSlots()
    if not slots then return false end
    for i = 1, math.min(#code, 5) do
        if slots[i] then
            slots[i].Text = code:sub(i,i)
            pcall(function()
                slots[i]:CaptureFocus()
                slots[i].Text = code:sub(i,i)
                slots[i]:ReleaseFocus(true)
            end)
        end
    end
    return true
end

local function getNotesUI()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local notes = pg:FindFirstChild("Notes")
    if not notes then return nil end
    local img = notes:FindFirstChild("ImageLabel")
    if not img then return nil end
    return img:FindFirstChild("ScrollingFrame")
end

local function captureClueText(timeout)
    timeout = timeout or 35
    local t0 = tick()
    local lastText, stable = "", 0
    while tick() - t0 < timeout do
        local sf = getNotesUI()
        if sf then
            local parts = {}
            for _, c in ipairs(sf:GetChildren()) do
                if c:IsA("TextLabel") and c.Text and #c.Text > 0 then
                    table.insert(parts, c.Text)
                end
            end
            local full = table.concat(parts, "")
            if #full > 0 then
                if full == lastText then
                    stable = stable + 1
                    if stable >= 60 then return full end
                else stable = 0; lastText = full end
            end
        end
        task.wait(0.05)
    end
    return lastText
end

local function waitNotesClose(timeout)
    timeout = timeout or 10
    local t0 = tick()
    while tick() - t0 < timeout do
        local sf = getNotesUI()
        if not sf then return true end
        local has = false
        for _, c in ipairs(sf:GetChildren()) do
            if c:IsA("TextLabel") and c.Visible and #c.Text > 0 then has = true; break end
        end
        if not has then return true end
        task.wait(0.1)
    end
    return false
end

--// ═══════════════════════════════════════════════
--// PETER PUZZLE SOLVERS
--// ═══════════════════════════════════════════════

local function solveBinary(text)
    for bin in text:gmatch("[:%s]([01][01][01][01]+)") do
        local d = tonumber(bin, 2)
        if d and d >= 0 and d <= 9 then return tostring(d), "bin "..bin.."="..d end
    end
    local bin = text:match("^([01][01][01][01]+)")
    if bin then
        local d = tonumber(bin, 2)
        if d and d >= 0 and d <= 9 then return tostring(d), "bin "..bin.."="..d end
    end
    return nil, "no binary"
end

local function solveMorse(text)
    for m in text:gmatch("[%.%-][%.%-][%.%-][%.%-][%.%-]+") do
        local f = m:sub(1,5)
        if morseToNumber[f] then return morseToNumber[f], "morse "..f.."="..morseToNumber[f] end
    end
    for m in text:gmatch("[%.%-]+") do
        if #m >= 5 then
            local f = m:sub(1,5)
            if morseToNumber[f] then return morseToNumber[f], "morse "..f.."="..morseToNumber[f] end
        end
    end
    return nil, "no morse"
end

local function solveMorseReversed(text)
    for m in text:gmatch("[%.%-]+") do
        if #m >= 5 then
            local r = string.reverse(m:sub(1,5))
            if morseToNumber[r] then return morseToNumber[r], "rev "..m:sub(1,5).."→"..r.."="..morseToNumber[r] end
        end
    end
    return nil, "no rev morse"
end

local function solveMath(text)
    -- "N^M = ?" or "N^M" standalone power expression (MUST be before other patterns)
    -- Match at start or after whitespace/colon to avoid matching "ke-3" etc
    for base, exp in text:gmatch("(%d+)%^(%d+)") do
        local b, e = tonumber(base), tonumber(exp)
        if b and e and b <= 20 and e <= 10 then
            local r = b ^ e
            if r >= 0 and r <= 9999 then
                return tostring(math.floor(r)), base.."^"..exp.."="..math.floor(r)
            end
        end
    end

    -- "N pangkat M" in Indonesian
    local base2, exp2 = text:lower():match("(%d+)%s*pangkat%s*(%d+)")
    if base2 and exp2 then
        local b, e = tonumber(base2), tonumber(exp2)
        local r = b ^ e
        return tostring(math.floor(r)), base2.." pangkat "..exp2.."="..math.floor(r)
    end

    -- Also handle written numbers: "tiga pangkat dua" etc
    local wordToNum = {
        nol=0,satu=1,dua=2,tiga=3,empat=4,lima=5,
        enam=6,tujuh=7,delapan=8,sembilan=9,sepuluh=10
    }
    local tl = text:lower()
    for w1, w2 in tl:gmatch("(%a+)%s+pangkat%s+(%a+)") do
        local b, e = wordToNum[w1], wordToNum[w2]
        if b and e then
            local r = b ^ e
            return tostring(math.floor(r)), w1.." pangkat "..w2.."="..math.floor(r)
        end
    end

    -- d/dx [x^N] saat x=M
    local n, m = text:match("d/dx%s*%[?x%^(%d+)%]?%s*saat%s*x%s*=%s*(%d+)")
    if n and m then
        n, m = tonumber(n), tonumber(m)
        local r = n * m^(n-1)
        return tostring(r), "d/dx x^"..n.." at "..m.."="..r
    end

    -- Nx^M dievaluasi di K
    local co, ex, va = text:match("(%d+)x%^(%d+)%s*dievaluasi%s*di%s*(%d+)")
    if co and ex and va then
        co, ex, va = tonumber(co), tonumber(ex), tonumber(va)
        local r = co * va^ex
        return tostring(r), co.."*"..va.."^"..ex.."="..r
    end

    -- sqrt
    local sq = text:match("sqrt%((%d+)%)") or text:match("akar%s+(%d+)")
    if sq then
        local r = math.sqrt(tonumber(sq))
        if r == math.floor(r) then return tostring(math.floor(r)), "sqrt("..sq..")="..math.floor(r) end
    end

    -- N + M, N - M, N * M, N × M
    local a, op, b = text:match("(%d+)%s*([%+%-%*×/])%s*(%d+)%s*=")
    if a and op and b then
        a, b = tonumber(a), tonumber(b)
        local r
        if op == "+" then r = a + b
        elseif op == "-" then r = a - b
        elseif op == "*" or op == "×" then r = a * b
        elseif op == "/" and b ~= 0 then r = a / b end
        if r and r == math.floor(r) then
            return tostring(math.floor(r)), a..op..b.."="..math.floor(r)
        end
    end

    -- "jawaban" patterns
    local ans = text:match("[Jj]awabannya%s+adalah%s+(%d+)") or text:match("[Jj]awaban%s*:%s*(%d+)")
    if ans then return ans, "answer="..ans end

    return nil, "no math"
end

local function solveCS(text)
    local tl = text:lower()
    local hex = text:match("0x(%x+)")
    if hex then
        local d = tonumber(hex, 16)
        if d then
            if tl:find("lower") and tl:find("nibble") then
                local r = d % 16
                return tostring(r), "lower nibble 0x"..hex.."="..r
            elseif tl:find("upper") and tl:find("nibble") then
                local r = math.floor(d/16)
                return tostring(r), "upper nibble 0x"..hex.."="..r
            elseif d >= 0 and d <= 9 then
                return tostring(d), "0x"..hex.."="..d
            end
        end
    end
    if tl:find("nibble") and tl:find("bit") then return "4", "nibble=4 bits" end
    if tl:find("byte") and tl:find("bit") then return "8", "byte=8 bits" end
    return solveBinary(text)
end

local function autoSolveClue(idx, text)
    if not text or #text < 3 then return nil, "no text" end
    local solvers = {
        [1] = {solveBinary, solveMorse, solveMath, solveCS, solveMorseReversed},
        [2] = {solveMorse, solveBinary, solveMath, solveCS, solveMorseReversed},
        [3] = {solveMath, solveBinary, solveMorse, solveCS, solveMorseReversed},
        [4] = {solveCS, solveBinary, solveMorse, solveMath, solveMorseReversed},
        [5] = {solveMorseReversed, solveMorse, solveBinary, solveMath, solveCS},
    }
    for _, fn in ipairs(solvers[idx] or solvers[1]) do
        local d, info = fn(text)
        if d then return d, info end
    end
    return nil, "all failed"
end

--// ═══════════════════════════════════════════════
--// TELEPORT HELPERS
--// ═══════════════════════════════════════════════

local function hoverTeleport(targetPos)
    hrp.CFrame = CFrame.new(Vector3.new(targetPos.X, targetPos.Y + 20, targetPos.Z))
    hrp.Velocity = Vector3.new(0,0,0)
    task.wait(0.3)
    hrp.CFrame = CFrame.new(Vector3.new(targetPos.X, targetPos.Y + 2, targetPos.Z))
    hrp.Velocity = Vector3.new(0,0,0)
    task.wait(0.8)
end

local function teleportNear(model, offset)
    offset = offset or Vector3.new(0,0,3)
    local part
    if model:IsA("BasePart") then part = model
    elseif model:IsA("Model") then part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) end
    if not part then return false end
    local pos = part.Position + offset
    hoverTeleport(pos)
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(part.Position.X, hrp.Position.Y, part.Position.Z))
    return true
end

--// ═══════════════════════════════════════════════
--// GUI
--// ═══════════════════════════════════════════════

for _, n in ipairs({"DanurFullAuto","DanurAutoV2","DanurAutoV3","DanurAutoV4","DanurAutoV5","DanurPeterSolver","DanurCombined"}) do
    local o = game.CoreGui:FindFirstChild(n)
    if o then o:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "DanurCombined"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local function create(cls, props, ch)
    local inst = Instance.new(cls)
    for k,v in pairs(props or {}) do inst[k]=v end
    for _,c in ipairs(ch or {}) do c.Parent=inst end
    return inst
end

local function tw(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quad), props):Play()
end

local C = {
    bg       = Color3.fromRGB(8,8,12),
    surface  = Color3.fromRGB(16,16,22),
    surface2 = Color3.fromRGB(24,24,32),
    border   = Color3.fromRGB(34,34,44),
    text     = Color3.fromRGB(210,210,220),
    dim      = Color3.fromRGB(80,80,100),
    red      = Color3.fromRGB(180,50,50),
    green    = Color3.fromRGB(40,165,70),
    orange   = Color3.fromRGB(200,145,30),
    blue     = Color3.fromRGB(50,115,200),
    purple   = Color3.fromRGB(120,65,180),
    idle     = Color3.fromRGB(44,44,56),
}

-- MAIN FRAME (optimized for 1280x720 / LDCloud Kvip10)
-- Width: ~38% of screen, Height: ~92% of screen height
local mainFrame = create("Frame", {
    Size = UDim2.new(0.38, 0, 0.92, 0),
    Position = UDim2.new(0.01, 0, 0.04, 0),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0, Active = true, Draggable = true,
    ClipsDescendants = true, Parent = gui,
}, {
    create("UICorner", {CornerRadius = UDim.new(0,8)}),
    create("UIStroke", {Color = C.border, Thickness = 1}),
})

-- TITLE BAR
local titleBar = create("Frame", {
    Size=UDim2.new(1,0,0,28), BackgroundColor3=C.surface,
    BorderSizePixel=0, Parent=mainFrame,
}, {create("UICorner",{CornerRadius=UDim.new(0,8)})})
create("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),
    BackgroundColor3=C.surface,BorderSizePixel=0,Parent=titleBar})
create("TextLabel",{
    Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,8,0,0),
    Text="👻 DANUR PT.2 — FULL AUTO",Font=Enum.Font.GothamBold,TextSize=10,
    TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1,Parent=titleBar,
})
local closeBtn = create("TextButton",{
    Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-24,0,4),Text="✕",
    Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.dim,
    BackgroundColor3=C.bg,BorderSizePixel=0,Parent=titleBar,
},{create("UICorner",{CornerRadius=UDim.new(0,4)})})
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local content = create("Frame",{
    Size=UDim2.new(1,-12,1,-34),Position=UDim2.new(0,6,0,30),
    BackgroundTransparency=1,Parent=mainFrame,
})

-- PHASE INDICATOR (6 phases)
local PHASES = {
    {icon="📡", name="MORSE SCAN", short="SCAN"},
    {icon="🚪", name="HENDRICK DOOR", short="DOOR"},
    {icon="🎬", name="CUTSCENE", short="CUT"},
    {icon="🔍", name="PETER CLUES", short="CLUE"},
    {icon="🔑", name="PETER DOOR", short="KEY"},
    {icon="📝", name="PETER NOTE", short="NOTE"},
}

local phaseRow = create("Frame",{
    Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,0),
    BackgroundTransparency=1,Parent=content,
})

local phaseBoxes = {}
local phaseLabels = {}

for i, ph in ipairs(PHASES) do
    local box = create("Frame",{
        Size=UDim2.new(1/6,-3,0,30),Position=UDim2.new((i-1)/6,0,0,0),
        BackgroundColor3=C.surface,BorderSizePixel=0,Parent=phaseRow,
    },{
        create("UICorner",{CornerRadius=UDim.new(0,4)}),
        create("UIStroke",{Color=C.idle,Thickness=1}),
    })
    create("TextLabel",{
        Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,0),
        Text=ph.icon,TextSize=9,BackgroundTransparency=1,Parent=box,
    })
    local lbl = create("TextLabel",{
        Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,16),
        Text=ph.short,Font=Enum.Font.GothamBold,TextSize=6,
        TextColor3=C.dim,BackgroundTransparency=1,Parent=box,
    })
    phaseBoxes[i] = box
    phaseLabels[i] = lbl
end

-- STATUS
local statusLabel = create("TextLabel",{
    Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,34),
    Text="⏳  READY",Font=Enum.Font.GothamMedium,TextSize=8,
    TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1,Parent=content,TextTruncate=Enum.TextTruncate.AtEnd,
})

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or C.dim
end

local function setPhase(idx, state) -- state: "idle","active","done","error"
    local colors = {idle=C.idle, active=C.orange, done=C.green, error=C.red}
    local stroke = phaseBoxes[idx]:FindFirstChildOfClass("UIStroke")
    if stroke then tw(stroke, {Color=colors[state] or C.idle}, 0.2) end
    phaseLabels[idx].TextColor3 = colors[state] or C.dim
end

-- MORSE RADIO INDICATORS (5 boxes)
local radioRow = create("Frame",{
    Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,57),
    BackgroundTransparency=1,Parent=content,
})
create("TextLabel",{
    Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,-11),
    Text="MORSE RADIOS",Font=Enum.Font.GothamBold,TextSize=7,
    TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1,Parent=radioRow,
})

local radioDigits = {}
local radioBoxes = {}

for i = 1, 5 do
    local box = create("Frame",{
        Size=UDim2.new(1/5,-3,0,36),Position=UDim2.new((i-1)/5,0,0,0),
        BackgroundColor3=C.surface,BorderSizePixel=0,Parent=radioRow,
    },{
        create("UICorner",{CornerRadius=UDim.new(0,4)}),
        create("UIStroke",{Color=C.idle,Thickness=1}),
    })
    create("TextLabel",{
        Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,1),
        Text="R"..i,Font=Enum.Font.GothamMedium,TextSize=7,
        TextColor3=C.dim,BackgroundTransparency=1,Parent=box,
    })
    local digit = create("TextLabel",{
        Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,12),
        Text="—",Font=Enum.Font.GothamBold,TextSize=16,
        TextColor3=C.dim,BackgroundTransparency=1,Parent=box,
    })
    radioBoxes[i] = box
    radioDigits[i] = digit
end

-- MORSE CODE DISPLAY
local morseCodeBg = create("Frame",{
    Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,97),
    BackgroundColor3=C.surface,BorderSizePixel=0,Parent=content,
},{create("UICorner",{CornerRadius=UDim.new(0,4)})})
create("TextLabel",{
    Size=UDim2.new(0,42,1,0),Position=UDim2.new(0,6,0,0),
    Text="MORSE",Font=Enum.Font.GothamBold,TextSize=7,TextColor3=C.dim,
    TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
    Parent=morseCodeBg,
})
local morseCodeLabel = create("TextLabel",{
    Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,48,0,0),
    Text="— — — — —",Font=Enum.Font.Code,TextSize=14,TextColor3=C.dim,
    TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
    Parent=morseCodeBg,
})

-- PETER CLUE INDICATORS (5 boxes)
local clueRow = create("Frame",{
    Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,129),
    BackgroundTransparency=1,Parent=content,
})
create("TextLabel",{
    Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,-11),
    Text="PETER CLUES",Font=Enum.Font.GothamBold,TextSize=7,
    TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1,Parent=clueRow,
})

local CLUE_NAMES = {"BIN","MRS","MTH","CS","REV"}
local clueDigits = {}
local clueBoxes = {}

for i = 1, 5 do
    local box = create("Frame",{
        Size=UDim2.new(1/5,-3,0,36),Position=UDim2.new((i-1)/5,0,0,0),
        BackgroundColor3=C.surface,BorderSizePixel=0,Parent=clueRow,
    },{
        create("UICorner",{CornerRadius=UDim.new(0,4)}),
        create("UIStroke",{Color=C.idle,Thickness=1}),
    })
    create("TextLabel",{
        Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,1),
        Text=CLUE_NAMES[i],Font=Enum.Font.GothamMedium,TextSize=6,
        TextColor3=C.purple,BackgroundTransparency=1,Parent=box,
    })
    local digit = create("TextLabel",{
        Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,12),
        Text="—",Font=Enum.Font.GothamBold,TextSize=16,
        TextColor3=C.dim,BackgroundTransparency=1,Parent=box,
    })
    clueBoxes[i] = box
    clueDigits[i] = digit
end

-- PETER CODE DISPLAY
local peterCodeBg = create("Frame",{
    Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,169),
    BackgroundColor3=C.surface,BorderSizePixel=0,Parent=content,
},{create("UICorner",{CornerRadius=UDim.new(0,4)})})
create("TextLabel",{
    Size=UDim2.new(0,42,1,0),Position=UDim2.new(0,6,0,0),
    Text="PETER",Font=Enum.Font.GothamBold,TextSize=7,TextColor3=C.dim,
    TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
    Parent=peterCodeBg,
})
local peterCodeLabel = create("TextLabel",{
    Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,48,0,0),
    Text="— — — — —",Font=Enum.Font.Code,TextSize=14,TextColor3=C.dim,
    TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
    Parent=peterCodeBg,
})

-- PROGRESS BAR
local progBg = create("Frame",{
    Size=UDim2.new(1,0,0,3),Position=UDim2.new(0,0,0,195),
    BackgroundColor3=C.surface,BorderSizePixel=0,ClipsDescendants=true,
    Parent=content,
},{create("UICorner",{CornerRadius=UDim.new(0,2)})})
local progFill = create("Frame",{
    Size=UDim2.new(0,0,1,0),BackgroundColor3=C.red,
    BorderSizePixel=0,Parent=progBg,
},{create("UICorner",{CornerRadius=UDim.new(0,2)})})

local function setProgress(f, c)
    tw(progFill, {Size=UDim2.new(math.clamp(f,0,1),0,1,0), BackgroundColor3=c or C.red}, 0.3)
end

-- LOG AREA (fills remaining space)
local logBg = create("Frame",{
    Size=UDim2.new(1,0,1,-240),Position=UDim2.new(0,0,0,202),
    BackgroundColor3=C.surface,BorderSizePixel=0,ClipsDescendants=true,
    Parent=content,
},{create("UICorner",{CornerRadius=UDim.new(0,4)})})
create("TextLabel",{
    Size=UDim2.new(1,0,0,11),Position=UDim2.new(0,4,0,1),
    Text="ACTIVITY LOG",Font=Enum.Font.GothamBold,TextSize=6,
    TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,
    BackgroundTransparency=1,Parent=logBg,
})
local logScroll = create("ScrollingFrame",{
    Size=UDim2.new(1,-4,1,-14),Position=UDim2.new(0,2,0,12),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=2,ScrollBarImageColor3=C.idle,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    Parent=logBg,
},{create("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,1)})})

local logCount = 0
local function addLog(text, color)
    logCount = logCount + 1
    create("TextLabel",{
        Size=UDim2.new(1,0,0,11),
        Text=os.date("%H:%M:%S").."  "..text,
        Font=Enum.Font.Code,TextSize=7,
        TextColor3=color or C.text,
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,TextWrapped=true,
        AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=logCount,
        Parent=logScroll,
    })
    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
    end)
end

-- START BUTTON (anchored to bottom)
local startBtn = create("TextButton",{
    Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-34),
    Text="",BackgroundColor3=Color3.fromRGB(45,16,16),
    BorderSizePixel=0,AutoButtonColor=false,Parent=content,
},{
    create("UICorner",{CornerRadius=UDim.new(0,6)}),
    create("UIStroke",{Color=C.red,Thickness=1}),
})
local startLbl = create("TextLabel",{
    Size=UDim2.new(1,0,1,0),
    Text="🔥  START FULL AUTO",
    Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.text,
    BackgroundTransparency=1,Parent=startBtn,
})
startBtn.MouseEnter:Connect(function()
    tw(startBtn,{BackgroundColor3=Color3.fromRGB(60,20,20)},0.15)
end)
startBtn.MouseLeave:Connect(function()
    tw(startBtn,{BackgroundColor3=Color3.fromRGB(45,16,16)},0.15)
end)

--// ═══════════════════════════════════════════════
--// UI HELPERS
--// ═══════════════════════════════════════════════

local function setRadioDigit(i, digit, ok)
    radioDigits[i].Text = digit
    radioDigits[i].TextColor3 = ok and C.green or C.red
    local s = radioBoxes[i]:FindFirstChildOfClass("UIStroke")
    if s then tw(s, {Color = ok and C.green or C.red}, 0.2) end
end

local function setClueDigit(i, digit, ok)
    clueDigits[i].Text = digit
    clueDigits[i].TextColor3 = ok and C.green or C.red
    local s = clueBoxes[i]:FindFirstChildOfClass("UIStroke")
    if s then tw(s, {Color = ok and C.green or C.red}, 0.2) end
end

local function displayCode(label, code)
    local sp = {}
    for i = 1, #code do sp[i] = code:sub(i,i) end
    label.Text = table.concat(sp, " ")
    label.TextColor3 = code:find("%?") and C.orange or C.green
end

--// ═══════════════════════════════════════════════
--// MAIN AUTO SEQUENCE
--// ═══════════════════════════════════════════════

local running = false

local function runFullAuto()
    if running then return end
    running = true
    startBtn.Active = false
    startLbl.TextColor3 = C.dim

    --────────────────────────────────────
    -- PHASE 1: MORSE SCAN
    --────────────────────────────────────
    setPhase(1, "active")
    setStatus("📡  PHASE 1: Scanning morse radios...", C.orange)
    addLog("PHASE 1: Scanning "..RADIO_COUNT.." radios ("..SCAN_DURATION.."s)", C.orange)

    for i = 1, 5 do
        radioDigits[i].Text = "..."
        radioDigits[i].TextColor3 = C.orange
    end

    local scanned = 0
    local morseCode, morseResults = scanAllRadios(function(i, data)
        local ok = data.digit ~= "?"
        setRadioDigit(i, data.digit, ok)
        scanned = scanned + 1
        setProgress(scanned / 30, C.orange) -- phase 1 = first ~16% of total
        addLog("  R"..i..": "..data.digit.." ("..data.info..")", ok and C.green or C.red)
    end)

    displayCode(morseCodeLabel, morseCode)

    if morseCode:find("%?") then
        setPhase(1, "error")
        setStatus("❌  Morse scan failed: "..morseCode, C.red)
        addLog("MORSE FAILED: "..morseCode, C.red)
        running = false; startBtn.Active = true; startLbl.TextColor3 = C.text
        return
    end

    setPhase(1, "done")
    addLog("MORSE CODE: "..morseCode, C.green)

    --────────────────────────────────────
    -- PHASE 2: HENDRICK DOOR
    --────────────────────────────────────
    setPhase(2, "active")
    setStatus("🚪  PHASE 2: Going to Hendrick door...", C.blue)
    addLog("PHASE 2: Hendrick door", C.blue)
    setProgress(6/30, C.blue)

    hoverTeleport(Vector3.new(-1756.57, -10.30, -1866.81))
    local doorPos = hendrickDoor:GetPivot().Position
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(doorPos.X, hrp.Position.Y, doorPos.Z))
    task.wait(0.5)

    addLog("  Triggering door prompt...", C.dim)
    fireproximityprompt(hendrickPrompt)
    task.wait(1.5)

    addLog("  Filling morse slots: "..morseCode, C.dim)
    writeToMorseSlots(morseCode)
    task.wait(0.3)

    addLog("  Submitting code...", C.dim)
    morseRemote:FireServer(unpack({morseCode}))
    task.wait(2)
    setProgress(8/30, C.blue)

    setPhase(2, "done")
    addLog("  Code submitted!", C.green)

    --────────────────────────────────────
    -- PHASE 3: HENDRICK NOTE + CUTSCENE
    --────────────────────────────────────
    setPhase(3, "active")
    setStatus("📝  PHASE 3: Going to Hendrick note...", C.blue)
    addLog("PHASE 3: Hendrick note + cutscene", C.blue)

    hoverTeleport(Vector3.new(-1771.89, -10.32, -1865.50))
    local notePos = hendrickNote:GetPivot().Position
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(notePos.X, hrp.Position.Y, notePos.Z))
    task.wait(0.5)

    fireproximityprompt(hendrickNotePrompt)
    addLog("  Note triggered, cutscene starting...", C.dim)

    local cutT0 = tick()
    while tick() - cutT0 < CUTSCENE_DURATION do
        local rem = math.ceil(CUTSCENE_DURATION - (tick()-cutT0))
        local frac = 8/30 + ((tick()-cutT0)/CUTSCENE_DURATION) * (7/30)
        setProgress(frac, C.dim)
        setStatus("🎬  CUTSCENE... "..rem.."s remaining", C.dim)
        task.wait(1)
    end

    setPhase(3, "done")
    addLog("  Cutscene complete!", C.green)

    --────────────────────────────────────
    -- PHASE 4: PETER CLUES
    --────────────────────────────────────
    setPhase(4, "active")
    setStatus("🔍  PHASE 4: Solving Peter clues...", C.purple)
    addLog("PHASE 4: Peter clues (5 clues)", C.purple)

    local peterDigits = {"?","?","?","?","?"}

    for i = 1, 5 do
        local digit, info
        local attempt = 0

        repeat
            attempt = attempt + 1
            if attempt > 1 then
                addLog("  C"..i..": retry #"..attempt, C.orange)
                task.wait(2)
            end

            setStatus("🔍  Clue "..i.."/5".. (attempt > 1 and " (retry)" or "") .."...", C.purple)
            addLog("  C"..i..": teleporting...", C.dim)

            local clue = peterScene:FindFirstChild("Clue_Code_"..i)
            if not clue then
                info = "not found"; break
            end

            teleportNear(clue, Vector3.new(0,0,3))
            task.wait(0.5)

            waitNotesClose(5)
            task.wait(0.5)

            local prompt = clue:FindFirstChild("Prompt")
            if prompt then fireproximityprompt(prompt) end
            task.wait(2)

            addLog("  C"..i..": capturing text...", C.dim)
            local text = captureClueText(35)

            if text and #text >= 3 then
                digit, info = autoSolveClue(i, text)
                addLog("  C"..i..": "..text:sub(1,60), C.dim)
            else
                info = "no text"
            end

            waitNotesClose(8)
            task.wait(2)

        until (digit and digit ~= "?") or attempt >= (1 + MAX_CLUE_RETRIES)

        peterDigits[i] = digit or "?"
        local ok = digit and digit ~= "?"
        setClueDigit(i, digit or "?", ok)
        addLog("  C"..i.." = "..(digit or "?").." ("..(info or "")..")", ok and C.green or C.red)

        setProgress(15/30 + i/30, C.purple)
    end

    local peterCode = table.concat(peterDigits)
    displayCode(peterCodeLabel, peterCode)

    if peterCode:find("%?") then
        setPhase(4, "error")
        setStatus("❌  Peter clues incomplete: "..peterCode, C.red)
        addLog("PETER CLUES FAILED: "..peterCode, C.red)
        running = false; startBtn.Active = true; startLbl.TextColor3 = C.text
        return
    end

    setPhase(4, "done")
    addLog("PETER CODE: "..peterCode, C.green)

    --────────────────────────────────────
    -- PHASE 5: PETER DOOR + KEYPAD
    --────────────────────────────────────
    setPhase(5, "active")
    setStatus("🔑  PHASE 5: Peter door + keypad...", C.blue)
    addLog("PHASE 5: Peter door submit: "..peterCode, C.blue)
    setProgress(22/30, C.blue)

    teleportNear(peterDoor, Vector3.new(0,0,3))
    task.wait(1)

    fireproximityprompt(peterDoorPrompt)
    task.wait(2)

    -- Submit code via CalculusCursed.SubmitDoorCode (InvokeServer)
    -- Format: table of individual digit numbers {1, 5, 9, 5, 4}
    local codeDigits = {}
    for i = 1, #peterCode do
        table.insert(codeDigits, tonumber(peterCode:sub(i, i)))
    end

    addLog("  Sending digits: {"..table.concat(codeDigits, ",").."}", C.dim)

    local submitSuccess = false
    pcall(function()
        local calcCursed = ReplicatedStorage:WaitForChild("CalculusCursed", 5)
        if calcCursed then
            local submitRemote = calcCursed:WaitForChild("SubmitDoorCode", 5)
            if submitRemote then
                local result = submitRemote:InvokeServer(codeDigits)
                addLog("  InvokeServer result: "..tostring(result), C.dim)
                submitSuccess = true
            else
                addLog("  SubmitDoorCode not found!", C.red)
            end
        else
            addLog("  CalculusCursed not found!", C.red)
        end
    end)

    task.wait(2)
    setPhase(5, "done")
    setProgress(26/30, C.blue)
    addLog("  Door submitted!", C.green)

    --────────────────────────────────────
    -- PHASE 6: PETER NOTE
    --────────────────────────────────────
    setPhase(6, "active")
    setStatus("📝  PHASE 6: Peter note...", C.blue)
    addLog("PHASE 6: Peter note", C.blue)

    teleportNear(peterNote, Vector3.new(0,0,3))
    task.wait(1)

    fireproximityprompt(peterNotePrompt)
    task.wait(3)

    setPhase(6, "done")
    setProgress(1, C.green)

    --────────────────────────────────────
    -- DONE!
    --────────────────────────────────────
    setStatus("✅  ALL COMPLETE! Danur Part 2 finished.", C.green)
    addLog("═══ ALL PHASES COMPLETE! ═══", C.green)

    -- Pulse all phases green
    for i = 1, 6 do setPhase(i, "done") end

    running = false
    startLbl.Text = "✅  COMPLETED"
end

startBtn.MouseButton1Click:Connect(runFullAuto)

-- ENTRANCE
local targetSize = mainFrame.Size
mainFrame.Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = targetSize
}):Play()

setStatus("⏳  Press START to begin full automation", C.dim)
addLog("Danur Part 2 Full Auto loaded", C.dim)
addLog("Press START to begin all 6 phases", C.dim)
