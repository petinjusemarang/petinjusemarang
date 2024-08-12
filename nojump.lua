-- Skrip Anti-AFK tanpa GUI
local VirtualUser = game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Skrip untuk tidak melompat dengan auto loop
while true do
    local args = {
        [1] = "Enter",
        [2] = "2021Avanza15CVT"
    }

    game:GetService("ReplicatedStorage"):WaitForChild("NetworkContainer"):WaitForChild("RemoteEvents"):WaitForChild("Minigames"):FireServer(unpack(args))

    local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
    local location = CFrame.new(-4991, 20.7, 883.3)
    local respawnLocation = CFrame.new(-5000, 20.7, 880.0)

    local humanoid = game.Players.LocalPlayer.Character.Humanoid
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    wait(0.1)
    pl.CFrame = location

    wait(2)

    local touchPart = workspace:FindFirstChild("Interaksi")

    if touchPart then
        firetouchinterest(pl, touchPart, 0)
        firetouchinterest(pl, touchPart, 1)
    end

    while game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 do
        wait(0.1) -- Menunggu tanpa melompat
    end

    wait(20)
    pl.CFrame = respawnLocation
end
