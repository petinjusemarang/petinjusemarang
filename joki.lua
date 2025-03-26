-- GUI Utama
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local optionFrame = Instance.new("Frame")
local jokiUangButton = Instance.new("TextButton")
local jokiMinigameButton = Instance.new("TextButton")

-- Menyusun GUI
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
mainFrame.Size = UDim2.new(0, 400, 0, 280)

-- Judul
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "SAMLONG CDID"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 22
titleLabel.TextStrokeTransparency = 0.5

-- Frame Pilihan Joki
optionFrame.Parent = mainFrame
optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
optionFrame.Position = UDim2.new(0, 0, 0.1, 0)
optionFrame.Size = UDim2.new(1, 0, 0, 100)

-- Tombol Joki Uang
jokiUangButton.Parent = optionFrame
jokiUangButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jokiUangButton.Position = UDim2.new(0.1, 0, 0.1, 0)
jokiUangButton.Size = UDim2.new(0.8, 0, 0, 40)
jokiUangButton.Font = Enum.Font.Gotham
jokiUangButton.Text = "Joki Uang"
jokiUangButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jokiUangButton.TextSize = 18

-- Tombol Joki Minigame
jokiMinigameButton.Parent = optionFrame
jokiMinigameButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
jokiMinigameButton.Position = UDim2.new(0.1, 0, 0.55, 0)
jokiMinigameButton.Size = UDim2.new(0.8, 0, 0, 40)
jokiMinigameButton.Font = Enum.Font.Gotham
jokiMinigameButton.Text = "Joki Minigame"
jokiMinigameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jokiMinigameButton.TextSize = 18

-- Frame Device
local deviceFrame = Instance.new("Frame")
deviceFrame.Parent = mainFrame
deviceFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
deviceFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
deviceFrame.Size = UDim2.new(0.96, 0, 0.5, 0)
deviceFrame.Visible = false

-- Webhook untuk setiap device
local deviceWebhooks = {
    A1 = "https://discord.com/api/webhooks/1354264903363465308/iWj0svtJHd9RQz6D5z_AEi_qdzEkS1zSTIGNGNErbSFXkXrEUPTq5XQske6cN6dhlpBW", A2 = "https://discord.com/api/webhooks/1354264903933890734/t__VicA3UOwJ2KDKiSjqT_Yj_2xrYkuFLs8zt6tE_-AW2mu5-dSGeTjrquhO9_w6Y-7b", A3 = "https://discord.com/api/webhooks/1354264904617558168/NQDEECWAgdsfdXjwKA867jRiEUMhdUOrq1H8C2UtkOfn7xeOJFWu3Hu2ULkZEOHhi-F9", A4 = "https://discord.com/api/webhooks/1354264905443967246/jTe-7sVewMUZNk2Mtyd6yKeR5Dl25pDCcjsmqbGTDKbz703v_io7pMTEt0PLXAaX1akw", A5 = "https://discord.com/api/webhooks/1354264906333028352/5cdftql_i8zBIKBTmskty23Y5q19p4JM9v_28TKQTQzsLxOiJpG-0_smAQin__HHXTff", A6 = "https://discord.com/api/webhooks/1354264907150917855/ZU52-ptP00NreykxsN_rmqeQJysnYHgjYBzGDjQ2OtQuNXcAKIe25x60PBcSjSZOg_KP",
    B1 = "https://discord.com/api/webhooks/1354264907914285126/GLXFTtw26sQ-7GOxYa4YX_-koBD4UxtS4XE6FVHgdfoM8aYKmKyjFfGBe2U01UaE32Du", B2 = "https://discord.com/api/webhooks/1354264908526649375/cu2JiyaaMLduzPMzKGzyXdYp1Xcoi_CbXSYPgXplu2V-KN9YczClQoin3jvxbifXsQLa", B3 = "https://discord.com/api/webhooks/1354249825150963762/Mkf45iRxnlxx9obpGTB0510Cg6WZCW_jKe_RMrw52W4AuChmBRNG0C0AZUZIha_PSQCb", B4 = "https://discord.com/api/webhooks/1354264909722157066/gy99Lg2YjrVPO6gDnfCxr1FCkjxu2Srnk5fySDAjncAuxpZHKu72drRgMXKgENF_Sg_m", B5 = "https://discord.com/api/webhooks/1354264910183268412/WUKOkqPUJF0fLZbF9U6qi5g1iSRKEoE6ynLTGIyByOz2KxDQEmsPqE-wr2fvwlNAyeXr", B6 = "https://discord.com/api/webhooks/1354264799520882831/YXqh7e6DhIOVCToPUhoPwFCnXv3nWpmfREJsXZYmRXp-CbGouMPzvF7xoNON3jtnfjRz",
    C1 = "https://discord.com/api/webhooks/1354264804226895953/bTAfYr9_IeNIMvhWfIXzz5IVtx9HBcTFoL21aUoSTpTxkPniPA_zpdldf7tupbYaos8W", C2 = "https://discord.com/api/webhooks/1354264911223455834/9i9rHtu-5CWilFmSs6DijUMHbDe9auIp-VzsWXpZw_f8pFV-0GMsXXedjIqCKpTjqw5U", C3 = "https://discord.com/api/webhooks/1354264912314241085/_Ib62l-pTb-jH5JrB5B5OGJpqOhsstuDkzJvgycwfU6F4fzZXsrBYBFE2tN5PL4S3mPr", C4 = "https://discord.com/api/webhooks/1354289075242143754/pmmdwm9P-vorflCvhnrNt2yVQKdGlr9JoeJX0xn2LLsA_XKwKGC1XAbnaOC2032ztIKT", C5 = "https://discord.com/api/webhooks/1354289084935176222/P_mC3fD2HHuo6sKpH86xsLO9gZMxgrfqo6vmxbgBkKDZHcnJOsrAIeZT2djXBAiUKBzT", C6 = "https://discord.com/api/webhooks/1354289093445423275/6YPRP_-QCGlekRBDJRsOkIT5X-muun672MSUuZutWHttYdsQBw-RyTcjI7_a1LZsfVUa",
    D1 = "https://discord.com/api/webhooks/1354289099716034610/33WXkrOy7Lx_U8_A5549uMuBQJNWwE7hgnlq3SAIZSVfwHAZ2owbG854P6SQgnKHAUSS", D2 = "https://discord.com/api/webhooks/1354289107408523447/HUrh8W9kRps0KzGCt-XS3FDR-qUdaRHR0HQrrxaaB60E-GG64kJRpn8CjB7nNluM4zPw", D3 = "https://discord.com/api/webhooks/1354289113691324466/L3Sb2NftSUHWJpIZFWyvLIBoUnP3MF0TJs2JuzEulzb1LktnkTGlQ_Ih-Wh7xYkNZ-bW", D4 = "https://discord.com/api/webhooks/1354289113691324466/L3Sb2NftSUHWJpIZFWyvLIBoUnP3MF0TJs2JuzEulzb1LktnkTGlQ_Ih-Wh7xYkNZ-bW", D5 = "https://discord.com/api/webhooks/1354289113691324466/L3Sb2NftSUHWJpIZFWyvLIBoUnP3MF0TJs2JuzEulzb1LktnkTGlQ_Ih-Wh7xYkNZ-bW", D6 = "https://discord.com/api/webhooks/1354289113691324466/L3Sb2NftSUHWJpIZFWyvLIBoUnP3MF0TJs2JuzEulzb1LktnkTGlQ_Ih-Wh7xYkNZ-bW"
}

-- Fungsi menjalankan script joki uang
local function executeDeviceScript(device)
    local webhookURL = deviceWebhooks[device]
    if webhookURL then
        mainFrame.Visible = false
        local script = [[
            getgenv().startAutofarm = true
            getgenv().teleportTime = "52"
            getgenv().recallJobTime = "0.5"
            getgenv().webhookUrl = "]] .. webhookURL .. [["
            script_key="SrQuajZVansBldWigVqxjBPuKYbBkLDA";
            loadstring(game:HttpGet("https://getsades.net"))()
        ]]
        loadstring(script)()
    else
        print("Device tidak ditemukan!")
    end
end

-- Membuat tombol device
local devices = {
    "A1", "A2", "A3", "A4", "A5", "A6",
    "B1", "B2", "B3", "B4", "B5", "B6",
    "C1", "C2", "C3", "C4", "C5", "C6",
    "D1", "D2", "D3", "D4", "D5", "D6"
}

for i, deviceName in ipairs(devices) do
    local button = Instance.new("TextButton")
    button.Parent = deviceFrame
    button.Size = UDim2.new(0.15, 0, 0.22, 0)
    button.Position = UDim2.new(0.02 + ((i - 1) % 6) * 0.16, 0, math.floor((i - 1) / 6) * 0.25, 0)
    button.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    button.Text = deviceName
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16

    button.MouseButton1Click:Connect(function()
        executeDeviceScript(deviceName)
    end)
end

-- Joki Uang -> Pilih Device
jokiUangButton.MouseButton1Click:Connect(function()
    optionFrame.Visible = false
    deviceFrame.Visible = true
end)

-- Joki Minigame langsung jalan
jokiMinigameButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    loadstring(game:HttpGet("https://raw.githubusercontent.com/petinjusemarang/petinjusemarang/main/samlongmini.lua"))()
end)

