--[[
    ╔══════════════════════════════════════════╗
    ║   DANUR AUTO QUEST · MANUAL MODE · By - ║
    ║   Step-by-step debugging version         ║
    ╚══════════════════════════════════════════╝
]]

-----------------------------------------------------
-- SERVICES & REFS
-----------------------------------------------------
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char   = player.Character or player.CharacterAdded:Wait()
local hrp    = char:WaitForChild("HumanoidRootPart")
local cam    = workspace.CurrentCamera

-----------------------------------------------------
-- STATE
-----------------------------------------------------
local steps       = {}
local currentIdx  = 0
local totalSteps  = 0
local waiting     = false  -- true = waiting for NEXT click

-----------------------------------------------------
-- UI
-----------------------------------------------------
for _, g in pairs(game.CoreGui:GetChildren()) do
    if g.Name == "DanurManual" then g:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "DanurManual"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

-- ═══════════════════════════════════════════════════
-- UI OPTIMIZED FOR LDCLOUD KVIP ANDROID 10
-- Resolution: 1280x720 (landscape) / DPI 320
-- Panel: 220x320, centered on screen
-- ═══════════════════════════════════════════════════

local PANEL_W = 220
local PANEL_H = 320
local PAD = 8           -- inner padding
local TITLE_H = 36
local STEP_H = 44
local PROG_H = 5
local BTN_H = 30
local BTN_GAP = 4

-- Main Frame — centered
local main = Instance.new("Frame", gui)
main.Name = "Main"
main.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
main.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(90, 60, 180)
stroke.Thickness = 1
stroke.Transparency = 0.3

-- Title Bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, TITLE_H)
titleBar.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

local titleFix = Instance.new("Frame", titleBar)
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
titleFix.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -8, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DANUR AUTO"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local creditLabel = Instance.new("TextLabel", titleBar)
creditLabel.Size = UDim2.new(0, 40, 1, 0)
creditLabel.Position = UDim2.new(1, -70, 0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "By -"
creditLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
creditLabel.Font = Enum.Font.GothamMedium
creditLabel.TextSize = 9
creditLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Current Step Display
local yOff = TITLE_H + PAD
local stepFrame = Instance.new("Frame", main)
stepFrame.Size = UDim2.new(1, -PAD*2, 0, STEP_H)
stepFrame.Position = UDim2.new(0, PAD, 0, yOff)
stepFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
stepFrame.BorderSizePixel = 0
Instance.new("UICorner", stepFrame).CornerRadius = UDim.new(0, 6)

local stepNumLabel = Instance.new("TextLabel", stepFrame)
stepNumLabel.Size = UDim2.new(1, -10, 0, 14)
stepNumLabel.Position = UDim2.new(0, 6, 0, 3)
stepNumLabel.BackgroundTransparency = 1
stepNumLabel.Text = "STEP 0 / 0"
stepNumLabel.TextColor3 = Color3.fromRGB(90, 60, 180)
stepNumLabel.Font = Enum.Font.GothamBold
stepNumLabel.TextSize = 9
stepNumLabel.TextXAlignment = Enum.TextXAlignment.Left

local stepNameLabel = Instance.new("TextLabel", stepFrame)
stepNameLabel.Size = UDim2.new(1, -10, 0, 24)
stepNameLabel.Position = UDim2.new(0, 6, 0, 17)
stepNameLabel.BackgroundTransparency = 1
stepNameLabel.Text = "Ready to start"
stepNameLabel.TextColor3 = Color3.new(1, 1, 1)
stepNameLabel.Font = Enum.Font.GothamMedium
stepNameLabel.TextSize = 10
stepNameLabel.TextXAlignment = Enum.TextXAlignment.Left
stepNameLabel.TextWrapped = true

-- Progress Bar
yOff = yOff + STEP_H + PAD
local progressBarBG = Instance.new("Frame", main)
progressBarBG.Size = UDim2.new(1, -PAD*2, 0, PROG_H)
progressBarBG.Position = UDim2.new(0, PAD, 0, yOff)
progressBarBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
progressBarBG.BorderSizePixel = 0
Instance.new("UICorner", progressBarBG).CornerRadius = UDim.new(1, 0)

local progressBarFill = Instance.new("Frame", progressBarBG)
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
progressBarFill.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
progressBarFill.BorderSizePixel = 0
Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1, 0)

-- Log
yOff = yOff + PROG_H + PAD
local logBottom = PANEL_H - PAD - BTN_H - BTN_GAP - BTN_H - BTN_GAP - 22 -- space for 2 buttons + reset
local logH = logBottom - yOff
local logFrame = Instance.new("Frame", main)
logFrame.Size = UDim2.new(1, -PAD*2, 0, logH)
logFrame.Position = UDim2.new(0, PAD, 0, yOff)
logFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
logFrame.BorderSizePixel = 0
logFrame.ClipsDescendants = true
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 6)

local logTitle = Instance.new("TextLabel", logFrame)
logTitle.Size = UDim2.new(1, -10, 0, 14)
logTitle.Position = UDim2.new(0, 6, 0, 3)
logTitle.BackgroundTransparency = 1
logTitle.Text = "LOG"
logTitle.TextColor3 = Color3.fromRGB(90, 60, 180)
logTitle.Font = Enum.Font.GothamBold
logTitle.TextSize = 9
logTitle.TextXAlignment = Enum.TextXAlignment.Left

local logScroll = Instance.new("ScrollingFrame", logFrame)
logScroll.Size = UDim2.new(1, -8, 1, -20)
logScroll.Position = UDim2.new(0, 4, 0, 18)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = Color3.fromRGB(90, 60, 180)
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.Padding = UDim.new(0, 1)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder

local logIdx = 0

-- Buttons
local function makeBtn(text, posY, color)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -PAD*2, 0, BTN_H)
    btn.Position = UDim2.new(0, PAD, 0, posY)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local btnY = PANEL_H - PAD - 22 - BTN_GAP - BTN_H - BTN_GAP - BTN_H
local nextBtn  = makeBtn("▶  NEXT STEP", btnY, Color3.fromRGB(40, 160, 80))
btnY = btnY + BTN_H + BTN_GAP
local autoBtn  = makeBtn("⏩  AUTO ALL", btnY, Color3.fromRGB(60, 90, 180))
btnY = btnY + BTN_H + BTN_GAP
local resetBtn = makeBtn("↺  RESET", btnY, Color3.fromRGB(80, 80, 90))
resetBtn.Size = UDim2.new(0.45, 0, 0, 22)
resetBtn.TextSize = 9

-- Minimize Button
local miniBtn = Instance.new("TextButton", titleBar)
miniBtn.Size = UDim2.new(0, 22, 0, 22)
miniBtn.Position = UDim2.new(1, -30, 0, 7)
miniBtn.BackgroundColor3 = Color3.fromRGB(70, 45, 140)
miniBtn.BorderSizePixel = 0
miniBtn.Text = "—"
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 12
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 5)

local minimized = false
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized
        and UDim2.new(0, PANEL_W, 0, TITLE_H)
        or UDim2.new(0, PANEL_W, 0, PANEL_H)
    TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    miniBtn.Text = minimized and "+" or "—"
end)

-- Draggable
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-----------------------------------------------------
-- HELPERS
-----------------------------------------------------
local function log(msg, color)
    color = color or Color3.fromRGB(180, 180, 200)
    logIdx = logIdx + 1
    local entry = Instance.new("TextLabel", logScroll)
    entry.Size = UDim2.new(1, -6, 0, 13)
    entry.BackgroundTransparency = 1
    entry.Text = "› " .. msg
    entry.TextColor3 = color
    entry.Font = Enum.Font.GothamMedium
    entry.TextSize = 8
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextTruncate = Enum.TextTruncate.AtEnd
    entry.LayoutOrder = logIdx
    task.defer(function()
        logScroll.CanvasPosition = Vector2.new(0, logScroll.AbsoluteCanvasSize.Y)
    end)
end

local function updateUI()
    stepNumLabel.Text = "STEP " .. currentIdx .. " / " .. totalSteps
    local pct = totalSteps > 0 and (currentIdx / totalSteps) or 0
    TweenService:Create(progressBarFill, TweenInfo.new(0.3), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
    if currentIdx > 0 and currentIdx <= totalSteps then
        stepNameLabel.Text = steps[currentIdx].name
    elseif currentIdx >= totalSteps then
        stepNameLabel.Text = "QUEST COMPLETE!"
    end
end

local function refreshChar()
    char = player.Character or player.CharacterAdded:Wait()
    hrp = char:WaitForChild("HumanoidRootPart")
    cam = workspace.CurrentCamera
end

local function getPart(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return obj:FindFirstChildWhichIsA("BasePart")
end

local function lookDown()
    cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position - Vector3.new(0, 10, 0))
end

local function faceTarget(targetPos)
    if not targetPos then return end
    local hrpPos = hrp.Position
    local lookAt = Vector3.new(targetPos.X, hrpPos.Y, targetPos.Z)
    hrp.CFrame = CFrame.new(hrpPos, lookAt)
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
end

local noclipConn = nil
local function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if not noclipConn then return end
    -- Anchor HRP biar ga jatuh dulu
    hrp.Anchored = true
    -- Disconnect noclip loop
    noclipConn:Disconnect()
    noclipConn = nil
    -- Re-enable collision di semua parts
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    -- Kill velocity biar ga gerak
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    task.wait(0.15)
    -- Unanchor biar bisa gerak normal
    hrp.Anchored = false
end

local WARP_SPEED = 200 -- studs per second

local function tp(target, faceObj)
    refreshChar()
    local destPos = nil

    if typeof(target) == "Vector3" then
        destPos = target
    elseif typeof(target) == "Instance" then
        local part = getPart(target)
        if part then
            destPos = part.Position + Vector3.new(0, 3, 0)
        end
    elseif typeof(target) == "CFrame" then
        destPos = target.Position
    end

    if not destPos then return end

    -- Noclip warp
    enableNoclip()

    local startPos = hrp.Position
    local distance = (destPos - startPos).Magnitude
    local duration = math.clamp(distance / WARP_SPEED, 0.1, 3)
    local elapsed = 0

    -- Anchor selama warp biar stabil
    hrp.Anchored = true

    while elapsed < duration do
        local dt = RunService.Heartbeat:Wait()
        elapsed = elapsed + dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local smooth = alpha < 0.5
            and 2 * alpha * alpha
            or 1 - (-2 * alpha + 2)^2 / 2
        local currentPos = startPos:Lerp(destPos, smooth)
        hrp.CFrame = CFrame.new(currentPos, destPos)
    end

    -- Snap final position
    hrp.CFrame = CFrame.new(destPos)

    -- Safe landing: disable noclip (handles anchor/collision)
    disableNoclip()
    task.wait(0.1)

    -- Face target
    if faceObj then
        if typeof(faceObj) == "Instance" then
            local p = getPart(faceObj)
            if p then faceTarget(p.Position) end
        elseif typeof(faceObj) == "Vector3" then
            faceTarget(faceObj)
        end
    elseif typeof(target) == "Instance" then
        local part = getPart(target)
        if part then faceTarget(part.Position) end
    end
    task.wait(0.1)
end

-- ══════════════════════════════════════════════════
-- [FIX 3] SPECIAL TP FOR WALL FRAMES
-- Pakai WARP (biar gak kekick anti-cheat) tapi
-- destinasi ke LANTAI depan lukisan. Setelah sampai
-- disable noclip biar gak nyemplung/tembus.
-- ══════════════════════════════════════════════════
local FLOOR_Y = -0.40 -- default floor Y di area lukisan

local function forceLookAtFrame(framePos)
    local hrpPos = hrp.Position
    local lookAt = Vector3.new(framePos.X, hrpPos.Y, framePos.Z)
    hrp.CFrame = CFrame.new(hrpPos, lookAt)
    local camPos = hrpPos + Vector3.new(0, 1.5, 0)
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(camPos, framePos)
    task.wait(0.15)
end

local function tpToWallFrame(frameObj)
    refreshChar()
    local part = getPart(frameObj)
    if not part then
        log("  Frame part not found!", Color3.fromRGB(255, 80, 80))
        return
    end

    local frameCF = part.CFrame
    local framePos = frameCF.Position

    -- Cari arah "depan" lukisan pakai raycast
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, frameObj}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local tryOffset = frameCF.LookVector * 6
    local hit = workspace:Raycast(framePos, tryOffset, rayParams)
    if hit then
        tryOffset = frameCF.LookVector * -6
        log("  LookVector blocked, using reverse", Color3.fromRGB(255, 180, 50))
    end

    local frontPos = framePos + tryOffset
    -- Destinasi = LANTAI depan lukisan (bukan posisi lukisan di tembok)
    local destPos = Vector3.new(frontPos.X, FLOOR_Y, frontPos.Z)

    -- Pakai tp() yang udah ada (warp + noclip, aman dari anti-cheat)
    tp(destPos)

    -- Setelah sampai di lantai, MATIIN noclip biar gak nyemplung
    disableNoclip()
    task.wait(0.3)

    -- Paksa kamera nge-look ke atas ke lukisan
    forceLookAtFrame(framePos)
    task.wait(0.3)
end

-- Selesai interact frame, kembalikan kamera + re-enable noclip buat lanjut
local function landAfterFrame()
    cam.CameraType = Enum.CameraType.Custom
    task.wait(0.2)
    enableNoclip()
    task.wait(0.1)
end

local function interact(prompt, holdOverride)
    if not prompt then
        log("Prompt not found!", Color3.fromRGB(255, 80, 80))
        return false
    end
    local hold = holdOverride or prompt.HoldDuration or 0
    local ok, err = pcall(function()
        fireproximityprompt(prompt, hold)
    end)
    if not ok then
        log("Prompt error: " .. tostring(err), Color3.fromRGB(255, 80, 80))
        return false
    end
    task.wait(hold + 0.3)
    return true
end

local function clickDet(cd)
    if not cd then
        log("ClickDetector not found!", Color3.fromRGB(255, 80, 80))
        return false
    end
    pcall(function() fireclickdetector(cd) end)
    task.wait(0.4)
    return true
end

local function findNearestRotatePrompt()
    local nearest, nearestDist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Rotate" then
            local part = v.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < nearestDist then
                    nearest = v
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

local function rotateNTimes(n)
    for i = 1, n do
        local prompt = findNearestRotatePrompt()
        if prompt then
            local paintPart = prompt.Parent
            if paintPart and paintPart:IsA("BasePart") then
                faceTarget(paintPart.Position)
                task.wait(2)
            end
            fireproximityprompt(prompt, prompt.HoldDuration)
            log("  Rotated " .. i .. "/" .. n, Color3.fromRGB(160, 160, 200))
            task.wait(2)
        end
    end
end

-----------------------------------------------------
-- REGISTER ALL STEPS
-----------------------------------------------------
local function addStep(name, fn)
    table.insert(steps, {name = name, fn = fn})
end

-- ═══ PHASE 1: KITCHEN ═══
addStep("Collect Pan", function()
    local pan = workspace.Kitchen["Frying Pan"]
    tp(pan)
    task.wait(2)
    interact(pan.Prompt, 4)
    task.wait(2)
end)

addStep("Put Pan on Stove", function()
    local stove = workspace.Kitchen.Part
    tp(stove)
    task.wait(2)
    interact(stove.Prompt, 4)
    task.wait(2)
end)

addStep("Collect Egg", function()
    local egg = workspace.Kitchen.telor
    tp(egg)
    task.wait(2)
    interact(egg.Prompt, 4)
    task.wait(2)
end)

addStep("Cook Egg on Stove", function()
    local stove = workspace.Kitchen.Part
    tp(stove)
    task.wait(2)
    interact(stove.Prompt, 4)
    task.wait(2)
end)

-- ═══ PHASE 2: SLEEP ═══
addStep("Go to Bed & Sleep", function()
    local bed = workspace.RUMAH.Furniture_ParentsBedroom_KingBedFrame
    local bedPart = getPart(bed)
    if bedPart then
        local hoverPos = bedPart.Position + Vector3.new(0, 8, 0)
        tp(Vector3.new(hoverPos.X, hoverPos.Y, hoverPos.Z))
        task.wait(2)
        log("  Hovering above bed...", Color3.fromRGB(160, 160, 200))
        disableNoclip()
        task.wait(2)
        hrp.CFrame = CFrame.new(bedPart.Position + Vector3.new(0, 3, 0))
        task.wait(2)
    else
        tp(bed)
        task.wait(2)
    end
    lookDown()
    task.wait(2)
    local sleepPrompt = workspace.SceneHolder.Sleep_Scene_1.Part.Prompt
    interact(sleepPrompt, 4)
    log("  Waiting after sleep (5s)...", Color3.fromRGB(200, 200, 100))
    task.wait(5)
end)

addStep("TP after Sleep", function()
    tp(Vector3.new(-174.80, 20.56, -684.66))
    log("  Waiting before ballet (5s)...", Color3.fromRGB(200, 200, 100))
    task.wait(5)
end)

-- ═══ PHASE 3: BALLET ═══
addStep("Ballet Scene 1", function()
    tp(Vector3.new(-145.29, 4.74, -638.53))
    task.wait(5)
end)

-- [FIX 1] Ballet Scene 2: matiin noclip, wait hantu, noclip lagi
addStep("Ballet Scene 2", function()
    tp(Vector3.new(-178.51, -1.92, -586.10))
    task.wait(2)
    disableNoclip()
    log("  Noclip OFF - waiting for ghost attack (5s)...", Color3.fromRGB(255, 180, 50))
    task.wait(5)
    enableNoclip()
    log("  Noclip back ON", Color3.fromRGB(100, 220, 160))
    task.wait(2)
end)

addStep("Ballet Scene 4", function()
    tp(Vector3.new(-251.14, -0.40, -528.22))
    task.wait(5)
end)

-- ═══ PHASE 4: COLLECT ITEMS ═══
addStep("Go to Cabinet", function()
    local cabinet = workspace["Lower-SingleCabinetDrawers"]["Lower-SingleCabinet"]
    tp(Vector3.new(-313.74, -0.40, -681.74), cabinet)
    task.wait(2)
end)

addStep("Open Drawer (Tie)", function()
    local drawer = workspace.RKDKCW_DrawerTemplate.Tie_Loc_1.Drawer
    faceTarget(drawer.Position)
    task.wait(2)
    clickDet(drawer.ClickDetector)
    task.wait(2)
end)

addStep("Collect Tie", function()
    local tie = workspace.RKDKCW_DrawerTemplate.Tie_Loc_1.Tie
    tp(tie)
    task.wait(2)
    interact(tie.ProximityPrompt)
    task.wait(2)
end)

addStep("Go to Locker", function()
    local locker = workspace.TESTING1.Loker2
    tp(Vector3.new(-254.82, -0.40, -606.54), locker)
    task.wait(2)
end)

addStep("Open Locker", function()
    local locker = workspace.TESTING1.Loker2
    local p = getPart(locker)
    if p then faceTarget(p.Position) end
    task.wait(2)
    local cd = locker:FindFirstChildOfClass("ClickDetector")
    if cd then clickDet(cd) end
    task.wait(2)
end)

addStep("Collect Rose", function()
    local rose = workspace.RKDKCW_DrawerTemplate.Rose_Loc_1
    tp(rose)
    task.wait(2)
    interact(rose.ProximityPrompt)
    task.wait(2)
end)

addStep("Collect Weapon", function()
    local weapon = workspace.RKDKCW_DrawerTemplate.Weapon_Loc_1
    tp(weapon)
    task.wait(2)
    interact(weapon.ProximityPrompt)
    task.wait(2)
end)

-- ═══ PHASE 5: DELIVER ITEMS ═══
addStep("Give Rose", function()
    local spot = workspace.RKDKCW_DrawerTemplate.Rose_1.rose
    tp(spot)
    task.wait(2)
    lookDown()
    task.wait(2)
    interact(spot.ProximityPrompt)
    task.wait(2)
end)

addStep("Give Tie", function()
    local spot = workspace.RKDKCW_DrawerTemplate.Tie_1.Tie
    tp(spot)
    task.wait(2)
    lookDown()
    task.wait(2)
    interact(spot.ProximityPrompt)
    task.wait(2)
end)

addStep("Give Weapon", function()
    local spot = workspace.RKDKCW_DrawerTemplate.Weapon_1.Weapon
    tp(spot)
    task.wait(2)
    lookDown()
    task.wait(2)
    interact(spot.ProximityPrompt)
    task.wait(2)
end)

-- ═══ PHASE 6: PAINTINGS ═══
addStep("Painting 1 - Rotate 4x", function()
    tp(Vector3.new(-253.60, 2.70, -635.06))
    task.wait(2)
    rotateNTimes(4)
    task.wait(2)
end)

addStep("Painting 2 - Rotate 4x", function()
    tp(Vector3.new(-315.81, -0.40, -647.66))
    task.wait(2)
    rotateNTimes(4)
    task.wait(2)
end)

addStep("Painting 3 - Rotate 4x", function()
    tp(Vector3.new(-262.84, -0.37, -591.82))
    task.wait(2)
    rotateNTimes(4)
    task.wait(2)
end)

addStep("Painting 4 - Rotate 4x", function()
    tp(Vector3.new(-262.43, -0.40, -540.97))
    task.wait(2)
    rotateNTimes(4)
    task.wait(2)
end)

-- ═══ PHASE 7: JASHEN DOOR & NOTE ═══
addStep("Open Jashen Door 1", function()
    local door = workspace.RKDKCW_DrawerTemplate.JashenDoor1.Door
    tp(door)
    task.wait(2)
    interact(door.ProximityPrompt)
    task.wait(2)
end)

addStep("Wait Cutscene (10s)", function()
    log("Waiting 10s for cutscene...", Color3.fromRGB(200, 200, 100))
    task.wait(10)
end)

addStep("Take Note", function()
    local note = workspace.SceneHolder.Ballet_Scene_3.Note
    tp(Vector3.new(-263.33, -0.40, -677.97), note)
    task.wait(2)
    local prompt = note:FindFirstChild("Prompt")
        or note:FindFirstChildWhichIsA("ProximityPrompt")
        or note:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        interact(prompt)
        task.wait(2)
    else
        log("  Brute-forcing prompts...", Color3.fromRGB(255, 180, 50))
        for _, desc in pairs(note:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                fireproximityprompt(desc, desc.HoldDuration)
                task.wait(2)
            end
        end
    end
end)

addStep("Wait Cutscene (85s)", function()
    log("Waiting ~85s for cutscene...", Color3.fromRGB(200, 200, 100))
    for i = 85, 1, -5 do
        stepNameLabel.Text = "Cutscene: " .. i .. "s remaining"
        task.wait(5)
    end
end)

-- ═══ PHASE 8: VIOLIN QUEST ═══
addStep("Open Jashen Door 2", function()
    local door = workspace.RKDKCW_DrawerTemplate.JashenDoor2.Door
    tp(door)
    task.wait(2)
    interact(door.ProximityPrompt)
    task.wait(2)
end)

addStep("TP to Corridor", function()
    tp(Vector3.new(-284.47, -0.40, -711.92))
    task.wait(2)
end)

addStep("Get Violin", function()
    local violin = workspace.SceneHolder.ViolinJumpscare
    tp(violin)
    task.wait(2)
    local prompt = violin:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then interact(prompt) end
    task.wait(2)
end)

addStep("Open Door (Children[26])", function()
    local doorObj = workspace:GetChildren()[26]
    if doorObj and doorObj:FindFirstChild("Door") then
        tp(doorObj.Door)
        task.wait(2)
        interact(doorObj.Door.ProximityPrompt)
        task.wait(2)
    end
end)

addStep("Meet Pak RT (auto-dialog)", function()
    tp(Vector3.new(-280.79, -1.11, -1143.13))
    log("Waiting for Pak RT dialog (10s)...", Color3.fromRGB(200, 200, 100))
    task.wait(10)
end)

-- [FIX 2] Open Door Children[180] + jeda 3 detik
addStep("Open Door (Children[180])", function()
    local doorObj = workspace:GetChildren()[180]
    if doorObj and doorObj:FindFirstChild("Door") then
        tp(doorObj.Door)
        task.wait(2)
        interact(doorObj.Door.ProximityPrompt)
        log("  Waiting after door (3s)...", Color3.fromRGB(200, 200, 100))
        task.wait(3)
    end
end)

-- ═══ PHASE 9: WILLIAM SCENE ═══
addStep("TP to William Area", function()
    tp(Vector3.new(-425.64, -12.11, -1309.28))
    task.wait(2)
end)

addStep("Collect Key", function()
    local key = workspace.SceneHolder.WilliamScene.CollectedKeys
    tp(key)
    task.wait(2)
    interact(key.ProximityPrompt)
    task.wait(2)
end)

addStep("Collect Violin (William)", function()
    local violin = workspace.SceneHolder.WilliamScene.CollectedViolin
    tp(violin)
    task.wait(2)
    interact(violin.ProximityPrompt)
    task.wait(2)
end)

addStep("Open William Door", function()
    local door = workspace.WilliamDoor.Door
    tp(door)
    task.wait(2)
    interact(door.ProximityPrompt)
    task.wait(2)
end)

addStep("Place Violin", function()
    local spot = workspace.SceneHolder.WilliamScene.ViolinPlacement
    tp(spot)
    task.wait(2)
    interact(spot.ProximityPrompt)
    task.wait(2)
end)

addStep("Wait Cutscene (85s)", function()
    log("Waiting ~85s for cutscene...", Color3.fromRGB(200, 200, 100))
    for i = 85, 1, -5 do
        stepNameLabel.Text = "Cutscene: " .. i .. "s remaining"
        task.wait(5)
    end
end)

-- ═══ PHASE 10: WILLIAM DOOR 3 ═══
addStep("TP to William Door 3", function()
    local target = workspace.RKDKCW_DrawerTemplate.WilliamDoor3["unik nih"]
    tp(Vector3.new(-770.16, -11.97, -1101.39), target)
    task.wait(2)
end)

addStep("Open William Door 3", function()
    local part = workspace.RKDKCW_DrawerTemplate.WilliamDoor3.Part
    tp(part)
    task.wait(2)
    interact(part.ProximityPrompt)
    task.wait(2)
end)

addStep("Open Final Corridor Door", function()
    local door = workspace.Door.Door
    tp(door)
    task.wait(2)
    interact(door.ProximityPrompt)
    log("  Waiting after door (7s)...", Color3.fromRGB(200, 200, 100))
    task.wait(7)
end)

-- ═══ PHASE 11: MOPPING ═══
addStep("Mop All Water (11 spots)", function()
    local hansJob = workspace.RKDKCW_HansJob
    local children = hansJob:GetChildren()
    for i, child in ipairs(children) do
        local part = getPart(child)
        if part then
            local safePos = Vector3.new(part.Position.X, part.Position.Y + 4, part.Position.Z)
            tp(safePos)
            task.wait(2)
            lookDown()
            task.wait(2)
            local prompt = child:FindFirstChild("Prompt")
                or child:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                interact(prompt)
                log("  Mopped " .. i .. "/" .. #children, Color3.fromRGB(100, 220, 160))
                task.wait(2)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════
-- PHASE 12: ROTATING FRAMES (3 foto)
-- Teleport ke koordinat yang udah pasti di lantai,
-- lihat ke lukisan, rotate 3x masing-masing
-- ═══════════════════════════════════════════════════

addStep("Foto 1 - Rotate 3x", function()
    local obj = workspace.RKDKCW_RotatingFrame:GetChildren()[3]
    tp(Vector3.new(-1130.91, -12.14, -1156.31))
    task.wait(2)
    disableNoclip()
    task.wait(2)
    local framePos = getPart(obj).Position
    forceLookAtFrame(framePos)
    task.wait(2)
    local prompt = obj:FindFirstChild("Bordighera_Geo")
        and obj.Bordighera_Geo:FindFirstChildWhichIsA("ProximityPrompt")
        or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        for i = 1, 3 do
            forceLookAtFrame(framePos)
            task.wait(2)
            fireproximityprompt(prompt, prompt.HoldDuration)
            log("  Foto 1 rotated " .. i .. "/3", Color3.fromRGB(160, 160, 200))
            task.wait(2)
        end
    end
    task.wait(2)
    landAfterFrame()
end)

addStep("Foto 2 - Rotate 3x", function()
    local obj = workspace.RKDKCW_RotatingFrame:GetChildren()[2]
    tp(Vector3.new(-1146.98, -12.11, -1067.10))
    task.wait(2)
    disableNoclip()
    task.wait(2)
    local framePos = getPart(obj).Position
    forceLookAtFrame(framePos)
    task.wait(2)
    local prompt = obj:FindFirstChild("Bordighera_Geo")
        and obj.Bordighera_Geo:FindFirstChildWhichIsA("ProximityPrompt")
        or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        for i = 1, 3 do
            forceLookAtFrame(framePos)
            task.wait(2)
            fireproximityprompt(prompt, prompt.HoldDuration)
            log("  Foto 2 rotated " .. i .. "/3", Color3.fromRGB(160, 160, 200))
            task.wait(2)
        end
    end
    task.wait(2)
    landAfterFrame()
end)

addStep("Foto 3 (Bordighera) - Rotate 3x", function()
    local obj = workspace.RKDKCW_RotatingFrame.Bordighera
    tp(Vector3.new(-1141.41, -12.12, -1086.50))
    task.wait(2)
    disableNoclip()
    task.wait(2)
    local framePos = getPart(obj).Position
    forceLookAtFrame(framePos)
    task.wait(2)
    local prompt = obj:FindFirstChild("Bordighera_Geo")
        and obj.Bordighera_Geo:FindFirstChildWhichIsA("ProximityPrompt")
        or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        for i = 1, 3 do
            forceLookAtFrame(framePos)
            task.wait(2)
            fireproximityprompt(prompt, prompt.HoldDuration)
            log("  Foto 3 rotated " .. i .. "/3", Color3.fromRGB(160, 160, 200))
            task.wait(2)
        end
    end
    task.wait(2)
    landAfterFrame()
end)

addStep("Foto 4 - Rotate 3x", function()
    local obj = workspace.RKDKCW_RotatingFrame:GetChildren()[4]
    tp(Vector3.new(-1176.35, -12.03, -1065.15))
    task.wait(2)
    disableNoclip()
    task.wait(2)
    local framePos = getPart(obj).Position
    forceLookAtFrame(framePos)
    task.wait(2)
    local prompt = obj:FindFirstChild("Bordighera_Geo")
        and obj.Bordighera_Geo:FindFirstChildWhichIsA("ProximityPrompt")
        or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        for i = 1, 3 do
            forceLookAtFrame(framePos)
            task.wait(2)
            fireproximityprompt(prompt, prompt.HoldDuration)
            log("  Foto 4 rotated " .. i .. "/3", Color3.fromRGB(160, 160, 200))
            task.wait(2)
        end
    end
    task.wait(2)
    landAfterFrame()
end)

-----------------------------------------------------
-- INIT
-----------------------------------------------------
totalSteps = #steps
updateUI()
log("Loaded " .. totalSteps .. " steps. Press NEXT to begin.", Color3.fromRGB(120, 120, 140))

-----------------------------------------------------
-- EXECUTE STEP
-----------------------------------------------------
local function executeStep(idx)
    if idx < 1 or idx > totalSteps then return end
    currentIdx = idx
    updateUI()

    local s = steps[idx]
    log("▶ [" .. idx .. "] " .. s.name, Color3.fromRGB(120, 200, 255))

    -- Flash button
    nextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    nextBtn.Text = "⏳  RUNNING..."

    local ok, err = pcall(s.fn)
    if not ok then
        log("ERROR: " .. tostring(err), Color3.fromRGB(255, 50, 50))
    else
        log("✓ Done", Color3.fromRGB(100, 220, 100))
    end

    updateUI()

    if currentIdx >= totalSteps then
        nextBtn.Text = "✓  QUEST COMPLETE"
        nextBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        log("═══ ALL STEPS COMPLETE! ═══", Color3.fromRGB(50, 255, 100))
    else
        nextBtn.Text = "▶  NEXT: " .. steps[idx + 1].name
        nextBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    end
end

-----------------------------------------------------
-- BUTTON CONNECTIONS
-----------------------------------------------------
nextBtn.MouseButton1Click:Connect(function()
    if currentIdx >= totalSteps then return end
    task.spawn(function()
        executeStep(currentIdx + 1)
    end)
end)

local autoRunning = false
autoBtn.MouseButton1Click:Connect(function()
    if autoRunning then
        autoRunning = false
        autoBtn.Text = "⏩  AUTO (Run All Remaining)"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
        return
    end

    autoRunning = true
    autoBtn.Text = "⏸  PAUSE AUTO"
    autoBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 40)

    task.spawn(function()
        while autoRunning and currentIdx < totalSteps do
            executeStep(currentIdx + 1)
            task.wait(0.5)
        end
        autoRunning = false
        autoBtn.Text = "⏩  AUTO (Run All Remaining)"
        autoBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
    end)
end)

resetBtn.MouseButton1Click:Connect(function()
    autoRunning = false
    currentIdx = 0
    updateUI()
    stepNameLabel.Text = "Ready to start"
    nextBtn.Text = "▶  NEXT STEP"
    nextBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    for _, child in pairs(logScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    logIdx = 0
    log("Reset. Press NEXT to begin.", Color3.fromRGB(120, 120, 140))
end)
