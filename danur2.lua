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

-- Network module (for intercepting clue text directly from server)
local NetworkModule = nil
pcall(function()
    NetworkModule = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("Network", 5))
end)

--// CLUE INTERCEPT SYSTEM
-- When server sends OpenClue event, we capture the text instantly
local interceptedClue = {index = nil, text = nil, received = false}

if NetworkModule then
    NetworkModule.OnClientEvent("OpenClue", function(clueIndex, clueText)
        interceptedClue.index = clueIndex
        interceptedClue.text = clueText
        interceptedClue.received = true
        print("[INTERCEPT] Clue "..tostring(clueIndex)..": "..tostring(clueText):sub(1,100))
    end)
end

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
    -- Match "0b" prefix binary: 0b0100, 0b1001, etc
    local binPrefixed = text:match("0b([01]+)")
    if binPrefixed and #binPrefixed >= 4 then
        local d = tonumber(binPrefixed, 2)
        if d and d >= 0 and d <= 9 then return tostring(d), "0b"..binPrefixed.."="..d end
    end

    -- Match standalone binary after : or space
    for bin in text:gmatch("[:%s=]%s*([01][01][01][01]+)") do
        -- Skip if it's part of 0b prefix (already handled above)
        if not text:find("0b"..bin) then
            local d = tonumber(bin, 2)
            if d and d >= 0 and d <= 9 then return tostring(d), "bin "..bin.."="..d end
        end
    end

    -- Match at start of text
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
    local tl = text:lower()

    -- Word-to-number map (Indonesian + English)
    local wordToNum = {
        nol=0,satu=1,dua=2,tiga=3,empat=4,lima=5,
        enam=6,tujuh=7,delapan=8,sembilan=9,sepuluh=10,
        sebelas=11,
        zero=0,one=1,two=2,three=3,four=4,five=5,
        six=6,seven=7,eight=8,nine=9,ten=10,
        eleven=11,twelve=12,
    }

    -- WELL-KNOWN CALCULUS RESULTS (must be before generic patterns)
    -- d/dx [x] = 1 (coefficient of x)
    if tl:find("d/dx") and tl:find("%[x%]") and not tl:find("x%^") then
        return "1", "d/dx[x]=1"
    end

    -- d/dx [Nx] = N (coefficient)
    local coefN = text:match("d/dx%s*%[(%d+)x%]")
    if coefN then
        return coefN, "d/dx["..coefN.."x]="..coefN
    end

    -- lim(x->0) sin(x)/x = 1
    if tl:find("lim") and tl:find("sin") and tl:find("/x") then
        return "1", "lim sin(x)/x=1"
    end

    -- lim(x->0) (1-cos(x))/x = 0
    if tl:find("lim") and tl:find("cos") and tl:find("/x") then
        return "0", "lim (1-cos(x))/x=0"
    end

    -- lim(x->0) tan(x)/x = 1
    if tl:find("lim") and tl:find("tan") and tl:find("/x") then
        return "1", "lim tan(x)/x=1"
    end

    -- lim(x->0) (e^x - 1)/x = 1
    if tl:find("lim") and tl:find("e%^x") then
        return "1", "lim (e^x-1)/x=1"
    end

    -- d/dx [sin(x)] = cos(x) → at x=0 → 1
    if tl:find("d/dx") and tl:find("sin") then
        -- derivative of sin(x) = cos(x), at x=0 cos(0)=1
        local atX = text:match("at%s*x%s*=%s*(%d+)") or text:match("saat%s*x%s*=%s*(%d+)")
        if atX then
            local r = math.cos(math.rad(tonumber(atX)))
            -- But usually x is in radians and at x=0, cos(0)=1
            if tonumber(atX) == 0 then return "1", "d/dx sin(x) at 0=cos(0)=1" end
        end
    end

    -- d/dx [cos(x)] = -sin(x) → at x=0 → 0
    if tl:find("d/dx") and tl:find("cos") then
        local atX = text:match("at%s*x%s*=%s*(%d+)") or text:match("saat%s*x%s*=%s*(%d+)")
        if atX and tonumber(atX) == 0 then return "0", "d/dx cos(x) at 0=-sin(0)=0" end
    end

    -- d/dx [e^x] = e^x → at x=0 → 1
    if tl:find("d/dx") and tl:find("e%^x") then
        return "1", "d/dx e^x=e^x, at 0=1"
    end

    -- d/dx [ln(x)] = 1/x → at x=1 → 1
    if tl:find("d/dx") and (tl:find("ln") or tl:find("log")) then
        local atX = text:match("at%s*x%s*=%s*(%d+)") or text:match("saat%s*x%s*=%s*(%d+)")
        if atX then
            local x = tonumber(atX)
            if x and x > 0 then
                local r = math.floor(1/x)
                if 1/x == r then return tostring(r), "d/dx ln(x) at "..x.."=1/"..x.."="..r end
            end
        end
    end

    -- "N^M = ?" or "N^M" power expression
    for base, exp in text:gmatch("(%d+)%s*%^%s*(%d+)") do
        local b, e = tonumber(base), tonumber(exp)
        if b and e and b <= 100 and e <= 10 then
            local r = math.floor(b ^ e)
            return tostring(r), base.."^"..exp.."="..r
        end
    end

    -- "N pangkat M" / "N to the power of M" / "N power M" (angka)
    local base2, exp2 = tl:match("(%d+)%s*pangkat%s*(%d+)")
    if not base2 then base2, exp2 = tl:match("(%d+)%s*to the power of%s*(%d+)") end
    if not base2 then base2, exp2 = tl:match("(%d+)%s*power%s*(%d+)") end
    if not base2 then base2, exp2 = tl:match("(%d+)%s*raised to%s*(%d+)") end
    if base2 and exp2 then
        local r = math.floor(tonumber(base2) ^ tonumber(exp2))
        return tostring(r), base2.." pangkat "..exp2.."="..r
    end

    -- "tiga pangkat dua" / "three to the power of two" (kata)
    for w1, w2 in tl:gmatch("(%a+)%s+pangkat%s+(%a+)") do
        local b, e = wordToNum[w1], wordToNum[w2]
        if b and e then
            local r = math.floor(b ^ e)
            return tostring(r), w1.." pangkat "..w2.."="..r
        end
    end
    for w1, w2 in tl:gmatch("(%a+)%s+to the power of%s+(%a+)") do
        local b, e = wordToNum[w1], wordToNum[w2]
        if b and e then
            local r = math.floor(b ^ e)
            return tostring(r), w1.." ^ "..w2.."="..r
        end
    end
    for w1, w2 in tl:gmatch("(%a+)%s+squared") do
        local b = wordToNum[w1]
        if b then return tostring(math.floor(b^2)), w1.." squared="..math.floor(b^2) end
    end
    for w1 in tl:gmatch("(%a+)%s+cubed") do
        local b = wordToNum[w1]
        if b then return tostring(math.floor(b^3)), w1.." cubed="..math.floor(b^3) end
    end

    -- d/dx [Cx^N] saat x=M → C*N*x^(N-1) evaluated at M
    -- Matches: "d/dx [4x^2] saat x=1", "d/dx [3x^4] at x=2"
    local dc, dn, dm = text:match("d/dx%s*%[?(%d+)x%^(%d+)%]?%s*saat%s*x%s*=%s*(%d+)")
    if not dc then dc, dn, dm = text:match("d/dx%s*%[?(%d+)x%^(%d+)%]?%s*at%s*x%s*=%s*(%d+)") end
    if not dc then dc, dn, dm = text:match("d/dx%s*%[?(%d+)x%^(%d+)%]?%s*when%s*x%s*=%s*(%d+)") end
    if dc and dn and dm then
        dc, dn, dm = tonumber(dc), tonumber(dn), tonumber(dm)
        local r = math.floor(dc * dn * dm^(dn-1))
        return tostring(r), "d/dx "..dc.."x^"..dn.." at "..dm.."="..r
    end

    -- d/dx [x^N] saat x=M / d/dx [x^N] at x=M / when x=M
    local n, m = text:match("d/dx%s*%[?x%^(%d+)%]?%s*saat%s*x%s*=%s*(%d+)")
    if not n then n, m = text:match("d/dx%s*%[?x%^(%d+)%]?%s*at%s*x%s*=%s*(%d+)") end
    if not n then n, m = text:match("d/dx%s*%[?x%^(%d+)%]?%s*when%s*x%s*=%s*(%d+)") end
    if not n then n, m = text:match("derivative%s*of%s*x%^(%d+)%s*at%s*x%s*=%s*(%d+)") end
    if n and m then
        n, m = tonumber(n), tonumber(m)
        local r = math.floor(n * m^(n-1))
        return tostring(r), "d/dx x^"..n.." at "..m.."="..r
    end

    -- d/dx [Cx^N] saat x=M → C*N*x^(N-1) evaluated at M
    -- Matches: "d/dx [4x^2] saat x=1", "d/dx [3x^3] at x=2"
    local dC, dN, dM = text:match("d/dx%s*%[(%d+)x%^(%d+)%]%s*saat%s*x%s*=%s*(%d+)")
    if not dC then dC, dN, dM = text:match("d/dx%s*%[(%d+)x%^(%d+)%]%s*at%s*x%s*=%s*(%d+)") end
    if not dC then dC, dN, dM = text:match("d/dx%s*%[(%d+)x%^(%d+)%]%s*when%s*x%s*=%s*(%d+)") end
    if not dC then dC, dN, dM = text:match("d/dx%s*%((%d+)x%^(%d+)%)%s*saat%s*x%s*=%s*(%d+)") end
    if not dC then dC, dN, dM = text:match("d/dx%s*%((%d+)x%^(%d+)%)%s*at%s*x%s*=%s*(%d+)") end
    if dC and dN and dM then
        dC, dN, dM = tonumber(dC), tonumber(dN), tonumber(dM)
        -- derivative of Cx^N = C*N*x^(N-1)
        local r = math.floor(dC * dN * dM^(dN-1))
        return tostring(r), "d/dx "..dC.."x^"..dN.." at "..dM.."="..r
    end

    -- Also handle: "Cx dievaluasi di M" or "Cx evaluated at M" (result from derivative hint)
    -- Example: "8x dievaluasi di 1" → 8*1 = 8
    local evalC, evalM = text:match("(%d+)x%s+dievaluasi%s+di%s+(%d+)")
    if not evalC then evalC, evalM = text:match("(%d+)x%s+evaluated%s+at%s+(%d+)") end
    if evalC and evalM then
        local r = math.floor(tonumber(evalC) * tonumber(evalM))
        return tostring(r), evalC.."x at "..evalM.."="..r
    end

    -- Limits: lim(x->a) (x^N-1)/(x-1) = N*a^(N-1) when factored
    -- Common: lim(x->1) (x^2-1)/(x-1) = 2, lim(x->1) (x^3-1)/(x-1) = 3, etc
    -- General form: lim(x->a) (x^n - a^n)/(x - a) = n * a^(n-1)
    local limA, limN = tl:match("lim%s*%(x%s*[->]+%s*(%d+)%)%s*%(x%^(%d+)%-1%)%s*/%(x%-1%)")
    if limA and limN then
        local a, n = tonumber(limA), tonumber(limN)
        local r = n * a^(n-1)
        return tostring(math.floor(r)), "lim(x->"..a..") (x^"..n.."-1)/(x-1)="..math.floor(r)
    end

    -- More general limit: lim(x->a) (x^n - C)/(x - a) where C = a^n
    local limA2, limN2, limC = tl:match("lim%s*%(x%s*[->]+%s*(%d+)%)%s*%(x%^(%d+)%-(%d+)%)%s*/%(x%-")
    if limA2 and limN2 then
        local a, n = tonumber(limA2), tonumber(limN2)
        local r = n * a^(n-1)
        return tostring(math.floor(r)), "lim(x->"..a..") derivative="..math.floor(r)
    end

    -- Simple lim(x->a) (x+b) = a+b or lim(x->a) f(a)
    local limSimpleA = tl:match("lim%s*%(x%s*[->]+%s*(%d+)%)")
    if limSimpleA then
        local a = tonumber(limSimpleA)
        -- For (x^n-1)/(x-1) at x=1, the answer is always n
        -- Try to find the exponent
        local exp = text:match("x%^(%d+)")
        if exp and a == 1 then
            return exp, "lim(x->1) x^"..exp.." form="..exp
        end
        -- For (x^n - a^n)/(x-a) = n*a^(n-1)
        if exp then
            local n = tonumber(exp)
            local r = n * a^(n-1)
            if r >= 0 and r <= 999 then
                return tostring(math.floor(r)), "lim derivative="..math.floor(r)
            end
        end
    end

    -- Integral [a,b] C dx = C * (b - a)
    -- Matches: "Integral [0,3] 2 dx", "integral [1,5] 4 dx", "∫[0,3] 2 dx"
    local intA, intB, intC = tl:match("integral%s*%[(%d+)%s*[,;]%s*(%d+)%]%s*(%d+)%s*dx")
    if not intA then intA, intB, intC = tl:match("∫%s*%[(%d+)%s*[,;]%s*(%d+)%]%s*(%d+)%s*dx") end
    if not intA then intA, intB, intC = tl:match("integral%s*dari%s*(%d+)%s*sampai%s*(%d+)%s*dari%s*(%d+)") end
    if not intA then intA, intB, intC = tl:match("integral%s*from%s*(%d+)%s*to%s*(%d+)%s*of%s*(%d+)") end
    if intA and intB and intC then
        local a, b, c = tonumber(intA), tonumber(intB), tonumber(intC)
        local r = c * (b - a)
        return tostring(math.floor(r)), "∫["..a..","..b.."] "..c.." dx="..math.floor(r)
    end

    -- Also handle "Integral [a,b] x dx = (b^2 - a^2) / 2"
    local intA2, intB2 = tl:match("integral%s*%[(%d+)%s*[,;]%s*(%d+)%]%s*x%s*dx")
    if intA2 and intB2 then
        local a, b = tonumber(intA2), tonumber(intB2)
        local r = (b^2 - a^2) / 2
        if r == math.floor(r) then
            return tostring(math.floor(r)), "∫["..a..","..b.."] x dx="..math.floor(r)
        end
    end

    -- sqrt / akar / square root
    local sq = text:match("sqrt%((%d+)%)") or tl:match("akar%s*kuadrat%s*dari%s*(%d+)") or tl:match("akar%s+(%d+)") or tl:match("square%s*root%s*of%s*(%d+)") or tl:match("square%s*root%s*(%d+)")
    if sq then
        local r = math.sqrt(tonumber(sq))
        if r == math.floor(r) then return tostring(math.floor(r)), "sqrt("..sq..")="..math.floor(r) end
    end

    -- "N + M = ?", "N - M = ?", "N * M = ?", "N x M = ?", "N / M = ?"
    local a, op, b = text:match("(%d+)%s*([%+%-%*×x/])%s*(%d+)")
    if a and op and b then
        a, b = tonumber(a), tonumber(b)
        local r
        if op == "+" then r = a + b
        elseif op == "-" then r = a - b
        elseif op == "*" or op == "×" or op == "x" then r = a * b
        elseif op == "/" and b ~= 0 then r = a / b end
        if r and r == math.floor(r) then
            return tostring(math.floor(r)), a..op..b.."="..math.floor(r)
        end
    end

    -- "N dikali M" / "N multiplied by M" / "N times M" etc
    local n1, opw, n2 = tl:match("(%d+)%s+(dikali)%s+(%d+)")
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+(ditambah)%s+(%d+)") end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+(dikurang)%s+(%d+)") end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+(dibagi)%s+(%d+)") end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+multiplied%s+by%s+(%d+)"); if n1 then opw="dikali" end end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+times%s+(%d+)"); if n1 then opw="dikali" end end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+plus%s+(%d+)"); if n1 then opw="ditambah" end end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+minus%s+(%d+)"); if n1 then opw="dikurang" end end
    if not n1 then n1, opw, n2 = tl:match("(%d+)%s+divided%s+by%s+(%d+)"); if n1 then opw="dibagi" end end
    if n1 and opw and n2 then
        n1, n2 = tonumber(n1), tonumber(n2)
        local r
        if opw == "dikali" then r = n1 * n2
        elseif opw == "ditambah" then r = n1 + n2
        elseif opw == "dikurang" then r = n1 - n2
        elseif opw == "dibagi" and n2 ~= 0 then r = n1 / n2 end
        if r and r == math.floor(r) then
            return tostring(math.floor(r)), n1.." "..opw.." "..n2.."="..math.floor(r)
        end
    end

    -- Factorial: "N!" or "N faktorial"
    local fact = text:match("(%d+)%s*!")
    if not fact then fact = tl:match("(%d+)%s*faktorial") end
    if fact then
        local n = tonumber(fact)
        if n and n <= 10 then
            local r = 1
            for i = 2, n do r = r * i end
            return tostring(r), fact.."!="..r
        end
    end

    -- Modulo: "N mod M" or "N % M"
    local modA, modB = text:match("(%d+)%s*mod%s*(%d+)")
    if not modA then modA, modB = text:match("(%d+)%s*%%%s*(%d+)") end
    if modA and modB then
        local r = tonumber(modA) % tonumber(modB)
        return tostring(r), modA.." mod "..modB.."="..r
    end

    -- "log2(N)" or "log basis 2 dari N" or "log base 2 of N"
    local logVal = text:match("log2%((%d+)%)")
    if not logVal then logVal = tl:match("log%s*basis%s*2%s*dari%s*(%d+)") end
    if not logVal then logVal = tl:match("log%s*base%s*2%s*of%s*(%d+)") end
    if logVal then
        local r = math.log(tonumber(logVal)) / math.log(2)
        if r == math.floor(r) then
            return tostring(math.floor(r)), "log2("..logVal..")="..math.floor(r)
        end
    end

    -- "jawaban" / "hasil" / "answer" / "result" patterns
    local ans = text:match("[Jj]awabannya%s+adalah%s+(%d+)")
        or text:match("[Jj]awaban%s*:%s*(%d+)")
        or text:match("[Hh]asil%s*:%s*(%d+)")
        or text:match("[Hh]asilnya%s+adalah%s+(%d+)")
        or text:match("[Hh]asilnya%s*=%s*(%d+)")
        or tl:match("the%s+answer%s+is%s+(%d+)")
        or tl:match("answer%s*:%s*(%d+)")
        or tl:match("answer%s*=%s*(%d+)")
        or tl:match("result%s*:%s*(%d+)")
        or tl:match("result%s*is%s*(%d+)")
        or tl:match("equals%s+(%d+)")
        or tl:match("equal%s+to%s+(%d+)")
    if ans then return ans, "answer="..ans end

    -- ULTIMATE FALLBACK: look for "= N" anywhere (but N must be single digit for safety)
    for eq in text:gmatch("=%s*(%d+)") do
        local n = tonumber(eq)
        if n and n >= 0 and n <= 9 then
            return tostring(n), "equation result="..n
        end
    end

    -- ULTIMATE FALLBACK 2: look for any isolated single digit after "?" 
    local afterQ = text:match("%?%s*(%d)")
    if afterQ then
        return afterQ, "after ?="..afterQ
    end

    return nil, "no math"
end

local function solveCS(text)
    local tl = text:lower()

    -- Bitwise operations: "0xA3 AND 0x0F", "0xA3 & 0x0F", "0xA3 OR 0x0F", "0xA3 XOR 0x0F"
    local hexA, bitwiseOp, hexB = text:match("0x(%x+)%s+AND%s+0x(%x+)")
    if hexA and hexB then bitwiseOp = "AND" end
    if not hexA then
        hexA, hexB = text:match("0x(%x+)%s*&%s*0x(%x+)")
        if hexA then bitwiseOp = "AND" end
    end
    if not hexA then
        hexA, hexB = text:match("0x(%x+)%s+OR%s+0x(%x+)")
        if hexA then bitwiseOp = "OR" end
    end
    if not hexA then
        hexA, hexB = text:match("0x(%x+)%s+XOR%s+0x(%x+)")
        if hexA then bitwiseOp = "XOR" end
    end

    if hexA and bitwiseOp and hexB then
        local a, b = tonumber(hexA, 16), tonumber(hexB, 16)
        if a and b then
            local r
            if bitwiseOp == "AND" then r = bit32.band(a, b)
            elseif bitwiseOp == "OR" then r = bit32.bor(a, b)
            elseif bitwiseOp == "XOR" then r = bit32.bxor(a, b) end
            if r then
                return tostring(r), "0x"..hexA.." "..bitwiseOp.." 0x"..hexB.."="..r
            end
        end
    end

    -- Lower/upper nibble with hex
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
    local tl = text:lower()

    -- SMART DETECTION: analyze text keywords to determine solver priority
    local priority = {}

    -- Check for CS keywords (hex, nibble, AND, bitwise)
    if text:find("0x%x") or tl:find("nibble") or tl:find("byte") or text:find("AND") or text:find("XOR") or text:find("OR 0x") then
        table.insert(priority, solveCS)
    end

    -- Check for binary keywords (0b prefix, "binary", "biner")
    if text:find("0b[01]") or tl:find("binary") or tl:find("biner") then
        table.insert(priority, solveBinary)
    end

    -- Check for morse keywords (dots and dashes pattern, "morse")
    if text:find("[%.%-][%.%-][%.%-][%.%-]") or tl:find("morse") then
        -- Check if reversed
        if tl:find("reverse") or tl:find("terbalik") or tl:find("kanan ke kiri") or tl:find("right to left") then
            table.insert(priority, solveMorseReversed)
        end
        table.insert(priority, solveMorse)
    end

    -- Check for math keywords
    if text:find("%^") or tl:find("pangkat") or tl:find("power") or tl:find("d/dx")
        or tl:find("integral") or tl:find("lim") or tl:find("sqrt") or tl:find("akar")
        or tl:find("factorial") or tl:find("faktorial")
        or tl:find("dikali") or tl:find("ditambah") or tl:find("times") or tl:find("plus")
        or tl:find("square root") or tl:find("derivative") then
        table.insert(priority, solveMath)
    end

    -- Try priority solvers first
    for _, fn in ipairs(priority) do
        local d, info = fn(text)
        if d then return d, info end
    end

    -- Then try ALL solvers as fallback (order: CS, binary, morse, math, reversed)
    local allSolvers = {solveCS, solveBinary, solveMorse, solveMath, solveMorseReversed}
    for _, fn in ipairs(allSolvers) do
        local d, info = fn(text)
        if d then return d, "fb: "..info end
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
    ScrollBarThickness=4,ScrollBarImageColor3=C.idle,
    ScrollingDirection=Enum.ScrollingDirection.Y,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ElasticBehavior=Enum.ElasticBehavior.Always,
    ScrollingEnabled=true,
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

-- BUTTONS ROW (START + PAUSE side by side)
local btnRow = create("Frame",{
    Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,1,-34),
    BackgroundTransparency=1,Parent=content,
})

local startBtn = create("TextButton",{
    Size=UDim2.new(0.65,-2,1,0),Position=UDim2.new(0,0,0,0),
    Text="🔥 START FULL AUTO",BackgroundColor3=Color3.fromRGB(45,16,16),
    Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.text,
    BorderSizePixel=0,AutoButtonColor=true,Active=true,
    ZIndex=10,Parent=btnRow,
},{
    create("UICorner",{CornerRadius=UDim.new(0,6)}),
    create("UIStroke",{Color=C.red,Thickness=1}),
})

local pauseBtn = create("TextButton",{
    Size=UDim2.new(0.35,-2,1,0),Position=UDim2.new(0.65,2,0,0),
    Text="⏸ PAUSE",BackgroundColor3=C.surface,
    Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.dim,
    BorderSizePixel=0,AutoButtonColor=true,Active=true,
    ZIndex=10,Parent=btnRow,
},{
    create("UICorner",{CornerRadius=UDim.new(0,6)}),
    create("UIStroke",{Color=C.idle,Thickness=1}),
})

--// ═══════════════════════════════════════════════
--// PAUSE SYSTEM
--// ═══════════════════════════════════════════════
local paused = false

local function updatePauseButton()
    if paused then
        pauseBtn.Text = "▶ CONTINUE"
        pauseBtn.TextColor3 = C.green
        pauseBtn.BackgroundColor3 = Color3.fromRGB(16,35,16)
        local stroke = pauseBtn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = C.green end
        setStatus("⏸  PAUSED — tap CONTINUE to resume", C.orange)
    else
        pauseBtn.Text = "⏸ PAUSE"
        pauseBtn.TextColor3 = C.dim
        pauseBtn.BackgroundColor3 = C.surface
        local stroke = pauseBtn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = C.idle end
    end
end

local function waitForUnpause()
    while paused do
        task.wait(0.1)
    end
end

-- Pause-aware wait: pauses immediately when paused=true
local function pauseWait(seconds)
    local t0 = tick()
    while tick() - t0 < seconds do
        if paused then
            updatePauseButton()
            addLog("⏸ PAUSED", C.orange)
            waitForUnpause()
            updatePauseButton()
            addLog("▶ RESUMED", C.green)
        end
        task.wait(0.1)
    end
end

local function checkpoint(label)
    if paused then
        addLog("⏸ PAUSED at: "..label, C.orange)
        setStatus("⏸  PAUSED — tap CONTINUE ("..label..")", C.orange)
        waitForUnpause()
        updatePauseButton()
        addLog("▶ RESUMED", C.green)
    end
end

-- Use Activated (works on mobile + PC)
pauseBtn.Activated:Connect(function()
    if not running then return end
    paused = not paused
    updatePauseButton()
    if paused then
        addLog("⏸ PAUSE REQUESTED", C.orange)
    end
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

local function skipIntro()
    addLog("SKIPPING INTRO...", C.orange)
    setStatus("⏩  Skipping intro...", C.orange)

    local pg = player:FindFirstChild("PlayerGui")

    -- Kill intro ScreenGui
    pcall(function()
        local screenGui = pg and pg:FindFirstChild("ScreenGui")
        if screenGui then
            local frame = screenGui:FindFirstChild("Frame")
            if frame then
                frame.BackgroundTransparency = 1
                -- Destroy all intro elements
                for _, child in ipairs(frame:GetChildren()) do
                    pcall(function() child.Visible = false end)
                    pcall(function() child:Destroy() end)
                end
            end
            screenGui.Enabled = false
        end
    end)

    -- Enable player controls
    pcall(function()
        local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule", 3))
        if playerModule then
            playerModule:GetControls():Enable()
        end
    end)

    -- Enable CoreGui
    pcall(function()
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)

    -- Set camera to custom
    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)

    -- Enable first person camera modules
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        if modules then
            local sway = modules:FindFirstChild("SwayEffect")
            if sway then require(sway):Enable() end
            local walk = modules:FindFirstChild("WalkEffect")
            if walk then require(walk):Enable() end
            local cam = modules:FindFirstChild("Camera")
            if cam then require(cam):EnableFirstPerson() end
        end
    end)

    -- Remove blur
    pcall(function()
        local blur = game:GetService("Lighting"):FindFirstChild("Blur")
        if blur then blur.Size = 0 end
    end)

    -- Teleport to Hendrick spawn
    pcall(function()
        local spawn = workspace:FindFirstChild("Scenes")
            and workspace.Scenes:FindFirstChild("Hendrick")
            and workspace.Scenes.Hendrick:FindFirstChild("Spawn")
        if spawn then
            hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            addLog("  Teleported to Hendrick spawn", C.dim)
        end
    end)

    -- Reset button
    pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
    end)

    pauseWait(1)
    addLog("  Intro skipped!", C.green)
end

local function runFullAuto()
    if running then return end
    running = true
    startBtn.Active = false
    startBtn.TextColor3 = C.dim

    --────────────────────────────────────
    -- PHASE 0: SKIP INTRO
    --────────────────────────────────────
    addLog("PHASE 0: Skip intro", C.blue)
    skipIntro()

    --────────────────────────────────────
    -- PHASE 1: MORSE SCAN (with retry)
    --────────────────────────────────────
    setPhase(1, "active")

    local morseCode = ""
    local morseAttempt = 0
    local MAX_MORSE_RETRIES = 2

    repeat
        morseAttempt = morseAttempt + 1
        if morseAttempt > 1 then
            addLog("MORSE RETRY #"..morseAttempt, C.orange)
            setStatus("📡  MORSE RETRY #"..morseAttempt.."...", C.orange)
        else
            setStatus("📡  PHASE 1: Scanning morse radios...", C.orange)
            addLog("PHASE 1: Scanning "..RADIO_COUNT.." radios ("..SCAN_DURATION.."s)", C.orange)
        end

        for i = 1, 5 do
            radioDigits[i].Text = "..."
            radioDigits[i].TextColor3 = C.orange
        end

        local scanned = 0
        local results
        morseCode, results = scanAllRadios(function(i, data)
            local ok = data.digit ~= "?"
            setRadioDigit(i, data.digit, ok)
            scanned = scanned + 1
            setProgress(scanned / 30, C.orange)
            addLog("  R"..i..": "..data.digit.." ("..data.info..")", ok and C.green or C.red)
        end)

        displayCode(morseCodeLabel, morseCode)

    until not morseCode:find("%?") or morseAttempt >= (1 + MAX_MORSE_RETRIES)

    if morseCode:find("%?") then
        setPhase(1, "error")
        setStatus("❌  Morse scan failed after "..morseAttempt.." attempts: "..morseCode, C.red)
        addLog("MORSE FAILED: "..morseCode, C.red)
        running = false; startBtn.Active = true; startBtn.TextColor3 = C.text
        return
    end

    setPhase(1, "done")
    addLog("MORSE CODE: "..morseCode, C.green)

    checkpoint("after morse scan")

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
    pauseWait(0.5)

    addLog("  Triggering door prompt...", C.dim)
    fireproximityprompt(hendrickPrompt)
    pauseWait(1.5)

    addLog("  Filling morse slots: "..morseCode, C.dim)
    writeToMorseSlots(morseCode)
    pauseWait(0.3)

    addLog("  Submitting code...", C.dim)
    morseRemote:FireServer(unpack({morseCode}))
    pauseWait(2)
    setProgress(8/30, C.blue)

    setPhase(2, "done")
    addLog("  Code submitted!", C.green)

    --────────────────────────────────────
    -- PHASE 3: HENDRICK NOTE + CUTSCENE (SKIP)
    --────────────────────────────────────
    setPhase(3, "active")
    setStatus("📝  PHASE 3: Going to Hendrick note...", C.blue)
    addLog("PHASE 3: Hendrick note + cutscene", C.blue)

    hoverTeleport(Vector3.new(-1771.89, -10.32, -1865.50))
    local notePos = hendrickNote:GetPivot().Position
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(notePos.X, hrp.Position.Y, notePos.Z))
    pauseWait(0.5)

    fireproximityprompt(hendrickNotePrompt)
    addLog("  Note triggered...", C.dim)
    pauseWait(3) -- wait a moment for server to register interaction

    -- Try to skip cutscene via network events
    addLog("  Attempting cutscene skip...", C.orange)
    setStatus("⏩  Skipping Hendrick cutscene...", C.orange)

    local skipSuccess = false

    -- Method 1: Fire HendrickScene_Done via Network module
    pcall(function()
        if NetworkModule then
            NetworkModule:FireServer("HendrickScene_Done")
            addLog("  Fired: HendrickScene_Done (Network)", C.dim)
        end
    end)

    -- Method 2: Fire HendrickScene_Skip via Network module
    pcall(function()
        if NetworkModule then
            NetworkModule:FireServer("HendrickScene_Skip")
            addLog("  Fired: HendrickScene_Skip (Network)", C.dim)
        end
    end)

    -- Method 3: Fire via RemoteEvents directly
    pcall(function()
        local nc = ReplicatedStorage:FindFirstChild("NetworkContainer")
        if nc then
            local re = nc:FindFirstChild("RemoteEvents")
            if re then
                local skipEvt = re:FindFirstChild("HendrickScene_Skip")
                if skipEvt then
                    skipEvt:FireServer()
                    addLog("  Fired: HendrickScene_Skip (direct)", C.dim)
                    skipSuccess = true
                end

                local doneEvt = re:FindFirstChild("HendrickScene_Done")
                if doneEvt then
                    doneEvt:FireServer()
                    addLog("  Fired: HendrickScene_Done (direct)", C.dim)
                    skipSuccess = true
                end
            end
        end
    end)

    if skipSuccess then
        addLog("  Skip events fired!", C.green)
    else
        addLog("  Skip events not found, waiting for cutscene...", C.orange)
    end

    -- Wait for scene transition (server needs time to process skip)
    -- Check if player gets teleported to Peter scene
    setStatus("⏳  Waiting for scene transition...", C.dim)
    local transT0 = tick()
    local MAX_TRANSITION_WAIT = 30 -- max 30s wait for skip to work

    while tick() - transT0 < MAX_TRANSITION_WAIT do
        -- Check if Peter scene is now accessible (means cutscene is done)
        local peterCheck = workspace:FindFirstChild("Scenes")
            and workspace.Scenes:FindFirstChild("Peter")
            and workspace.Scenes.Peter:FindFirstChild("Clue_Code_1")
        if peterCheck then
            addLog("  Peter scene detected — cutscene skipped!", C.green)
            break
        end

        local elapsed = math.floor(tick() - transT0)
        setStatus("⏳  Waiting for transition... "..elapsed.."s", C.dim)
        setProgress(8/30 + (elapsed/MAX_TRANSITION_WAIT) * (7/30), C.dim)
        pauseWait(1)
    end

    -- If skip didn't work after 30s, fall back to waiting full cutscene
    if not (workspace:FindFirstChild("Scenes") and workspace.Scenes:FindFirstChild("Peter") and workspace.Scenes.Peter:FindFirstChild("Clue_Code_1")) then
        addLog("  Skip didn't work, waiting full cutscene...", C.orange)
        setStatus("🎬  Cutscene couldn't skip, waiting...", C.orange)

        local cutT0 = tick()
        while tick() - cutT0 < CUTSCENE_DURATION do
            local rem = math.ceil(CUTSCENE_DURATION - (tick()-cutT0))
            local frac = 8/30 + ((tick()-cutT0)/CUTSCENE_DURATION) * (7/30)
            setProgress(frac, C.dim)
            setStatus("🎬  CUTSCENE... "..rem.."s remaining", C.dim)
            pauseWait(1)
        end
    end

    -- Cleanup: remove blackscreen if stuck
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            local bs = pg:FindFirstChild("BlackscreenGuard") or pg:FindFirstChild("Blackscreen")
            if bs then bs:Destroy() addLog("  Removed blackscreen", C.dim) end
        end
    end)

    -- Re-enable movement
    pcall(function()
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)

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
        checkpoint("before clue "..i)

        local digit, info
        local attempt = 0

        repeat
            attempt = attempt + 1
            if attempt > 1 then
                addLog("  C"..i..": retry #"..attempt, C.orange)
                pauseWait(2)
            end

            setStatus("🔍  Clue "..i.."/5".. (attempt > 1 and " (retry)" or "") .."...", C.purple)
            addLog("  C"..i..": teleporting...", C.dim)

            local clue = peterScene:FindFirstChild("Clue_Code_"..i)
            if not clue then
                info = "not found"; break
            end

            teleportNear(clue, Vector3.new(0,0,3))
            pauseWait(0.5)

            -- Reset intercept before triggering
            interceptedClue.received = false
            interceptedClue.text = nil
            interceptedClue.index = nil

            local prompt = clue:FindFirstChild("Prompt")
            if prompt then fireproximityprompt(prompt) end

            local text = nil

            -- METHOD 1: Intercept from OpenClue event (instant, reliable)
            if NetworkModule then
                addLog("  C"..i..": waiting for OpenClue event...", C.dim)
                local waitT0 = tick()
                while not interceptedClue.received and tick() - waitT0 < 10 do
                    task.wait(0.1)
                end

                if interceptedClue.received and interceptedClue.text then
                    text = interceptedClue.text
                    addLog("  C"..i..": GOT via intercept!", C.green)

                    -- Fire ClueReadDone so server knows we're done
                    pcall(function()
                        NetworkModule:FireServer("ClueReadDone")
                    end)
                end
            end

            -- METHOD 2: Fallback to UI capture if intercept failed
            if not text or #text < 3 then
                addLog("  C"..i..": intercept failed, capturing from UI...", C.orange)
                pauseWait(2)
                text = captureClueText(35)
            end

            if text and #text >= 3 then
                digit, info = autoSolveClue(i, text)
                addLog("  C"..i..": "..text:sub(1,100), C.dim)
            else
                info = "no text"
            end

            -- Wait for notes to close before next
            waitNotesClose(8)
            pauseWait(1)

        until (digit and digit ~= "?") or attempt >= (1 + MAX_CLUE_RETRIES)

        peterDigits[i] = digit or "?"
        local ok = digit and digit ~= "?"
        setClueDigit(i, digit or "?", ok)
        addLog("  C"..i.." = "..(digit or "?").." ("..(info or "")..")", ok and C.green or C.red)

        -- PAUSE POINT: after each clue, user can screenshot if needed
        if not ok then
            addLog("  ⚠ C"..i.." FAILED — pausing for review", C.orange)
            paused = true
            updatePauseButton()
            setStatus("⏸  CLUE "..i.." FAILED — screenshot soal, tap CONTINUE", C.orange)
            waitForUnpause()
            updatePauseButton()
        end

        setProgress(15/30 + i/30, C.purple)
    end

    local peterCode = table.concat(peterDigits)
    displayCode(peterCodeLabel, peterCode)

    if peterCode:find("%?") then
        setPhase(4, "error")
        setStatus("❌  Peter clues incomplete: "..peterCode, C.red)
        addLog("PETER CLUES FAILED: "..peterCode, C.red)
        running = false; startBtn.Active = true; startBtn.TextColor3 = C.text
        return
    end

    setPhase(4, "done")
    addLog("PETER CODE: "..peterCode, C.green)

    checkpoint("after peter clues")

    --────────────────────────────────────
    -- PHASE 5: PETER DOOR + KEYPAD
    --────────────────────────────────────
    setPhase(5, "active")
    setStatus("🔑  PHASE 5: Peter door + keypad...", C.blue)
    addLog("PHASE 5: Peter door submit: "..peterCode, C.blue)
    setProgress(22/30, C.blue)

    teleportNear(peterDoor, Vector3.new(0,0,3))
    pauseWait(1)

    fireproximityprompt(peterDoorPrompt)
    pauseWait(2)

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

    pauseWait(2)
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
    pauseWait(1)

    fireproximityprompt(peterNotePrompt)
    pauseWait(3)

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
    startBtn.Text = "✅  COMPLETED"
end

startBtn.Activated:Connect(runFullAuto)

-- ENTRANCE
local targetSize = mainFrame.Size
mainFrame.Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset, 0, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = targetSize
}):Play()

setStatus("⏳  Press START to begin full automation", C.dim)
addLog("Danur Part 2 Full Auto loaded", C.dim)
addLog("Press START to begin all 6 phases", C.dim)
